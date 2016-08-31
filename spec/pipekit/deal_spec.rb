module Pipekit
  RSpec.describe Deal do
    let(:uri) { "deals" }

    it_behaves_like "a repository"

    describe "Finding deals" do
      it "finds deals by person id" do
        person = instance_spy("Pipekit::Person")
        person_id = 1456
        repository = described_class.new

        repository.get_by_person_id(person_id, person_repo: person)

        expect(person).to have_received(:find_deals).with(person_id)
      end

      it "errors if no ID is supplied" do
        repository = described_class.new
        expect{ repository.get_by_person_id(nil) }.to raise_error(UnknownPersonError)
      end

    end

    it "updates a deal based on a person's email supplied" do
      person = instance_spy("Pipekit::Person")
      request = instance_spy("Pipekit::Request")

      params = { title: "Deal title" }
      email = "test@example.com"
      person_id = 123
      deal_id = 456

      allow(person).to receive(:find_by).with(email: email).and_return(id: person_id)
      allow(person).to receive(:find_deals).with(person_id).and_return([{id: deal_id}])

      repository = described_class.new(request)
      repository.update_by_person(email, params, person_repo: person)

      expect(request).to have_received(:put).with(deal_id, params)
    end
  end
end
