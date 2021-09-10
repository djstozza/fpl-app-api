# == Schema Information
#
# Table name: players
#
#  id                           :bigint           not null, primary key
#  assists                      :integer
#  bonus                        :integer
#  bps                          :integer
#  chance_of_playing_next_round :integer
#  chance_of_playing_this_round :integer
#  clean_sheets                 :integer
#  code                         :integer
#  creativity                   :decimal(, )
#  dreamteam_count              :integer
#  event_points                 :integer
#  first_name                   :citext
#  form                         :decimal(, )
#  goals_conceded               :integer
#  goals_scored                 :integer
#  history                      :jsonb
#  history_past                 :jsonb
#  ict_index                    :decimal(, )
#  in_dreamteam                 :boolean
#  influence                    :decimal(, )
#  last_name                    :citext
#  minutes                      :integer
#  news                         :string
#  news_added                   :datetime
#  own_goals                    :integer
#  penalties_missed             :integer
#  penalties_saved              :integer
#  photo                        :string
#  points_per_game              :decimal(, )
#  red_cards                    :integer
#  saves                        :integer
#  selected_by_percent          :decimal(, )
#  special                      :boolean
#  status                       :string
#  threat                       :decimal(, )
#  total_points                 :integer
#  yellow_cards                 :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  external_id                  :integer
#  position_id                  :bigint
#  team_id                      :bigint
#
# Indexes
#
#  index_players_on_external_id          (external_id) UNIQUE
#  index_players_on_id_and_first_name    (id,first_name)
#  index_players_on_id_and_goals_scored  (id,goals_scored)
#  index_players_on_id_and_last_name     (id,last_name)
#  index_players_on_id_and_total_points  (id,total_points)
#  index_players_on_position_id          (position_id)
#  index_players_on_team_id              (team_id)
#
require 'rails_helper'

RSpec.describe PlayerSerializer, type: :serializer do
  let!(:player) { create :player }

  describe '.has_history' do
    it 'returns true if the history attribute count is > 0' do
      player.update(history: [instance_double('history')])

      expect(described_class.new(player, history: true).as_json).to include(has_history: true)
    end

    it 'returns true if the history attribute count is 0' do
      expect(described_class.new(player, history: true).as_json).to include(has_history: false)
    end
  end

  describe '.has_history_past' do
    it 'returns true if the history attribute count is > 0' do
      player.update(history_past: [instance_double('history_past')])

      expect(described_class.new(player, history_past: true).as_json).to include(has_history_past: true)
    end

    it 'returns true if the history attribute count is 0' do
      expect(described_class.new(player, history_past: true).as_json).to include(has_history_past: false)
    end
  end
end
