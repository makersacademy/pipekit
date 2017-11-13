module Pipekit
  class PersonField
    include FieldRepository
    SINGULAR_CLASSNAME = "personField".freeze
    # Pipedrive requires camelcase for resources
    PLURALIZED_CLASSNAME = "personFields".freeze
  end
end
