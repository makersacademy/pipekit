describe "Pipekit::WebMock::API::stub_pipedrive_request" do
  include ::WebMock::API
  WebMock.enable!
  include Pipekit::WebMock::API

  it "registers a WebMock stub for creating a person" do
    stub_create = stub_pipedrive_request(
      resource: :person,
      action: :create,
      params: {name: "Bird Person", custom_field: "custom_value"}
    )

    actual_request_pattern = WebMock::StubRegistry.instance.request_stubs.first.request_pattern
    expected_request_pattern = "POST https://api.pipedrive.com/v1/persons?api_token=123456 with body \"name=Bird%20Person&99912a=99\""

    expect(actual_request_pattern.to_s).to eq(expected_request_pattern)

    remove_request_stub(stub_create)
  end

  it "registers a WebMock stub for updating a deal" do
    deal_params = {id: 123, stage: "1st Contact"}

    stub_update = stub_pipedrive_request(
      resource: :deal,
      action: :update,
      params: deal_params
    )

    actual_request_pattern = WebMock::StubRegistry.instance.request_stubs.first.request_pattern
    expected_request_pattern = "PUT https://api.pipedrive.com/v1/deals/123?api_token=123456 with body \"456sdf=23\""

    expect(actual_request_pattern.to_s).to eq(expected_request_pattern)
    remove_request_stub(stub_update)
  end

  it "registers WebMock stub for retreiving a person by id" do
    stub_get = stub_pipedrive_request(
      resource: :person,
      action: :get,
      params: {id: 123}
    )

    actual_request_pattern = WebMock::StubRegistry.instance.request_stubs.first.request_pattern
    expected_request_pattern = "GET https://api.pipedrive.com/v1/persons/123?api_token=123456&limit=500&start=0"

    expect(actual_request_pattern.to_s).to eq(expected_request_pattern)
    remove_request_stub(stub_get)
  end

  it "registers a WebMock stub for finding a person by a custom field (middle name)" do
    stub_search = stub_pipedrive_request(
      resource: :person,
      action: :search,
      params: {middle_name: "Purr"}
    )

    actual_request_pattern = WebMock::StubRegistry.instance.request_stubs.first.request_pattern

    query_string = "exact_match=1&field_key=123abc&field_type=personField&limit=500&return_item_ids=true&start=0&term=Purr"
    expected_request_pattern = "GET https://api.pipedrive.com/v1/searchResults/field?api_token=123456&#{query_string}"

    expect(actual_request_pattern.to_s).to eq(expected_request_pattern)
    remove_request_stub(stub_search)
  end

  it "registers a WebMock stub for finding deals for a person" do
    stub_find_by = stub_pipedrive_request(
      resource: :deal,
      action: :find_by_person_id,
      params: {person_id: 123}
    )

    actual_request_pattern = WebMock::StubRegistry.instance.request_stubs.first.request_pattern

    expected_request_pattern = "GET https://api.pipedrive.com/v1/persons/123/deals?api_token=123456&limit=500&start=0"

    expect(actual_request_pattern.to_s).to eq(expected_request_pattern)
    remove_request_stub(stub_find_by)
  end

  it "registers a WebMock stub for finding a person by email" do
    stub_find_by_email = stub_pipedrive_request(
      resource: :person,
      action: :find_by_email,
      params: {email: "octocat@github.com"}
    )

    actual_request_pattern = WebMock::StubRegistry.instance.request_stubs.first.request_pattern

    expected_request_pattern = "GET https://api.pipedrive.com/v1/persons/find?api_token=123456&limit=500&search_by_email=1&start=0&term=octocat@github.com"

    expect(actual_request_pattern.to_s).to eq(expected_request_pattern)
    remove_request_stub(stub_find_by_email)
  end

  it "registers a WebMock stub for finding a person by name" do
    stub_find_by_name = stub_pipedrive_request(
      resource: :person,
      action: :find_by_name,
      params: {name: "Jay Z"}
    )

    actual_request_pattern = WebMock::StubRegistry.instance.request_stubs.first.request_pattern

    expected_request_pattern = "GET https://api.pipedrive.com/v1/persons/find?api_token=123456&limit=500&start=0&term=Jay%20Z"

    expect(actual_request_pattern.to_s).to eq(expected_request_pattern)
    remove_request_stub(stub_find_by_name)
  end

  it "registers a WebMock stub with a return value in a form of Pipekit response object" do
    stub_create = stub_pipedrive_request(
      resource: :note,
      action: :create,
      params: {content: "rad", deal_id: 123},
      response: {id: 456}
    )

    actual_request = WebMock::StubRegistry.instance.request_stubs.first
    expected_request_pattern = "POST https://api.pipedrive.com/v1/notes?api_token=123456 with body \"content=rad&deal_id=123\""

    expect(actual_request.request_pattern.to_s).to eq(expected_request_pattern)
    expect(actual_request.response.body).to eq({data: {id: 456}, success: true}.to_json)

    remove_request_stub(stub_create)
  end

  xit "throws an exception when trying to register a stub for the unknown resource" do
  end

  xit "throws an exception when trying to register a stub for the unknown action" do
  end

  private

  def api_token
    Pipekit::Config.fetch(:api_token)
  end
end
