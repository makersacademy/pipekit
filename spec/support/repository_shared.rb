RSpec.shared_examples "a repository" do

  subject(:repository) { described_class.new(request) }

  let(:request) { instance_spy("Pipedrive::Request") }

  describe "#all" do
    it "returns all records from the repository" do
      repository.all(filter_id: 2)
      expect(request).to have_received(:get).with("", filter_id: 2)
    end
  end

  describe "#where" do
    it "returns records matching given field" do
      search_data = {field: "fake_field", value: "fake value"}
      response = {id: 123, name: "Test"}
      field_id = "field-id-123"

      allow(request).to receive(:search_by_field).with(search_data).and_return([{"id" => field_id}])
      allow(request).to receive(:get).with(field_id).and_return(response)

      expect(repository.where(fake_field: "fake value")).to eq([response])
    end

    it "searches by id" do
      id = 123

      allow(request).to receive(:get).with(id).and_return(:response)

      expect(repository.where(id: id)).to eq([:response])
    end

    it "returns an empty array when request was unsuccessful" do
      id = 123

      allow(request).to receive(:get).and_raise(Pipekit::ResourceNotFoundError.new(:response))

      expect(repository.where(id: id)).to eq([])
    end

    it "searches by id" do
      id = 123

      allow(request).to receive(:get).with(id).and_return(:response)

      expect(repository.where(id: id)).to eq([:response])
    end

    describe "find_by" do
      it "returns the first record matching given field" do
        data = {id: 123}
        allow(request).to receive(:get).with(data[:id]).and_return(:response)

        expect(repository.find_by(id: 123)).to eq(:response)
      end

      it "raises an error when resource not found" do
        resource_error = Pipekit::ResourceNotFoundError.new(:response)
        allow(request).to receive(:get).and_raise(resource_error)

        expect{repository.find_by(id: 123)}.to raise_error(resource_error)
      end
    end
  end


  describe "create" do
    it "creates a record in a repository" do
      fields = {foo: :bar}
      expect(request).to receive(:post).with(fields)
      repository.create(fields)
    end
  end

  describe "update" do
    it "updates a record in a repository" do
      id = 1
      fields = {foo: :bar}
      expect(request).to receive(:put).with(id, fields)
      repository.update(id, fields)
    end
  end
end
