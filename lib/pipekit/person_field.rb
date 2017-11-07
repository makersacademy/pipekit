module Pipekit
  class PersonField
    include FieldRepository
    # Pipedrive requires camelcase for resources
    PLURALIZED_CLASSNAME = "personFields".freeze
  end
end
