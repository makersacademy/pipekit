module Pipekit
  RSpec.describe Response do
    it "acts like a hash" do
      data = {
        "name" => "Dave"
      }

      response = described_class.new("person", data)

      expect(response["name"]).to eq("Dave")
    end

    describe "fetching custom fields" do
      it "converts custom field ids into their human readable name" do
        middle_name_label = Config.field("person", "middle_name")
        params = {
          middle_name_label => "Milhous",
          "first_name" => "Richard"
        }

        response = described_class.new("person", params)

        expect(response["middle_name"]).to eq("Milhous")
        expect(response["first_name"]).to eq("Richard")
      end

      it "still allows access using the original Pipedrive ID" do
        age_label = Config.field("deal", "middle_name")
        params = {
          age_label => 23,
        }

        response = described_class.new("deal", params)

        expect(response[age_label]).to eq(23)
      end

      context "when Pipedrive returns for a field's value a meaningless internal ID" do

        it "converts the ID into a meaningful label if this has been configured" do
          interview_result = "Amazing"
          pipedrive_id_for_result = 66

          allow(Config).to receive(:field_value)
            .with("person", :interview_quality, pipedrive_id_for_result)
            .and_return(interview_result)

          response = described_class.new("person", "interview_quality" => pipedrive_id_for_result)

          expect(response[:interview_quality]).to eq(interview_result)

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
  end
end
