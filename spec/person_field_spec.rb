RSpec.describe Pipekit::PersonField do
  subject(:repository) { described_class.new(request) }
  let(:request) { instance_double("Pipedrive::Request") }
  let(:uri) { "personFields" }

  it_behaves_like "a repository"

  it "finds by id" do
    response = [{"id" => 1}, {"id" => 2}]
    allow(request).to receive(:get).with("/personFields").and_return(response)

    expect(repository.get_by_id(2)).to eq([response.last])
  end

  it "finds by key" do
    config = { "people_fields" => { "middle_name" => "fieldkey"} }
    allow(request).to receive(:config).and_return(config)

    response = [{"key" => "no"},{"key" => "fieldkey"}]
    allow(request).to receive(:get).with("/personFields").and_return(response)

    expect(repository.get_by_key("middle_name")).to eq([response.last])
  end
end
