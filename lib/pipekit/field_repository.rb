module Pipekit
  module FieldRepository
    include Repository
    def get_by_key(key)
      key = Config.field_id(parent_resource, key)
      search_fields("key", key)
    end

    def get_by_name(name)
      search_fields("name", name)
    end

    def find_label(field:, id:)
      find_values(field)
        .find(raise_label_not_found(field, id)) { |value| value["id"] == id.to_i }
        .fetch("label", "")
    end

    def find_values(field)
      find_by(name: field).fetch("options", [], choose_first_value: false)
    end

    private

    def raise_label_not_found(field, id)
      -> { raise LabelNotFoundError.new(field, id) }
    end

    def search_fields(field_element, value)
      result = request.get.select { |element| element[field_element] == value }

      raise ResourceNotFoundError.new("#{parent_resource}Field searching by element #{field_element} for #{value} could not be found") if result.empty?
      result
    end

    def parent_resource
      resource.chomp("Field")
    end

  end

  class LabelNotFoundError < StandardError

    def initialize(field, id)
      @field = field
      @id = id
    end

    def message
      "Could not find label for id: #{@id} with field: #{@field}"
    end
  end
end
