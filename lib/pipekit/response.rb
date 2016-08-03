module Pipekit
  class Response
    def initialize(resource, data, success = true)
      @resource = resource
      @data = data
      @success = success
    end

    def [](key)
      key = Config.field(resource, key)
      data[key]
    end

    def success?
      success
    end

    private

    attr_reader :data, :resource, :success
  end
end
