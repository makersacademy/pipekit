module Pipekit
  class DealField
    include Repository

    def get_by_key(key)
      key = Pipekit.custom_field(Deal.resource, key)
      request.get.select { |element| element["key"] == key }
    end
  end
end
