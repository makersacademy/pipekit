require "httparty"

# Add a parameter of @resource
# then a result object can be returned in result from
# this can then normalize the fields on the fly if they are configured

module Pipekit
  class Request
    include HTTParty

    PIPEDRIVE_URL = "https://api.pipedrive.com/v1"

    base_uri PIPEDRIVE_URL
    format :json

    def initialize(resource)
      @resource = resource
    end

    # Public: Pipedrive /searchField API call.
    #
    # type - Type of the field:
    #        :person - person fields
    #        :deal - deal fields
    # field - The name of the field.
    #         If it's the custom field the id of the field should be stored in `config/pipedrive.yml`.
    # value - The value of the field.
    #
    # Examples
    #
    #   search_by_field(field: :cohort, value: 119)
    #   search_by_field(field: :github_username, value: "octocat")
    #
    # Returns an array of Hashes or nil.
    def search_by_field(field:, value:)
      query = {field_type: "#{resource}Field",
                 field_key: config["fields"]["person"][field],
                 return_item_ids: true,
                 term: value
      }

      result_from self.class.get("/searchResults/field", options(query: query))
    end

    def get(suffix = nil, query = {})
      result_from self.class.get(uri(suffix), options(query: query))
    end

    def put(id, body)
      result_from self.class.put(uri(id), options(body: body))
    end

    def post(body)
      result_from self.class.post(uri, options(body: body))
    end

    private

    attr_reader :resource

    def config
      Pipekit.config
    end

    def uri(id = nil)
      "/#{resource}s/#{id}".chomp("/")
    end

    def result_from(response)
      Response.new(resource, response)
    end

    def options(query: {}, body: {})
      {
        query: {api_token: config[:api_token] }.merge(query),
        body: body
      }
    end
  end
end
