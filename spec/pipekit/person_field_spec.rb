RSpec.describe Pipekit::PersonField do
  subject(:repository) { described_class.new(request) }
  let(:request) { instance_double("Pipedrive::Request") }

  it_behaves_like "a repository", true

  it "finds by id" do
    response = [{"id" => 1}, {"id" => 2}]

    allow(request).to receive(:get).and_return(response)

    expect(repository.get_by_id(2)).to eq([response.last])
  end

  it "finds by key" do
    allow(Pipekit).to receive(:custom_field).with("person", "middle_name").and_return("fieldkey")

    response = [{"key" => "no"},{"key" => "fieldkey"}]
    allow(request).to receive(:get).and_return(response)

    expect(repository.get_by_key("middle_name")).to eq([response.last])
  end
end
