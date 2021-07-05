require 'rails_helper'

RSpec.describe Api::FplTeamLists::WaiverPicksController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: 'api/fpl_team_lists/1/waiver_picks')
        .to route_to('api/fpl_team_lists/waiver_picks#index', fpl_team_list_id: '1')
    end

    it 'routes to #show' do
      expect(get: 'api/fpl_team_lists/1/waiver_picks/1')
        .not_to route_to('api/fpl_team_lists/waiver_picks#show', fpl_team_list_id: '1', id: '1')
    end


    it 'routes to #create' do
      expect(post: 'api/fpl_team_lists/1/waiver_picks')
        .to route_to('api/fpl_team_lists/waiver_picks#create', fpl_team_list_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: 'api/fpl_team_lists/1/waiver_picks/1')
        .not_to route_to('api/fpl_team_lists/waiver_picks#update', fpl_team_list_id: '1', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: 'api/fpl_team_lists/1/waiver_picks/1')
        .not_to route_to('api/fpl_team_lists/waiver_picks#update', fpl_team_list_id: '1', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: 'api/fpl_team_lists/1/waiver_picks/1')
        .to route_to('api/fpl_team_lists/waiver_picks#destroy', fpl_team_list_id: '1', id: '1')
    end
  end
end
