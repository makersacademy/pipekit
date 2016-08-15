module Pipekit
  class Person
    include Repository

    def get_by_email(email)
      request.get("find", term: email, search_by_email: 1)
    end

    def get_by_name(name)
      request.get("find", term: name)
    end

    def create_or_update(fields)
      person = find_by(email: fields[:email])
      update(person["id"], fields)
    rescue ResourceNotFoundError
      create(fields)
    end

    def find_deals(id)
      request.get("#{id}/deals")
    end
  end
end
