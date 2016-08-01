module Pipekit
  class Deal
    include Repository

    def get_by_person_id(person_id, request = nil)
      request ||= Request.new(Person.resource)
      request.get("#{person_id}/#{resource}s")
    end
  end
end
