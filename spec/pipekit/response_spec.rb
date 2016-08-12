module Pipekit
  RSpec.describe Response do
    describe "fetching custom fields" do
      it "converts custom field ids into their human readable name" do
        params = {
          Config.field_name("person", "middle_name") => "Milhous",
          "first_name" => "Richard"
        }

        response = described_class.new("person", params)

        expect(response["middle_name"]).to eq("Milhous")
        expect(response["first_name"]).to eq("Richard")
      end

      it "still allows access using the original Pipedrive ID" do
        age_label = Config.field_name("deal", "middle_name")
        params = {
          age_label => 23,
        }

        response = described_class.new("deal", params)

        expect(response[age_label]).to eq(23)
      end

      context "when Pipedrive returns for a field's value a meaningless internal ID" do

        it "converts the ID into a meaningful label if this has been configured" do
          pipedrive_id = 66
          stub_field_value(:interview_quality, pipedrive_id, "Amazing")
          response = described_class.new("person", "interview_quality" => pipedrive_id)

          expect(response[:interview_quality]).to eq("Amazing")

        end

        it "can fetch a custom field value from Pipedrive when specifically asked to" do
          cohort_id = 123
          cohort_field = {
            "options" => [
              { "id" => cohort_id, "label" => "August 2016" },
              { "id" => "other id", "label" => "Not this 2016" }
            ]
          }

          repository = instance_double("Pipedrive::DealField")
          allow(DealField).to receive(:new).and_return(repository)
          allow(repository).to receive(:find_by).with(name: "Cohort").and_return(cohort_field)

          response = described_class.new("deal", "Cohort" => cohort_id)

          result = response.fetch(:Cohort, find_value_on_pipedrive: true)

          expect(result).to eq("August 2016")
        end
      end

    end

    it "acts like a hash" do
      data = {
        "name" => "Dave"
      }

      response = described_class.new("person", data)
      expect(response["name"]).to eq("Dave")
    end


    it "can fetch the data as a hash, converting custom keys and values from the config" do
      # ID fetched from test config in spec/support/config.yml
      interview_quality_id = 66
      data = {
        "name" => "Simone",
        Config.field_name("person", "middle_name") => "Gob",
        "interview_quality" => interview_quality_id
      }

      response = described_class.new("person", data)

      expect(response.to_hash).to eq(name: "Simone", middle_name: "Gob", interview_quality: "Amazing")
    end

    def stub_field_value(field, pipedrive_id, label)
      allow(Config).to receive(:field_value)
        .with("person", field, pipedrive_id)
        .and_return(label)
    end
  end
end
