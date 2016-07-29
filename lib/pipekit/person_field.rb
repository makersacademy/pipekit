module Pipekit
  class PersonField
    include Repository

    def get_by_id(id)
      request.get("/#{uri}").select { |element| element["id"] == id }
    end

    def get_by_key(key)
      custom_field_key = request.config["people_fields"][key] rescue nil
      key = custom_field_key || key
      request.get("/#{uri}").select { |element| element["key"] == key }
    end
  end
end
