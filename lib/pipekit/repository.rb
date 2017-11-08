module Pipekit
  module Repository

    def initialize(request = nil)
      @request = request || Request.new(resource)
    end

    def all(query = {})
      request.get("", query)
    end

    # Public: Get all records from Pipedrive by **one** of the record's fields.
    #
    # options - A Hash with one key-value pair. Key is a field name and values is a field value.
    #
    # Examples
    #
    #   where(name: "John Doe")
    #   where(github_username: "pipedriver")
    #   where(id: 123)
    #
    # Returns array of Hashes.
    def where(options, raise_error = false)
      send("get_by_#{options.keys.first}", options.values.first)
    rescue ResourceNotFoundError => error
      raise error if raise_error
      []
    end

    # Public: Get the first record by **one** field from Pipedrive.
    #
    # options - A Hash with one key-value pair. Key is a field name and values is a field value.
    #
    # Examples
    #
    #   find_by(name: "John Doe")
    #   find_by(github_username: "pipedriver")
    #   find_by(id: 123)
    #
    # Returns a Hash or nil if none found.
    def find_by(options)
      warn "Using `Repository#find_by` with an email may return inexact matches" if email_key?(options)
      where(options, true).first
    end

    # Public: Create a record on Pipedrive.
    #
    # fields - fields for the record.
    #
    #
    # Examples
    #   create({name: "John Doe", deal_id: 123})
    #
    # Returns nothing.
    def create(fields)
      request.post(fields)
    end

    # Public: Updates a record on Pipedrive.
    #
    # fields - fields for the record.
    #
    # Examples
    #
    #   update(123, {name: "Jane Doe"})
    #
    # Returns nothing.
    def update(id, fields)
      request.put(id, fields)
    end

    private

    attr_reader :request

    def method_missing(method_name, *args)
      super unless method_name =~ /^get_by/

      field = method_name.to_s.gsub("get_by_", "")
      get_by_field(field: field, value: args[0])
    end

    def get(id = nil)
      request.get(id)
    end

    def get_by_id(id)
      [get(id)]
    end

    def get_by_field(field:, value:)
      result = request.search_by_field(field: field, value: value)
      result.map { |item| get_by_id(item["id"]) }.flatten
    end

    def resource
      singular_resource = self.class.to_s.downcase
      pluralized_resource = self.class::PLURALIZED_CLASSNAME
      ResourceLabel.new(singular_label: singular_resource, pluralized_label: pluralized_resource)
    end

    def email_key?(options)
      options.keys.first && options.keys.first.to_s == "email"
    end
  end
end
