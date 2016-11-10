# Public: An extension over Webmock's `stub_request`.
# Allows to stub specifically requests to Pipedrive.
#
# Examples
#
#   # in your spec file or spec_helper.rb
#
#   include Pipekit::Webmock::API
#
# before do
#   stub_pipedrive_request(
#     resource: :person,
#     action: :create,
#     params: {name: "Morty"},
#     response: {id: 123}
#   )
# end
require "webmock"
require "pipekit/webmock/errors"

module Pipekit
  module WebMock
    module API
      extend self

      def self.included(mod)
        if const_defined?("::WebMock::NetConnectNotAllowedError")
          ::WebMock.send(:remove_const, :NetConnectNotAllowedError)
          ::WebMock.send(:const_set, :NetConnectNotAllowedError, Pipekit::WebMock::UnregisteredPipedriveRequestError)
        end
      end

      def stub_pipedrive_request(resource:, action:, params:, response: nil)
        StubRequest.new(resource).stub_request_and_response(action, params, response)
      end

      class StubRequest
        include ::WebMock::API

        def initialize(resource)
          @request = Pipekit::Request.new(resource)
        end

        def stub_request_and_response(action, params, response)
          request = self.send("stub_#{action}_request", params)
          request.and_return(status: 200, body: {"data" => response, "success" => true}.to_json) if response
          request
        end

        private

        def stub_create_request(params)
          stub_request(:post, resource_uri).with(body: body_from(params))
        end

        def stub_update_request(params)
          id = params.delete(:id)
          stub_request(:put, resource_uri(id)).with(body: body_from(params))
        end

        def stub_get_request(params)
          id = params.delete(:id)
          uri = "#{resource_uri(id)}&#{body_from(pagination_params)}"
          stub_request(:get, uri)
        end

        def stub_search_request(params)
          field = params.keys.first
          value = params[field]
          query = @request.search_by_field_query(field, value).merge(pagination_params)
          uri = "#{Pipekit::Request::PIPEDRIVE_URL}/searchResults/field?#{api_token_param}&#{body_from(query)}"
          stub_request(:get, uri)
        end

        def stub_find_by_person_id_request(params)
          person_id = params.delete(:person_id)
          stub_request(:get, "#{Pipekit::Request::PIPEDRIVE_URL}/persons/#{person_id}/deals?#{api_token_param}&#{body_from(pagination_params)}")
        end

        def stub_find_by_email_request(params)
          email = params.delete(:email)
          stub_request(:get, "#{resource_uri("find")}&#{body_from(pagination_params)}&term=#{email}&search_by_email=1")
        end

        def stub_find_by_name_request(params)
          name = params.delete(:name)
          stub_request(:get, "#{resource_uri("find")}&#{body_from(pagination_params)}&term=#{name}")
        end

        def resource_uri(id = "")
          "#{Pipekit::Request::PIPEDRIVE_URL}#{@request.uri(id)}?#{api_token_param}"
        end

        def body_from(params)
          HTTParty::HashConversions.to_params(@request.parse_body(params))
        end

        def pagination_params
          {
            limit: @request.pagination_limit,
            start: 0
          }
        end

        def start
          0
        end

        def api_token_param
          "api_token=#{Config.fetch(:api_token)}"
        end
      end
    end
  end
end
