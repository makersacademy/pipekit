module Pipekit

  RSpec.describe Config do

    it "can access config values from the yaml file" do
      expect(described_class.fetch("test")).to eq(2)
    end

    it "can provide a default value if no config value exists" do
      expect(described_class.fetch("non_existent value", :default)).to eq(:default)
    end

    it "raises an error if no config file has been set" do
      file_path = described_class.file_path
      Pipekit.config_file_path = nil

      expect{described_class.file_path}.to raise_error(Pipekit::Config::NotSetError)

      Pipekit.config_file_path = file_path
    end


    describe "fetching custom fields from the config" do
      it "converts custom field names into their Pipedrive ID" do
        result = described_class.field("person", "middle_name")
        person_fields = described_class.custom_fields["person"]
        expect(result).to eq(person_fields["middle_name"])
      end

      it "keeps keys that do not have a custom field the same" do
        result = described_class.field("person", "last_name")
        expect(result).to eq("last_name")
      end

      it "keeps keys that do not have a resource with custom fields the same" do
        result = described_class.field("blah", "last_name")
        expect(result).to eq("last_name")
      end
    end
  end
end
