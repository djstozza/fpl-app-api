require 'support/api_helpers/not_found_helper'
require 'support/api_helpers/test_client'

module APIHelpers

  def api
    @api ||= TestClient.new(self)
  end

end

RSpec.configure do |config|
  config.include APIHelpers, type: :request
end
