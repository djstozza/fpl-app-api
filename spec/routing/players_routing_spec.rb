require 'rails_helper'

RSpec.describe Api::PlayersController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/api/players').to route_to('api/players#index')
    end

    it 'routes to #show' do
      expect(get: '/api/players/1').to route_to('api/players#show', id: '1')
    end
  end
end
