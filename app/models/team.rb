# == Schema Information
#
# Table name: teams
#
#  id                    :bigint           not null, primary key
#  clean_sheets          :integer
#  code                  :integer
#  draws                 :integer
#  form                  :jsonb
#  goal_difference       :integer
#  goals_against         :integer
#  goals_for             :integer
#  losses                :integer
#  name                  :citext
#  played                :integer
#  points                :integer
#  position              :integer
#  short_name            :citext
#  strength              :integer
#  strength_attack_away  :integer
#  strength_attack_home  :integer
#  strength_defence_away :integer
#  strength_defence_home :integer
#  strength_overall_away :integer
#  strength_overall_home :integer
#  wins                  :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  external_id           :integer
#
# Indexes
#
#  index_teams_on_external_id  (external_id) UNIQUE
#
class Team < ApplicationRecord
  has_many :home_fixtures, class_name: 'Fixture', foreign_key: :team_h_id
  has_many :away_fixtures, class_name: 'Fixture', foreign_key: :team_a_id
  has_many :players

  validates :external_id, presence: true, uniqueness: true
end
