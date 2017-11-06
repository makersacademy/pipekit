module Pipekit
  class DealField
    include FieldRepository
    # Pipedrive requires camelcase for resources
    PLURALIZED_CLASSNAME = "dealFields".freeze
  end
end
