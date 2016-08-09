module Pipekit
  class PersonField
    include Repository

    def get_by_key(key)
      key = Config.field(Person.resource, key)
      request.get.select { |element| element["key"] == key }
    end
  end
end
