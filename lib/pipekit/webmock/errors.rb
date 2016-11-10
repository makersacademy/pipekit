require "rack"
require "webmock"

module Pipekit
  module WebMock
    class UnregisteredPipedriveRequestError < StandardError
      WebMockNetConnectNotAllowedError = ::WebMock::NetConnectNotAllowedError unless const_defined?(:WebMockNetConnectNotAllowedError)

      def initialize(request_signature)
        return WebMockNetConnectNotAllowedError.new(request_signature) unless request_signature.uri.hostname == "api.pipedrive.com"

        resource = request_signature.uri.path.split("/").last[0..-2]
        query = request_signature.uri.query
        body = request_signature.body
        text = [
          "Unregistered request to Pipedrive: #{request_signature.uri}",
          "with params:",
          extract_params(resource, query),
          "and body:",
          extract_params(resource, body),
          "="*60
        ].compact.join("\n\n")
        super(text)
      end

      def extract_params(resource, query)
        params = Rack::Utils.parse_nested_query(query)
        params.reduce({}) do |result, (field, value)|
          field = Config.field_name(resource, field)
          value = Config.field_value(resource, field, value)
          result.tap { |result| result[field] = value }
        end.map { |k, v| "#{k}: #{v}" }.join("\n")
      end
    end
  end
end
