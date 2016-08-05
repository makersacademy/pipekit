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
      self.class.debug_output $stdout if Config.fetch("debug_requests")
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
               field_key: Config.field(resource, field),
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

    def uri(id = nil)
      "/#{resource}s/#{id}".chomp("/")
    end

    def result_from(response)
      data = response["data"]
      success = response["success"]

      return Response.new(resource, data, success) unless data.is_a? Array
      data.map { |details| Response.new(resource, details, success) }
    end

    def options(query: {}, body: {})
      {
        query: {api_token: Config.fetch("api_token") }.merge(query),
        body: parse_body(body)
      }
    end

    # Replaces custom fields with their Pipedrive ID
    # if the ID is defined in the configuration
    #
    # So if the body looked like this with a custom field
    # called middle_name:
    #
    # { middle_name: "Dave" }
    #
    # And it has a Pipedrive ID ("123abc"), this will put in this custom ID
    #
    # { "123abc": "Dave" }
    #
    # meaning you don't have to worry about the custom IDs
    def parse_body(body)
      body.reduce({}) do |result, (field, value)|
        field = Config.field(resource, field)
        result.tap { |result| result[field] = value }
      end
    end
  end
end
