module Pipekit
  class Repository
    module PersonsMethods
      def get_by_email(email)
        client.get("/#{uri}/find", term: email, search_by_email: 1)
      end

      def get_by_name(name)
        client.get("/#{uri}/find", term: name)
      end
    end
  end
end
