module Pipekit
  class Deal
    include Repository
    SINGULAR_CLASSNAME = "deal".freeze
    PLURALIZED_CLASSNAME = "deals".freeze

    def get_by_person_id(person_id, person_repo: Person.new)
      raise UnknownPersonError, "No person ID supplied when getting deals by person ID" unless person_id
      person_repo.find_deals(person_id)
    end

    # Finds a person by their email, then finds the first deal related to that
    # person and updates it with the params provided
    def update_by_person(email, params, person_repo: Person.new)
      person = person_repo.find_exactly_by_email(email)
      deal = get_by_person_id(person[:id], person_repo: person_repo).first
      update(deal[:id], params)
    end

    def flow(id)
      request.get("#{id}/flow")
    end
  end

  UnknownPersonError = Class.new(StandardError)
end
