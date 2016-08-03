module Pipekit
  class Response
    def initialize(resource, data, pipedrive_success = true)
      @resource = resource
      @data = data
      @pipedrive_success = pipedrive_success
    end

    def [](key)
      key = Config.field(resource, key)
      data[key]
    end

    def success?
      pipedrive_success && !data.empty?
    end

    private

    attr_reader :data, :resource, :pipedrive_success
  end
end
