# TODO extract to pipekit-webmock feature tests

RSpec.describe "Pipekit Webmock stubs" do
  ::WebMock.enable!
  include Pipekit::WebMock::API

  let(:person_repo) { Pipekit::Person.new }
  let(:deal_repo) { Pipekit::Deal.new }
  let(:person_params) {
    {
      "email" => "octocat@github.com",
      "name" => "Octocat",
      "middle_name" => "Purr"
    }
  }

  it "should stub a create Person request to Pipedrive API" do
    stub_pipedrive_request(
      resource: :person,
      action: :create,
      params: person_params
    ).and_return(status: 200, body: {"data" => {"id" => 123}, "success" => true}.to_json)
    person_repo.create(person_params)
  end

  it "should stub a find Person by custom value request to Pipedrive API" do
    stub_pipedrive_request(
      resource: :person,
      action: :search,
      params: {middle_name: "Purr"}
    ).and_return(status: 200, body: {"data" => [{"id" => 123}], "success" => true}.to_json)
    stub_pipedrive_request(
      resource: :person,
      action: :get,
      params: {id: 123}
    ).and_return(status: 200, body: {"data" => {"id" => 123}, "success" => true}.to_json)

    person_repo.find_by(middle_name: "Purr")
  end

  it "should stub a find deals for person request to Pipedrive API" do
    stub_pipedrive_request(
      resource: :deal,
      action: :find_by_person_id,
      params: {person_id: 123}
    ).and_return(status: 200, body: {"data" => [{"id" => 234}], "success" => true}.to_json)

    deal_repo.find_by(person_id: 123)
  end

  it "should stub a find person by email request to Pipedrive API" do
    stub_pipedrive_request(
      resource: :person,
      action: :find_by_email,
      params: {email: "octocat@github.com"}
    ).and_return(status: 200, body: {"data" => [{"id" => 234}], "success" => true}.to_json)

    person_repo.find_by(email: "octocat@github.com")
  end

  it "should stub a find person by name request to Pipedrive API" do
    stub_pipedrive_request(
      resource: :person,
      action: :find_by_name,
      params: {name: "Octocat"}
    ).and_return(status: 200, body: {"data" => [{"id" => 234}], "success" => true}.to_json)

    person_repo.find_by(name: "Octocat")
  end

  xit "should throw a readable error if a different request was sent" do
    actual_person_params = {
      "email" => "octocat@github.com",
      "name" => "John Doe",
      "Phone number" => "+0123345567"}

    expect { person_repo.create(actual_person_params) }.to raise_error(error_message)
  end
end
