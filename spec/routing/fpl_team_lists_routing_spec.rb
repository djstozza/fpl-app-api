require 'rails_helper'

RSpec.describe Api::FplTeams::FplTeamListsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: 'api/fpl_teams/1/fpl_team_lists').to route_to('api/fpl_teams/fpl_team_lists#index', fpl_team_id: '1')
    end

    it 'routes to #show' do
      expect(get: 'api/fpl_teams/1/fpl_team_lists/1')
        .to route_to('api/fpl_teams/fpl_team_lists#show', fpl_team_id: '1', id: '1')
    end


    it 'routes to #create' do
      expect(post: 'api/fpl_teams/1/fpl_team_lists')
        .not_to route_to('api/fpl_teams/fpl_team_lists#create', fpl_team_id: '1')
    end

    it 'routes to #update via PUT' do
      expect(put: 'api/fpl_teams/1/fpl_team_lists/1')
        .not_to route_to('api/fpl_teams/fpl_team_lists#update', fpl_team_id: '1', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: 'api/fpl_teams/1/fpl_team_lists/1')
        .not_to route_to('api/fpl_teams/fpl_team_lists#update', fpl_team_id: '1', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: 'api/fpl_teams/1/fpl_team_lists/1')
        .not_to route_to('api/fpl_teams/fpl_team_lists#destroy', fpl_team_id: '1', id: '1')
    end
  end
end
