require 'rails_helper'

RSpec.describe Api::RoundsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/rounds').to route_to('api/rounds#index')
    end

    it 'routes to #show' do
      expect(get: '/api/rounds/1').to route_to('api/rounds#show', id: '1')
    end
  end
end
