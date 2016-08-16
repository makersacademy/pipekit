module Pipekit
  class Config
    class << self

      attr_writer :file_path

      # Finds the field name in the config from the Pipedrive ID
      #
      # Example
      #
      #   Config.field_name(:person, "asbasdfasc2343443")
      #     # => "middle_name"
      #
      #   Config.field_name(:person, "name")
      #     # => "name"
      def field_name(resource, key)
        custom_fields(resource)
          .invert
          .fetch(key.to_s, key.to_s)
      end

      # Finds the Pipedrive field ID from the config
      #
      # Example
      #
      #   Config.field_id(:person, "middle_name")
      #     # => "asbasdfasc2343443"
      #
      #   Config.field_id(:person, "name")
      #     # => "name"
      def field_id(resource, key)
        custom_fields(resource)
          .fetch(key.to_s, key.to_s)
      end

      # Finds the Pipedrive field value from the config
      # translating from a Pipedrive ID in the config if one exists for that
      # field/value
      #
      # Example
      #
      #   Config.field_value(:person, "inteview_quality", 66)
      #     # => "Amazing"
      #
      #   Config.field_value(:person, "inteview_quality", "value_not_there")
      #     # => "value_not_there"
      def field_value(resource, field, value)
        custom_field_values(resource, field)
          .fetch(value, value)
      end

      # Finds the Pipedrive field value ID from the config if one exists for that
      # field/value
      #
      # Example
      #
      #   Config.field_value_id(:person, "inteview_quality", "Amazing")
      #     # => 66
      #
      #   Config.field_value_id(:person, "inteview_quality", "value_not_there")
      #     # => "value_not_there"
      def field_value_id(resource, field, value)
        custom_field_values(resource, field)
          .invert
          .fetch(value, value)
      end

      def fetch(key, default = nil)
        config.fetch(key.to_s, default)
      end

      def custom_fields(resource)
        fetch("fields", {})
          .fetch(resource.to_s, {})
      end

      def custom_field_values(resource, field)
        fetch("field_values", {})
          .fetch(resource.to_s, {})
          .fetch(field.to_s, {})
      end

      def file_path
        @file_path || raise_config_error
      end

      private

      def config
        @config ||= load_config
      end

      def raise_config_error
        raise NotSetError, "You need to create a yaml file with your Pipedrive config and set the path to the file using `Pipekit.config_file_path = 'path/to/file.yml'`"
      end

      def load_config
        yaml = ERB.new(File.read(file_path)).result
        YAML.load(yaml)
      end
    end

    NotSetError = Class.new(Exception)
  end
end
