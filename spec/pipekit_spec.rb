require 'pipekit'

RSpec.describe Pipekit do
  it 'has a version number' do
    expect(Pipekit::VERSION).not_to be nil
  end

  it "raises an error if no config file has been set" do
    Pipekit.config_file_path = nil
    expect{Pipekit.config_file_path}.to raise_error(Pipekit::ConfigNotSetError)
  end
end
