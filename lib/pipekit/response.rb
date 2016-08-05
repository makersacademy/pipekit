module Pipekit
  class Response
    def initialize(resource, data)
      @resource = resource
      @data = data
    end

    def [](key)
      key = Config.field(resource, key)
      data[key.to_s]
    end

    private

    attr_reader :data, :resource
  end
end
