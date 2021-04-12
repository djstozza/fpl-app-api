require 'rails_helper'

RSpec.describe 'api/players/facets', :no_transaction, type: :request do
  let(:team1) { create :team }
  let(:team2) { create :team }

  let!(:player1) do
    create(
      :player,
      :forward,
      team: team1,
      status: 'a',
      chance_of_playing_next_round: 100,
      in_dreamteam: true,
    )
  end
  let!(:player2) do
    create(
      :player,
      :defender,
      team: team1,
      status: 'u',
      in_dreamteam: false,
    )
  end
  let!(:player3) do
    create(
      :player,
      :goalkeeper,
      team: team2,
      status: 'i',
      in_dreamteam: true,
    )
  end
  let!(:player3) do
    create(
      :player,
      :midfielder,
      team: team2,
      status: 'd',
      chance_of_playing_this_round: 25,
      in_dreamteam: false,
    )
  end

  it 'returns a list of player facets' do
    api.get(api_players_facets_path)

    expect(api.data).to match(
      'teams' => [
        { 'label' => team1.short_name, 'value' => team1.to_param },
        { 'label' => team2.short_name, 'value' => team2.to_param },
      ],
      'positions' => [
        { 'label' => 'DEF', 'value' => player2.position.to_param },
        { 'label' => 'FWD', 'value' => player1.position.to_param },
        { 'label' => 'MID', 'value' => player3.position.to_param },
      ],
      'in_dreamteam' => [
        { 'label' => 'No', 'value' => false },
        { 'label' => 'Yes', 'value' => true },
      ],
      'chance_of_playing_next_round' => [
        { 'label' => '0%', 'value' => 0 },
        { 'label' => '100%', 'value' => 100 },
      ],
      'chance_of_playing_this_round' => [
        { 'label' => '0%', 'value' => 0 },
        { 'label' => '25%', 'value' => 25 },
      ],
      'statuses' => [
        { 'label' => 'Available', 'value' => 'a' },
        { 'label' => 'Unavailable', 'value' => 'u' },
        { 'label' => 'doubtful', 'value' => 'd' },
      ],
    )
  end
end
