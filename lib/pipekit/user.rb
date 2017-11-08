module Pipekit
  class User
    include Repository
    SINGULAR_CLASSNAME = "user".freeze
    PLURALIZED_CLASSNAME = "users".freeze

    def get_by_email(email)
      request.get('find', term: email, search_by_email: 1)
    end

    def get_by_name(name)
      request.get('find', term: name)
    end
  end
end
