require "httparty"

module Pipekit
  class Request
    include HTTParty

    PIPEDRIVE_URL = "https://api.pipedrive.com/v1"
    DEFAULT_PAGINATION_LIMIT = 500

    base_uri PIPEDRIVE_URL
    format :json

    def initialize(resource)
      @resource = resource
      self.class.debug_output $stdout if Config.fetch(:debug_requests)
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
    #
    # This also uses the "request_all_pages" config option when set to do
    # multiple requests, getting around Pipedrive's pagination
    def search_by_field(field:, value:)
      query = search_by_field_query(field, value)

      get_request("/searchResults/field", query).response
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
    def get(id = "", query = {})
      uri = uri(id)
      _get(uri, query, get_request(uri, query))
    end

    def put(id, data)
      response_from self.class.put(uri(id), options(body: data))
    end

    def post(data)
      response_from self.class.post(uri, options(body: data))
    end

    attr_reader :resource

    def _get(uri, query, result)
      return result.response unless result.fetch_next_request?
      _get(uri, query, result + get_request(uri, query, result.next_start))
    end

    def get_request(uri, query, start = 0)
      response = self.class.get(uri, options(query: {limit: pagination_limit, start: start}.merge(query)))
      Result.new(resource, response)
    end

    def response_from(response_data)
      Result.response(resource, response_data)
    end

    def uri(id = "")
      "/#{resource}s/#{id}".chomp("/")
    end

    def options(query: {}, body: {})
      {
        query: query.merge(api_token: Config.fetch(:api_token)),
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
        value = Config.field_value_id(resource, field, value)
        field = Config.field_id(resource, field)
        result.tap { |result| result[field] = value }
      end
    end

    def pagination_limit
      Config.fetch(:pagination_limit, DEFAULT_PAGINATION_LIMIT)
    end

    def search_by_field_query(field = nil, value = nil)
      {
        field_type: "#{resource}Field",
        field_key: Config.field_id(resource, field),
        return_item_ids: true,
        term: Config.field_value_id(resource, field, value),
        exact_match: 1
      }
    end

  end
end
