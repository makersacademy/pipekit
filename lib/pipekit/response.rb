module Pipekit
  class Response

    def initialize(resource, data)
      @resource = resource
      @data = data
    end

    def [](key)
      fetch(key)
    end

    def to_h
      data.inject({}) do |result, (field, value)|
        field_name = Config.field_name(resource, field)
        result[field_name.to_sym] = Config.field_value(resource, field, value)
        result
      end
    end

    alias_method :to_hash, :to_h

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
    # Options:
    #
    # find_value_on_pipedrive (default: false) - if set to true will look up using the Pipedrive
    # API the actual value of field (rather than the Pipedrive ID)
    #
    # choose_first_value (default: true) - if Pipedrive returns an array of values this will
    # choose the first one rather than return the array
    #
    # Examples:
    #
    # Normally you can just use the square brackets alias to fetch responses as
    # though this was a hash:
    #
    #    response[:resource] # returns: "Dave"
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
    def fetch(key, default = nil, opts = {})
      opts = {
        find_value_on_pipedrive: false,
        choose_first_value: true
      }.merge(opts)

      value = fetch_value(key, default)

      return value_from_pipedrive(key.to_s, value) if opts[:find_value_on_pipedrive]
      convert_value(key, value, opts)
    end

    def has_key?(key)
      data.has_key? convert_key(key)
    end

    private

    attr_reader :data, :resource

    def fetch_value(key, default)
      data.fetch(convert_key(key), default)
    end

    def value_from_pipedrive(key, value)
      field_repository
        .find_by(name: key)
        .fetch("options", [])
        .find { |options| options["id"] == value }
        .fetch("label")
    end

    def field_repository
      Object.const_get("Pipekit::#{resource.capitalize}Field").new
    end

    def convert_key(key)
      Config.field_id(resource, key)
    end

    def convert_value(key, value, opts)
      value = choose_first(value) if opts[:choose_first_value]
      Config.field_value(resource, key, value)
    end

    def choose_first(result)
      return result unless result.is_a? Array
      result.first["value"]
    end
  end
end
