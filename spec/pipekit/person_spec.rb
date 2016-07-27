require "spec_helper"

RSpec.describe Pipekit::Person do

  subject(:repository) { described_class.new(request) }
  let(:request) { instance_spy("Pipedrive::Request") }

  it_behaves_like "a repository"

  describe "finding a person by specific fields" do
    it "gets by email" do
      email = "test@example.com"

      repository.get_by_email(email)

      expect(request).to have_received(:get).with("/#{repository.uri}/find", term: email, search_by_email: 1)
    end

    it "gets by name" do
      name = "Dave Smith"

      repository.get_by_name(name)

      expect(request).to have_received(:get).with("/#{repository.uri}/find", term: name)
    end
  end
end
