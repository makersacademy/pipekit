RSpec.describe Pipekit::DealField do
  subject(:repository) { described_class.new(request) }
  let(:request) { instance_double("Pipedrive::Request") }

  it_behaves_like "a repository"

  it "finds by key" do
    allow(Pipekit).to receive(:custom_field).with("deal", "age").and_return("fieldkey")

    response = [{"key" => "no"},{"key" => "fieldkey"}]
    allow(request).to receive(:get).and_return(response)

    expect(repository.get_by_key("age")).to eq([response.last])
  end
end
