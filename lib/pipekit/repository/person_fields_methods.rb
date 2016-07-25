module Pipekit
  class Repository
    module PersonFieldsMethods
      def get_by_id(id)
        client.get("/#{uri}").select { |element| element["id"] == id }
      end

      def get_by_key(key)
        custom_field_key = client.config["people_fields"][key] rescue nil
        key = custom_field_key || key
        client.get("/#{uri}").select { |element| element["key"] == key }
      end
    end
  end
end
