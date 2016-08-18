module Pipekit
  RSpec.describe Response do
    describe "fetching custom fields" do
      it "converts custom field ids into their human readable name" do
        params = {
          Config.field_id("person", "middle_name") => "Milhous",
          "first_name" => "Richard"
        }

        response = described_class.new("person", params)

        expect(response["middle_name"]).to eq("Milhous")
        expect(response["first_name"]).to eq("Richard")
      end

      it "still allows access using the original Pipedrive ID" do
        age_label = Config.field_id("deal", "middle_name")
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

        describe "Custom field values" do

          it "can fetch a custom field value from Pipedrive when specifically asked to" do
            cohort_id = "123"
            stub_deal_field_lookup(cohort_id)
            response = described_class.new("deal", "Cohort" => cohort_id)

            result = response.fetch("Cohort", nil, find_value_on_pipedrive: true)

            expect(result).to eq("August 2016")
          end

          it "raises an error" do
            stub_deal_field_lookup(1234)
            response = described_class.new("deal", "Cohort" => "unkown cohort")

            expect do
              response.fetch("Cohort", nil, find_value_on_pipedrive: true)
            end.to raise_error(ResourceNotFoundError)
          end

          def stub_deal_field_lookup(cohort_id)
            deal_field_data = {
              "options" => [
                { "id" => "other id", "label" => "Not this 2016" },
                { "id" => cohort_id.to_i, "label" => "August 2016" }
              ]
            }

            repository = instance_double("Pipedrive::DealField")
            allow(DealField).to receive(:new).and_return(repository)

            allow(repository).to receive(:find_by)
              .with(name: "Cohort")
              .and_return(described_class.new("dealField", deal_field_data))
          end
        end
      end
    end

    describe "fetching phone and email" do
      it "fetches the first value for results with multiple values" do
        email = "test@test.com"
        phone = "+447854676890"
        data = {
          "phone" => [{"label"=>"", "value"=> phone, "primary"=>true}],
          "email" => [{"label"=>"", "value"=> email, "primary"=>true}]
        }

        response = described_class.new("person", data)

        expect(response[:email]).to eq(email)
        expect(response[:phone]).to eq(phone)
      end

      it "does not fetch the result if an option is passed in to not choose first" do
        response = described_class.new("person", "email" => [:result])
        expect(response.fetch(:email, nil, choose_first_value: false)).to eq([:result])
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
        Config.field_id("person", "middle_name") => "Gob",
        "interview_quality" => interview_quality_id
      }

      response = described_class.new("person", data)

      expect(response.to_hash).to eq(name: "Simone", middle_name: "Gob", interview_quality: "Amazing")
    end

    it "knows if it has a key for a given value" do
      data = {
        "name" => "Simone",
        Config.field_id("person", "middle_name") => "Gob"
      }

      response = described_class.new("person", data)

      expect(response).to have_key(:name)
      expect(response).to have_key("middle_name")
      expect(response).not_to have_key(:blah)
    end

    def stub_field_value(field, pipedrive_id, label)
      allow(Config).to receive(:field_value)
        .with("person", field, pipedrive_id)
        .and_return(label)
    end
  end
end
