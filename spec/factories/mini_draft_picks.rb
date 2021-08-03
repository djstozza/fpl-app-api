# == Schema Information
#
# Table name: mini_draft_picks
#
#  id            :bigint           not null, primary key
#  passed        :boolean          default(FALSE), not null
#  pick_number   :integer
#  season        :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  fpl_team_id   :bigint
#  in_player_id  :bigint
#  league_id     :bigint
#  out_player_id :bigint
#
# Indexes
#
#  index_mini_draft_picks_on_fpl_team_id                           (fpl_team_id)
#  index_mini_draft_picks_on_in_player_id                          (in_player_id)
#  index_mini_draft_picks_on_league_id                             (league_id)
#  index_mini_draft_picks_on_out_player_id                         (out_player_id)
#  index_mini_draft_picks_on_pick_number_and_league_id_and_season  (pick_number,league_id,season) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (in_player_id => players.id)
#  fk_rails_...  (out_player_id => players.id)
#
FactoryBot.define do
  factory :mini_draft_pick do
    sequence :pick_number do |n|
      n
    end

    association :fpl_team
    association :out_player, factory: :player
    association :in_player, factory: :player
    league { fpl_team.league }

    season { 'summer' }

    trait :summer do
      season { 'summer' }
    end

    trait :winter do
      season { 'winter' }
    end

    trait :passed do
      out_player { nil }
      in_player { nil }
      passed { true }
    end
  end
end
