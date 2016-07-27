module Pipekit
  class Deal
    include Repository

    self.uri = "deals"

    def get_by_person_id(person_id)
      request.get("/#{Pipekit::Person.uri}/#{person_id}/#{self.class.uri}")
    end
  end
end
