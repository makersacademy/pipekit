require 'webmock/rspec'

module Pipekit
  RSpec.describe Request do
    include WebMock::API
    WebMock.enable!

    subject(:request) { described_class.new("person") }

    describe "#get" do
      it "makes a get request to Pipedrive with correct options" do
        result = {"name" => "Spike"}
        stub_get("persons?api_token=", result)

        response = request.get

        expect(response["name"]).to eq("Spike")
      end

      it "handles when the request returns an array of data" do
        result = [{"name" => "Dan"}]
        stub_get("persons?api_token=", result)

        response = request.get

        expect(response.first["name"]).to eq("Dan")
      end
    end

    describe "#search_by_field" do
      it "makes a get request to Pipedrive /searchResults with a field key and value" do
        field_key = Config.field("person", "middle_name")
        field_type = "personField"
        term = "princess"
        url = "searchResults/field?api_token=&field_key=#{field_key}&field_type=#{field_type}&return_item_ids=true&term=#{term}"
        response = { "name" => "middle name"}

        stub_get(url, response)

        result = request.search_by_field(field: :middle_name, value: term)

        expect(result["name"]).to eq("middle name")
      end
    end

    describe "#put" do
      it "makes a put request to Pipedrive with the correct options" do
        fields = {"middle_name" => "Dave"}
        custom_field = Config.field("person", "middle_name")
        id = "123"

        stub = stub_put("persons/123?api_token=", "#{custom_field}=Dave")

        request.put(id, fields)

        expect(stub).to have_been_requested
      end
    end

    describe "#post" do
      it "makes a post request to Pipedrive with the correct options" do
        fields = {"name" => "Bob", "middle_name" => "Milhous"}
        custom_field = Config.field("person", "middle_name")

        stub = stub_post("persons?api_token=", "name=Bob&#{custom_field}=Milhous")

        request.post(fields)

        expect(stub).to have_been_requested
      end
    end

    describe "raising errors" do
      it "raises an error when response is unsuccessful" do
        stub_get("persons?api_token=", "name=Bob", false)

        expect{request.get}.to raise_error(UnsuccessfulRequestError) 
      end

      it "raises an error when resource is not found" do
        stub_get("persons?api_token=", "", true)

        expect{request.get}.to raise_error(ResourceNotFoundError) 
      end
    end

    def stub_get(uri, response, success = true)
      stub_request(:get, "#{Pipekit::Request::PIPEDRIVE_URL}/#{uri}").to_return(status: 200, body: {success: success, data: response}.to_json)
    end

    def stub_put(uri, body)
      stub_request(:put, "#{Pipekit::Request::PIPEDRIVE_URL}/#{uri}")
        .with(body: body)
        .to_return(status: 200, body: {success: true, data: "not empty"}.to_json)
    end

    def stub_post(uri, body)
      stub_request(:post, "#{Pipekit::Request::PIPEDRIVE_URL}/#{uri}")
        .with(body: body)
        .to_return(status: 200, body: {success: true, data: "not empty"}.to_json)
    end
  end
end
