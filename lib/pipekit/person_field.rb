module Pipekit
  class PersonField
    include FieldRepository
    # Pipedrive requires camelcase for resources
    SINGULAR_CLASSNAME = "personField".freeze
    PLURALIZED_CLASSNAME = "personFields".freeze
  end
end
