module Pipekit
  class Person
    include Repository

    def get_by_email(email)
      request.get("find", term: email, search_by_email: 1)
    end

    def get_by_name(name)
      request.get("find", term: name)
    end

    def find_exactly_by_email(email)
      get_by_email(email).select do |item|
        item["email"] == email
      end.first
    end

    def update_by_email(email, fields)
      person = find_by(email: email)
      update(person["id"], fields)
    end

    def create_or_update(fields)
      update_by_email(fields[:email], fields)
    rescue ResourceNotFoundError
      create(fields)
    end

    def find_deals(id)
      request.get("#{id}/deals")
    end
  end
end
