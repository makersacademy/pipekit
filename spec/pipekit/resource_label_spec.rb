module Pipekit
  RSpec.describe ResourceLabel do

    describe "contains" do
      it "a singular resource label" do
        singular = "activity"
        pluralized = "activities"
        resource_label = described_class.new(singular_label: singular, pluralized_label: pluralized)
        expect(resource_label.singular).to eq(singular)
      end

      it "a pluralised resource label" do
        singular = "activity"
        pluralized = "activities"
        resource_label = described_class.new(singular_label: singular, pluralized_label: pluralized)
        expect(resource_label.pluralized).to eq(pluralized)
      end
    end

  end
end
