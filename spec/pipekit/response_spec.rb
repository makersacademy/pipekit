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

      # If you create a set of values for a field for Pipedrive to populate into
      # a dropdown menu, such as for Interview Result we might have in our
      # dropdown:
      #
      # ["Amazing", "Good", "OK"]
      #
      # When returning the value for Interview Result, Pipedrive helpfully just
      # returns their own number for this so "Amazing" might be something like
      # "66"
      context "when Pipedrive returns for a field's value a meaningless internal ID" do

        it "converts Pipedrive" do
          interview_qualities = {
            "66" => "Amazing"
          }

          allow(Config).to receive(:field_value).with("person", :interview_quality, 66).and_return("Amazing")

          response = described_class.new("person", "interview_quality" => 66)

          expect(response[:interview_quality]).to eq("Amazing")

        end
      end
    end
  end
end
