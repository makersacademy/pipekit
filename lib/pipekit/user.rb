module Pipekit
  class User
    include Repository

    def find_by_email(email)
      request.get('find', term: email, search_by_email: 1)
    end

    def find_by_name(name)
      request.get('find', term: name)
    end
  end
end
