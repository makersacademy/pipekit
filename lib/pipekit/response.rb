module Pipekit
  class Response
    def initialize(resource, body)
      @resource = resource
      @body = body
    end

    def [](key)
      key = Pipekit.custom_field(resource, key)
      data[key]
    end

    def success?
      body["success"]
    end

    private

    attr_reader :body, :resource

    def data
      body["data"]
    end
  end
end
