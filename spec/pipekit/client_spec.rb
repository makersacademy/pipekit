require 'webmock'
require 'spec_helper'

module Pipekit
  RSpec.describe Client do
    include WebMock::API
    WebMock.enable!

    subject(:client) { described_class.new }

    before do
      Pipekit.config_file_path = File.join(File.dirname(__FILE__), "..", "support", "config.yml")
    end

    describe "#get" do
      it "makes a get request to Pipedrive with correct options" do
        client = described_class.new
        stub_request(:get, "https://api.pipedrive.com/v1/persons?api_token=").to_return(status: 200, body: {success: true}.to_json)
        client.get("/persons")
      end
    end

    describe "#search_by_field" do
      it "makes a get request to Pipedrive /searchResults with a field key and value" do
        field_key = client.config["people_fields"]["middle_name"]
        field_type = "personField"
        return_item_ids = true
        term = "princess"
        url = "https://api.pipedrive.com/v1/searchResults/field?api_token=&field_key=#{field_key}&field_type=#{field_type}&return_item_ids=#{return_item_ids}&term=#{term}"
        stub_request(:get, url).to_return(status: 200, body: {success: true}.to_json)
        client.search_by_field(type: :person, field: :middle_name, value: term)
      end
    end

    context "Bad requests" do
      it "shows an error when an unsuccessful request is made" do
        uri = "/persons"
        body = {name: "Foo", test: "data"}
        response = double(:response, parsed_response: {"data" => "foo", "success" => false})

        stub_post("/persons", body, response)

        expect(client.post(uri, body)).to be nil
      end
    end

    def stub_post(uri, body, response)
      allow(described_class).to receive(:post).with(uri, query: default_query, body: body).and_return(response)
    end

    def default_query
      { api_token: client.config[:api_token] }
    end
  end
end
