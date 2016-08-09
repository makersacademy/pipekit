module Pipekit
  RSpec.describe PersonField do
    subject(:repository) { described_class.new(request) }
    let(:request) { instance_double("Pipekit::Request") }
    let(:config) { class_double("Pipekit::Config").as_stubbed_const }

    it_behaves_like "a repository"

    it "finds by key" do
      allow(config).to receive(:field).with("person", "middle_name").and_return("fieldkey")

      response = [{"key" => "no"},{"key" => "fieldkey"}]
      allow(request).to receive(:get).and_return(response)

      expect(repository.get_by_key("middle_name")).to eq([response.last])
    end
  end
end
