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
class Player < ApplicationRecord
  validates :external_id, presence: true, uniqueness: true

  belongs_to :team
  belongs_to :position

  delegate :singular_name_short, to: :position

  scope :forwards, -> { joins(:position).where('positions.singular_name_short = ?', 'FWD') }
  scope :midfielders, -> { joins(:position).where('positions.singular_name_short = ?', 'MID') }
  scope :defenders, -> { joins(:position).where('positions.singular_name_short = ?', 'DEF') }
  scope :goalkeepers, -> { joins(:position).where('positions.singular_name_short = ?', 'GKP') }
  scope :outfielders, -> { joins(:position).where('positions.singular_name_short != ?', 'GKP') }

  def goalkeeper?
    position.singular_name_short.casecmp('gkp').zero?
  end

  def name
    "#{first_name} #{last_name}"
  end
end
