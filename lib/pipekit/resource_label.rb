module Pipekit
  class ResourceLabel

    attr_reader :singular, :pluralized

    def initialize(singular_label:, pluralized_label:)
      @singular = singular_label
      @pluralized = pluralized_label
    end

  end
end
