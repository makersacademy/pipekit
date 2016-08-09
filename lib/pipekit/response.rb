module Pipekit
  class Response
    def initialize(resource, data)
      @resource = resource
      @data = data
    end

    def [](key)
      fetch(key)
    end

    # This is more complicated than it first seems as Pipedrive returns any
    # custom field you might create (such as a new cohort in the Cohort field)
    # as a meaningless Pipedrive ID so it returns something semantically
    # meaningnless such as "8" when it means "April 2016"
    #
    # There are two ways this method gets around this to bring back the
    # semantically meaningful result you're looking for here, if you put in the
    # config under "field_values" the IDs that Pipedrive assigns to your custom
    # values (you'll have to search the API to work out what these are) it will
    # look them up there.
    #
    # Otherwise you can plass the "find_value_on_pipedrive" flag and it will do
    # a call to the Pipedrive API to look it up. This is off by default as it is
    # obviously quite slow to call an API each time you want to fetch some data
    #
    #
    # Examples:
    #
    # Normally you can just use the square brackets alias to fetch responses as
    # though this was a hash:
    #
    #    response[:name] # returns: "Dave"
    #
    # However if you find when doing this Pipedrive returns its meaningless ID
    #
    #    response[:cohort] # returns: 1234
    #
    # then you can tell Pipedrive to fetch it manually
    #
    #    response.fetch(:cohort, find_value_on_pipedrive: true) # returns: "April
    # 2016"
    #
    def fetch(key, default = nil, find_value_on_pipedrive: false)
      result = fetch_result(key, default)
      return value_from_pipedrive(key.to_s, result) if find_value_on_pipedrive
      convert(key, result)
    end

    private

    attr_reader :data, :resource

    def fetch_result(key, default)
      converted_key = Config.field(resource, key)
      data.fetch(converted_key, default)
    end

    def value_from_pipedrive(name, result)
      field_repository
        .find_by(name: name)
        .fetch("options")
        .find { |options| options["id"] == result }
        .fetch("label")
    end

    def field_repository
      Object.const_get("Pipekit::#{resource.capitalize}Field").new
    end

    def convert(key, result)
      Config.field_value(resource, key, result)
    end
  end
end
