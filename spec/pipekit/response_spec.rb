module Pipekit
  RSpec.describe Response do
    it "acts like a hash" do
      data = {
        "name" => "Dave"
      }

      response = described_class.new("person", data)

      expect(response["name"]).to eq("Dave")
    end

    it "knows if it is a successful response" do
      successful_response = described_class.new("person", {}, true)
      unsuccessful_response = described_class.new("person", {}, false)

      expect(successful_response).to be_a_success
      expect(unsuccessful_response).not_to be_a_success
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
        expect(response[middle_name_label]).to eq("Milhous")
        expect(response["first_name"]).to eq("Richard")
      end

      it "still allows access using the original Pipedrive ID" do
        middle_name_label = Config.field("person", "middle_name")
        params = {
          middle_name_label => "Test",
        }

        response = described_class.new("person", params)

        expect(response[middle_name_label]).to eq("Test")
      end
    end
  end
end
