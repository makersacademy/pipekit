module Pipekit
  RSpec.describe User do

    subject(:repository) { described_class.new(request) }
    let(:request) { instance_spy("Pipedrive::Request") }

    it_behaves_like "a repository"

    describe "finding a person by specific fields" do
      it "gets by email" do
        email = "test@example.com"

        repository.find_by_email(email)

        expect(request).to have_received(:get).with("find", term: email, search_by_email: 1)
      end

      it "gets by name" do
        name = "Dave Smith"

        repository.find_by_name(name)

        expect(request).to have_received(:get).with("find", term: name)
      end
    end
  end
end
