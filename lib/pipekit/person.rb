module Pipekit
  class Person
    include Repository

    def get_by_email(email)
      request.get("/#{uri}/find", term: email, search_by_email: 1)
    end

    def get_by_name(name)
      request.get("/#{uri}/find", term: name)
    end
  end
end
