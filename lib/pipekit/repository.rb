require "pipekit/request"
require "pipekit/repository/persons_methods"
require "pipekit/repository/person_fields_methods"
require "pipekit/repository/deals_methods"

module Pipekit
  class Repository
    def initialize(uri, special_methods_module = nil, client = Pipekit::Request.new)
  new   @uri = uri
      @client = client
      extend(special_methods_module) if special_methods_module
    end

    def all
      client.get("/#{uri}")
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
      client.post("/#{uri}", fields)
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
      client.put("/#{uri}/#{id}", fields)
    end

    private

    attr_reader :client, :uri

    def method_missing(method_name, *args)
      super unless method_name =~ /^get_by/

      field = method_name.to_s.gsub("get_by_", "")
      get_by_field(field: field, value: args[0])
    end

    def get_by_id(id)
      [client.get("/#{uri}/#{id}")]
    end

    def get_by_field(field:, value:)
      result = client.search_by_field(type: uri, field: field, value: value)
      result.map { |item| get_by_id(item["id"]) }
    end

    #Persons = new("persons", Pipekit::Repository::PersonsMethods)
    #PersonFields = new("personFields", Pipekit::Repository::PersonFieldsMethods)
    #Deals = new("deals", Pipekit::Repository::DealsMethods)
    #Notes = new("notes")
  end
end
