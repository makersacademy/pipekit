module Pipekit
  RSpec.describe Person do

    subject(:repository) { described_class.new(request) }
    let(:request) { instance_spy("Pipedrive::Request") }
    let(:uri) { "persons" }

    it_behaves_like "a repository"

    describe "create or update" do

      it "creates a person when they don't yet exist on Pipedrive" do
        allow(request).to receive(:get).and_raise(ResourceNotFoundError.new(:resource))

        fields = {
          email: "test@example.com",
          name: "Testy McTest"
        }

        repository.create_or_update(fields)
        expect(request).to have_received(:post).with(fields)
      end

      it "updates a person on Pipedrive when they already exist" do
        id = 123
        fields = {
          email: "test@example.com",
          name: "Testy McTest"
        }

        allow(request).to receive(:get).with("find", term: fields[:email], search_by_email: 1).and_return([{"id" => id}])

        repository.create_or_update(fields)
        expect(request).to have_received(:put).with(id, fields)
      end
    end

    describe "finding a person by specific fields" do
      it "gets by email" do
        email = "test@example.com"

        repository.get_by_email(email)

        expect(request).to have_received(:get).with("find", term: email, search_by_email: 1)
      end

      it "gets by name" do
        name = "Dave Smith"

        repository.get_by_name(name)

        expect(request).to have_received(:get).with("find", term: name)
      end
    end
  end
end
