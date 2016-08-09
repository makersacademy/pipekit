$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pipekit'
require "support/repository_shared"
require "support/field_repository_shared"

# Dummy config data
Pipekit.config_file_path = File.join(File.dirname(__FILE__), "support", "config.yml")
