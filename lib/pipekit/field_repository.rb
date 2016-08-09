module Pipekit
  module FieldRepository
      def get_by_key(key)
        key = Config.field(parent_resource, key)
        result = request.get.select { |element| element["key"] == key }

        raise ResourceNotFoundError.new("#{parent_resource} field: #{key}") if result.empty?
        result
      end

      private

      def parent_resource
        resource.chomp("Field")
      end
  end
end
