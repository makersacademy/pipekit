require 'webmock/rspec'

module Pipekit
  RSpec.describe Request do
    include WebMock::API
    WebMock.enable!

    subject(:request) { described_class.new("person") }

    describe "#get" do
      it "makes a get request to Pipedrive with correct options" do
        result = {"name" => "Spike"}
        stub_get("persons/123", result, start: 10)

        response = request.get(123, start: 10)

        expect(response["name"]).to eq("Spike")
      end

      it "handles when the request returns an array of data" do
        result = [{"name" => "Dan"}]
        stub_get("persons", result)

        response = request.get

        expect(response.first["name"]).to eq("Dan")
      end

      it "handles automatically Pipedrive's pagination, doing additional requests when needed, when configured" do
        stub_get("persons", [:result1], more_items: true)
        stub_get("persons", [:result2], start: Request::DEFAULT_PAGINATION_LIMIT)

        response = request.get
        expect(response.length).to eq(2)
      end
    end

    describe "#search_by_field" do
      it "makes a get request to Pipedrive /searchResults with a field key and value" do
        field_key = Config.field_name("person", "middle_name")
        field_type = "personField"
        term = "princess"
        url = "searchResults/field?api_token=&field_key=#{field_key}&field_type=#{field_type}&return_item_ids=true&term=#{term}"
        response = { "name" => "middle name" }

        stub_request(:get, "#{Request::PIPEDRIVE_URL}/#{url}")
          .to_return(status: 200, body: {success: true, data: response}.to_json)

        result = request.search_by_field(field: :middle_name, value: term)

        expect(result["name"]).to eq("middle name")
      end
    end

    describe "#put" do
      it "makes a put request to Pipedrive with the correct options" do
        fields = {"middle_name" => "Dave", "interview_quality" => "Amazing"}
        custom_field = Config.field_name("person", "middle_name")
        interview_quality_id = Config.field_value_id("person", "interview_quality", "Amazing")
        id = "123"

        stub = stub_put("persons/123", "#{custom_field}=Dave&interview_quality=#{interview_quality_id}")

        request.put(id, fields)

        expect(stub).to have_been_requested
      end
    end

    describe "#post" do
      it "makes a post request to Pipedrive with the correct options" do
        fields = {"name" => "Bob", "middle_name" => "Milhous"}
        custom_field = Config.field_name("person", "middle_name")

        stub = stub_post("persons", "name=Bob&#{custom_field}=Milhous")

        request.post(fields)

        expect(stub).to have_been_requested
      end
    end

    describe "#post" do
      it "makes a post request to Pipedrive with the correct options" do
        fields = {"name" => "Bob", "middle_name" => "Milhous"}
        custom_field = Config.field_name("person", "middle_name")

        stub = stub_post("persons", "name=Bob&#{custom_field}=Milhous")

        request.post(fields)

        expect(stub).to have_been_requested
      end
    end

    describe "raising errors" do
      it "raises an error when response is unsuccessful" do
        stub_get("persons", "name=Bob", success: false)

        expect{request.get}.to raise_error(UnsuccessfulRequestError) 
      end

      it "raises an error when resource is not found" do
        stub_get("persons", "", success: true)

        expect{request.get}.to raise_error(ResourceNotFoundError) 
      end
    end

    def stub_get(uri, response, success: true, more_items: false, start: 0)
      stub_request(:get, "#{Request::PIPEDRIVE_URL}/#{uri}?api_token=&limit=#{Request::DEFAULT_PAGINATION_LIMIT}&start=#{start}")
        .to_return(status: 200, body: {
          success: success,
          data: response,
          additional_data: {
            pagination: {
              more_items_in_collection: more_items,
              next_start: Request::DEFAULT_PAGINATION_LIMIT
            }
          }
        }.to_json)
    end

    def stub_put(uri, body)
      stub_request(:put, "#{Request::PIPEDRIVE_URL}/#{uri}?api_token=")
        .with(body: body)
        .to_return(status: 200, body: {success: true, data: "not empty"}.to_json)
    end

    def stub_post(uri, body)
      stub_request(:post, "#{Request::PIPEDRIVE_URL}/#{uri}?api_token=")
        .with(body: body)
        .to_return(status: 200, body: {success: true, data: "not empty"}.to_json)
    end
  end
end
