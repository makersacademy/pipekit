module Pipekit
  # Define a path to Pipedrive config file
  #
  # Example:
  #
  # Pipekit.config_file_path = File.join("config", "pipedrive.yml")
  class << self
    attr_writer :config_file_path

    def config_file_path
      @config_file_path || raise_config_error
    end

    def raise_config_error
      raise ConfigNotSetError, "You need to create a yaml file with your Pipedrive config and set the path to the file using `Pipedrive.config_file_path = 'path/to/file.yml'`"
    end
  end

  ConfigNotSetError = Class.new(Exception)
end

require "httparty"
require "pipekit/configurable"
require "pipekit/version"
require "pipekit/request"
require "pipekit/repository"
require "pipekit/person"
require "pipekit/deal"
