module Pipekit
  class Response
    def initialize(resource, data)
      @resource = resource
      @data = data
    end

    def [](key)
      converted_key = Config.field(resource, key)
      Config.field_value(resource, key, data[converted_key])
    end

    private

    attr_reader :data, :resource
  end
end
