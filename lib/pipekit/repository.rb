module Pipekit
  module Repository

    def initialize(request = Pipekit::Request.new)
      @request = request
    end

    def all
      request.get("/#{uri}")
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
    def where(options)
      send("get_by_#{options.keys.first}", options.values.first)
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
      where(options).first
    end

    # Public: Create a record on Pipedrive.
    #
    # fields - fields for the record.
    #
    # Examples
    #
    #   create({name: "John Doe", deal_id: 123})
    #
    # Returns nothing.
    def create(fields)
      request.post("/#{uri}", fields)
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
      request.put("/#{uri}/#{id}", fields)
    end

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      attr_accessor :uri
    end

    private

    attr_reader :request

    def method_missing(method_name, *args)
      super unless method_name =~ /^get_by/

      field = method_name.to_s.gsub("get_by_", "")
      get_by_field(field: field, value: args[0])
    end

    def get_by_id(id)
      [request.get("/#{uri}/#{id}")]
    end

    def get_by_field(field:, value:)
      result = request.search_by_field(type: uri, field: field, value: value)
      result.map { |item| get_by_id(item["id"]) }.flatten
    end

    def uri
      self.class.uri
    end
  end
end
