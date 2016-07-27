#require "shoulda/matchers/independent/delegate_method_matcher"
require "shoulda/matchers"

RSpec.describe Pipekit::Client do
  it { should delegate_method }
end
