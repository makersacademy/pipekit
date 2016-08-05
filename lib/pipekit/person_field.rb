module Pipekit
  class PersonField
    include Repository

    def get_by_id(id)
      request.get.select { |element| element["id"] == id }
    end

    def get_by_key(key)
      key = Pipekit.custom_field(Person.resource, key)
      request.get.select { |element| element["key"] == key }
    end
  end
end
