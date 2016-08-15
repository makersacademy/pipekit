module Pipekit
  class Deal
    include Repository

    def get_by_person_id(person_id, person_repo: Person.new)
      person_repo.find_deals(123)
    end

    # Finds a person by their email, then finds the first deal related to that
    # person and updates it with the params provided
    def update_by_person(email, params, person_repo: Person.new)
      person = person_repo.find_by(email: email)
      deal = person_repo.find_deals(person[:id]).first
      update(deal[:id], params)
    end
  end
end
