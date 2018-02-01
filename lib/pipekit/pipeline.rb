module Pipekit
  class Pipeline
    include Repository
    SINGULAR_CLASSNAME = "pipeline".freeze
    PLURALIZED_CLASSNAME = "pipelines".freeze
  end
end