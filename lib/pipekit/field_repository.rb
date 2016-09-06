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

    def find_label(field:,id:)
      find_values(field).find({}) { |value| value["id"] == id }.fetch("label")
    end

    def find_values(field)
      find_by(name: field)["options"]
    end

    private

    def search_fields(field_element, value)
      result = request.get.select { |element| element[field_element] == value }

      raise ResourceNotFoundError.new("#{parent_resource}Field searching by element #{field_element} for #{value} could not be found") if result.empty?
      result
    end

    def parent_resource
      resource.chomp("Field")
    end
  end
end
