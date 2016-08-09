module Pipekit
  class Config
    class << self

      attr_writer :file_path

      def field(resource, key)
        custom_fields
          .fetch(resource, {})
          .fetch(key.to_s, key.to_s)
      end

      def field_value(resource, key, value)
        fetch("field_values", {})
          .fetch(resource, {})
          .fetch(key.to_s, {})
          .fetch(value, value)
      end

      def custom_fields
        fetch("fields", {})
      end

      def fetch(key, default = nil)
        config.fetch(key.to_s, default)
      end

      def file_path
        @file_path || raise_config_error
      end

      private

      def config
        @config ||= load_config
      end

      def raise_config_error
        raise NotSetError, "You need to create a yaml file with your Pipedrive config and set the path to the file using `Pipedrive.config_file_path = 'path/to/file.yml'`"
      end

      def load_config
        yaml = ERB.new(File.read(file_path)).result
        YAML.load(yaml)
      end
    end

    NotSetError = Class.new(Exception)
  end
end
