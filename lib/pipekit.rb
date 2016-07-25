module Pipekit
  # Define a path to Pipedrive config file
  #
  # Example:
  #
  # Pipekit.config_file_path = File.join("config", "pipedrive.yml")
  class << self
    attr_accessor :config_file_path
  end
end

require "httparty"
require "pipekit/configurable"
require "pipekit/version"
require "pipekit/client"
require "pipekit/repository"
