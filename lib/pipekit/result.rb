# Understands how to represent the result of a request to the Pipedrive API
module Pipekit
  class Result

    def initialize(response_data)
      @response_data = response_data
      raise UnsuccessfulRequestError.new(response_data) unless success?
    end

    def response(resource)
      raise ResourceNotFoundError.new(response_data) unless resource_found?
      return Response.new(resource, response_body) unless response_body.is_a? Array
      response_body.map { |data| Response.new(resource, data) }
    end

    def +(other)
      self.class.new(other.merged_response(response_body))
    end

    def fetch_next_request?
      Config.fetch("request_all_pages", true) && pagination_data["more_items_in_collection"]
    end

    def next_start
      pagination_data["next_start"]
    end

    def self.response(resource, response_data)
      new(response_data).response(resource)
    end

    protected

    def merged_response(other_body)
      response_data.tap do |response|
        response["data"] = other_body + response_body
      end
    end

    private

    attr_reader :response_data

    def pagination_data
      response_data
        .fetch("additional_data", {})
        .fetch("pagination", {})
    end

    def response_body
      response_data["data"]
    end

    def success?
      response_data["success"]
    end

    def resource_found?
      !(response_body.nil? || response_body.empty?)
    end
  end

  class ResourceNotFoundError < StandardError
    def initialize(response)
      @response = response
    end

    def message
      "Resource not found, response was: #{@response}"
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
