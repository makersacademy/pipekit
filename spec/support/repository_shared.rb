RSpec.shared_examples "a repository" do

  subject(:repository) { described_class.new(request) }

  let(:request) { instance_spy("Pipedrive::Request") }
  let(:normalize_fields) { class_double("Pipekit::NormalizeFields").as_stubbed_const }

  describe "#all" do
    it "returns all records from the repository" do
      repository.all
      expect(request).to have_received(:get).with("/#{uri}")
    end
  end

  describe "#where" do
    it "returns records matching given field" do
      search_data = {type: uri, field: "fake_field", value: "fake value"}
      response = {id: 123, name: "Test"}

      allow(request).to receive(:search_by_field).with(search_data).and_return([{"id" => 123}])
      allow(repository).to receive(:get_by_id).and_return(response)

      expect(repository.where(fake_field: "fake value")).to eq([response])
    end
  end

  describe "formatting fields" do
    context "when there is a configuration option to normalize field names" do
      it "replaces for all configured fields their ID with their human friendly name" do
        dummy_config = { "normalize_fields" => true }

        response = [{id: 123, "123abc" => "Milhaus"}]
        formatted_response = [{id: 123, "middle_name" => "Milhaus"}]

        allow(Pipekit).to receive(:config).and_return(dummy_config)
        expect(normalize_fields).to receive(:with).with(response).and_return(formatted_response)
        allow(request).to receive(:get).with("/#{uri}").and_return(response)

        expect(repository.all).to eq(formatted_response)
      end
    end
  end

  describe "find_by" do
    it "returns the first record matching given field" do
      data = {foo: :bar}
      expect(repository).to receive(:get_by_fake_field).with("fake value").and_return([data])
      expect(repository.find_by(fake_field: "fake value")).to eq(data)
    end
  end

  describe "create" do
    it "creates a record in a repository" do
      fields = {foo: :bar}
      expect(request).to receive(:post).with("/#{uri}", fields)
      repository.create(fields)
    end
  end

  describe "update" do
    it "updates a record in a repository" do
      id = 1
      fields = {foo: :bar}
      expect(request).to receive(:put).with("/#{uri}/#{id}", fields)
      repository.update(id, fields)
    end
  end
end
