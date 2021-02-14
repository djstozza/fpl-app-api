require "rails_helper"

RSpec.describe Api::PositionsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/api/positions").to route_to("api/positions#index")
    end
  end
end
