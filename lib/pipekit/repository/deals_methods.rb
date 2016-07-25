module Pipekit
  class Repository
    module DealsMethods
      def get_by_person_id(person_id)
        client.get("/#{Pipekit::Repository::Persons.uri}/#{person_id}/deals")
      end
    end
  end
end
