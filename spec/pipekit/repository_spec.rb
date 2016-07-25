require 'spec_helper'
require 'pipekit/repository'

module Pipekit
  RSpec.describe Repository do
    module FakeMethods
      def get_by_fake_field(value)
        nil
      end
    end

    subject(:repository) { described_class.new(uri, FakeMethods, client) }
    let(:client) { double("Pipedrive::Client") }
    let(:uri) { "tests"}

    describe "#all" do
      it "returns all records from the repository" do
        expect(client).to receive(:get).with("/#{uri}")
        repository.all
      end
    end

    describe "#where" do
      it "returns records matching given field" do
        expect(repository).to receive(:get_by_fake_field).with("fake value")
        repository.where(fake_field: "fake value")
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
        expect(client).to receive(:post).with("/#{uri}", fields)
        repository.create(fields)
      end
    end

    describe "update" do
      it "updates a record in a repository" do
        id = 1
        fields = {foo: :bar}
        expect(client).to receive(:put).with("/#{uri}/#{id}", fields)
        repository.update(id, fields)
      end
    end
  end
end
