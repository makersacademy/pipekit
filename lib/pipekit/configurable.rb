require "yaml"
require "active_support/inflector"
require "active_support/core_ext/hash/indifferent_access"

module Configurable
  def config
    self.class.config
  end

  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    def config_file_path
      "./config/#{name.underscore}.yml"
    end

    def config
      @config ||= load_config.with_indifferent_access
    end

    private

    def load_config
      config_hash = load_from_yaml

      config_hash.default_proc = proc do |hash, key|
        raise Configurable::KeyNotFoundError.new(key)
      end

      config_hash
    end

    def load_from_yaml
      yaml = ERB.new(File.read(config_file_path)).result
      YAML.load(yaml)
    end
  end

  class KeyNotFoundError < StandardError
    def initialize(key)
      super("The key #{key} was not found in the configuration file")
    end
  end
end
