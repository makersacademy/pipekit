require "httparty"

# Add a parameter of @resource
# then a result object can be returned in result from
# this can then normalize the fields on the fly if they are configured

module Pipekit
  class Request
    include HTTParty

    PIPEDRIVE_URL = "https://api.pipedrive.com/v1"
    DEFAULT_PAGINATION_LIMIT = 500

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
    # Returns an array of Response objects or throws a ResourceNotFoundError if
    # it couldn't find anything.
    def search_by_field(field:, value:)
      query = {field_type: "#{resource}Field",
               field_key: Config.field(resource, field),
               return_item_ids: true,
               term: value
      }

      result_from self.class.get("/searchResults/field", options(query: query))
    end

    # Public: Pipedrive GET API call - does a GET request to the Pipedrive API
    # based on the resource passed in the initialiser
    #
    # id - If the resource being searched for has an id
    # query - An optional query string
    # start - The offset with which to start the query
    #
    # As long as "request_all_pages" is not set to false in the config this will
    # recursively call `#get` until all the pages of the request have been
    # fetched from pipedrive
    # Pipedrive until everything available has been received
    def get(id = nil, query = {})
      _get(id, query)
    end

    def _get(id, query, start = 0, result = [], fetch_next_request = true)
      return result unless fetch_next_request

      response = self.class.get(uri(id), options(query: {limit: pagination_limit, start: start}.merge(query)))
      pagination = pagination_data(response)
      result = result_from(response, result)

      _get(id, query, pagination["next_start"], result, fetch_next_request?(pagination))
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

    def pagination_data(response)
      response
        .fetch("additional_data", {})
        .fetch("pagination", {})
    end

    def fetch_next_request?(pagination)
      Config.fetch("request_all_pages", true) && pagination["more_items_in_collection"]
    end

    def result_from(response, previous_result = [])
      raise UnsuccessfulRequestError.new(response) unless response["success"]
      raise ResourceNotFoundError.new(response) unless resource_found?(response)
      data = response["data"]

      return Response.new(resource, data) unless data.is_a? Array
      previous_result + data.map { |details| Response.new(resource, details) }
    end

    def options(query: {}, body: {})
      {
        query: query.merge(api_token: Config.fetch("api_token")),
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

    def resource_found?(response)
      !(response["data"].nil? || response["data"].empty?)
    end

    def pagination_limit
      Config.fetch("pagination_limit", DEFAULT_PAGINATION_LIMIT)
    end

  end

  class ResourceNotFoundError < StandardError
    def initialize(response)
      @response = response
    end

    def message
      "Resource not found: #{@response}"
    end
  end

  class UnsuccessfulRequestError < StandardError
    def initialize(response)
      @response = response
    end

    def message
      "Request not successful: #{@response}"
    end
  end
end
