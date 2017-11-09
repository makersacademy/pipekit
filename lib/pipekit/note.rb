module Pipekit
  class Note
    include Repository
    SINGULAR_CLASSNAME = "note".freeze
    PLURALIZED_CLASSNAME = "notes".freeze
  end
end
