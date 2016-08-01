RSpec.describe Pipekit::Deal do
  let(:uri) { "deals" }

  it_behaves_like "a repository"

  it "finds values by person id" do
    request = instance_spy("Pipekit::Request")
    repository = described_class.new

    repository.get_by_person_id(123, request)

    expect(request).to have_received(:get).with("123/deals")
  end
end
