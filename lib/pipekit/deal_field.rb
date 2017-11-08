module Pipekit
  class DealField
    include FieldRepository
    SINGULAR_CLASSNAME = "dealField".freeze
    # Pipedrive requires camelcase for resources
    PLURALIZED_CLASSNAME = "dealFields".freeze
  end
end
