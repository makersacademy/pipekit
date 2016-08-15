module Pipekit

  RSpec.describe Config do

    # This value is taken from the file at spec/support/config.yml
    let(:middle_name_id) { "123abc" }
    let(:interview_quality_id) { 66 }

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


    describe "fetching custom fields IDs from the config" do
      it "converts custom field names into their Pipedrive ID" do
        result = described_class.field_id("person", "middle_name")
        expect(result).to eq(middle_name_id)
      end

      it "keeps keys that do not have a custom field the same" do
        result = described_class.field_id("person", "last_name")
        expect(result).to eq("last_name")
      end

      it "keeps keys that do not have a resource with custom fields the same" do
        result = described_class.field_id("blah", "last_name")
        expect(result).to eq("last_name")
      end
    end

    describe "fetching field names from the config" do
      it "converts custom Pipedrive IDs into their more readable name" do
        result = described_class.field_name("person", middle_name_id)
        expect(result).to eq("middle_name")
      end

      it "keeps keys that do not have a custom field the same" do
        result = described_class.field_name("person", "last_name")
        expect(result).to eq("last_name")
      end
    end

    describe "fetching custom field values from the config" do
      it "converts custom field values from their Pipedrive ID into their meaningful name" do
        result = described_class.field_value("person", :interview_quality, interview_quality_id)
        expect(result).to eq("Amazing")
      end

      it "keeps values that do not have a custom field the same" do
        result = described_class.field_value("person", "interview_quality", "value_not_there")
        expect(result).to eq("value_not_there")
      end
    end

    describe "fetching custom field value IDs from the config" do
      it "converts custom field values into their Pipedrive ID when it exists in the config" do
        result = described_class.field_value_id("person", :interview_quality, "Amazing")
        expect(result).to eq(interview_quality_id)
      end

      it "keeps values that do not have a custom field value ID the same" do
        result = described_class.field_value_id("person", "interview_quality", "value_not_there")
        expect(result).to eq("value_not_there")
      end
    end
  end
end
