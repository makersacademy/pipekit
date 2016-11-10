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
      params: person_params,
      response: {"id" => 123}
    )
    person_repo.create(person_params)
  end

  it "should stub a find Person by custom value request to Pipedrive API" do
    stub_pipedrive_request(
      resource: :person,
      action: :search,
      params: {middle_name: "Purr"},
      response: [{"id" => 123}]
    )
    stub_pipedrive_request(
      resource: :person,
      action: :get,
      params: {id: 123},
      response: {"id" => 123}
    )

    person_repo.find_by(middle_name: "Purr")
  end

  it "should stub a find deals for person request to Pipedrive API" do
    stub_pipedrive_request(
      resource: :deal,
      action: :find_by_person_id,
      params: {person_id: 123},
      response: [{"id" => 234}]
    )

    deal_repo.find_by(person_id: 123)
  end

  it "should stub a find person by email request to Pipedrive API" do
    stub_pipedrive_request(
      resource: :person,
      action: :find_by_email,
      params: {email: "octocat@github.com"},
      response: [{"id" => 234}]
    )

    person_repo.find_by(email: "octocat@github.com")
  end

  it "should stub a find person by name request to Pipedrive API" do
    stub_pipedrive_request(
      resource: :person,
      action: :find_by_name,
      params: {name: "Octocat"},
      response: [{"id" => 234}]
    )

    person_repo.find_by(name: "Octocat")
  end

  it "should throw a readable error if a different request was sent" do
    error_message = %r(Unregistered request to Pipedrive: https://api.pipedrive.com:443/v1/persons\?api_token=123456

with params:

api_token: 123456

and body:

email: octocat@github.com
name: John Doe
custom_field: custom_value
)

    stub_pipedrive_request(
      resource: :person,
      action: :create,
      params: {
        name: "Bugz Bunny",
        middle_name: "Doc"
      },
      response: {id: 123}
    )

    actual_person_params = {
      "email" => "octocat@github.com",
      "name" => "John Doe",
      "custom_field" => "custom_value"}

    expect { person_repo.create(actual_person_params) }.to raise_error(error_message)
  end
end
