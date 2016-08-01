RSpec.describe Pipekit do
  it 'has a version number' do
    expect(Pipekit::VERSION).not_to be nil
  end

  it "raises an error if no config file has been set" do
    Pipekit.config_file_path = nil
    expect{Pipekit.config_file_path}.to raise_error(Pipekit::ConfigNotSetError)
  end

  describe "fetching custom fields from the config" do
    it "converts custom field names into their Pipedrive ID" do
      result = Pipekit.custom_field("person", "middle_name")
      expect(result).to eq(Pipekit.config["fields"]["person"]["middle_name"])
    end

    it "keeps keys that do not have a custom field the same" do
      result = Pipekit.custom_field("person", "last_name")
      expect(result).to eq("last_name")
    end
  end
end
