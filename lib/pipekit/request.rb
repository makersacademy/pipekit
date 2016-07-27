require "httparty"

module Pipekit
  class Request
    include HTTParty

    PIPEDRIVE_URL = "https://api.pipedrive.com/v1"

    base_uri PIPEDRIVE_URL
    format :json

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
    #   search_by_field(type: :person, field: :cohort, value: 119)
    #   search_by_field(type: :person, field: :github_username, value: "octocat")
    #
    # Returns an array of Hashes or nil.
    def search_by_field(type:, field:, value:)
      options = {field_type: "#{type}Field",
                 field_key: config["#{type.to_s.pluralize}_fields"][field],
                 return_item_ids: true}

      get("/searchResults/field", options.merge(term: value))
    end

    def get(uri, query = {})
      result_from self.class.get(uri, options(query: query))
    end

    def put(uri, body)
      result_from self.class.put(uri, options(body: body))
    end

    def post(uri, body)
      result_from self.class.post(uri, options(body: body))
    end

    private

    def config
      Pipekit.config
    end

    def result_from(response)
      return nil unless success?(response)
      response.parsed_response["data"]
    end

    def success?(response)
      response.parsed_response["success"]
    end

    def options(query: {}, body: {})
      {
        query: {api_token: config[:api_token] }.merge(query),
        body: body
      }
    end
  end
end
