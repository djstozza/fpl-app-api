# == Schema Information
#
# Table name: draft_picks
#
#  id          :bigint           not null, primary key
#  mini_draft  :boolean          default(FALSE), not null
#  pick_number :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  fpl_team_id :bigint
#  league_id   :bigint
#  player_id   :bigint
#
# Indexes
#
#  index_draft_picks_on_fpl_team_id                (fpl_team_id)
#  index_draft_picks_on_league_id                  (league_id)
#  index_draft_picks_on_pick_number_and_league_id  (pick_number,league_id) UNIQUE
#  index_draft_picks_on_player_id                  (player_id)
#  index_draft_picks_on_player_id_and_league_id    (player_id,league_id) UNIQUE
#
FactoryBot.define do
  factory :draft_pick do
    sequence :pick_number do |n|
      n
    end

    association :player
    association :fpl_team
    league { fpl_team.league }

    trait :mini_draft do
      mini_draft { true }
      player { nil }
    end

    trait :initialized do
      player { nil }
    end
  end
end
