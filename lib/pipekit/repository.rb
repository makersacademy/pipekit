module Pipekit
  module Repository

    def initialize(request = nil)
      @request = request || Request.new(self.class)
    end

    def all
      get
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

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def resource
        to_s.split("::").last.tap { |name| name[0] = name[0].downcase }
      end
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
      self.class.resource
    end
  end
end
