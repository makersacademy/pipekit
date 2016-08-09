require "pipekit/config"
require "httparty"
require "pipekit/version"
require "pipekit/request"
require "pipekit/result"
require "pipekit/response"
require "pipekit/repository"
require "pipekit/person"
require "pipekit/deal"
require "pipekit/person_field"
require "pipekit/note"

module Pipekit

  # Define a path to Pipedrive config file
  #
  # Example:
  #
  # Pipekit.config_file_path = File.join("config", "pipedrive.yml")
  def self.config_file_path=(path)
    Config.file_path = path
  end
end

