module Pipekit
  module FieldRepository
      def get_by_key(key)
        key = Config.field_name(parent_resource, key)
        search_fields("key", key)
      end

      def get_by_name(name)
        search_fields("name", name)
      end

      private

      def search_fields(field_element, value)
        result = request.get.select { |element| element[field_element] == value }

        raise ResourceNotFoundError.new("#{parent_resource} field searching by element #{field_element}: #{value}") if result.empty?
        result
      end

      def parent_resource
        resource.chomp("Field")
      end
  end
end
