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
#  first_name                   :string
#  form                         :decimal(, )
#  goals_conceded               :integer
#  goals_scored                 :integer
#  history                      :jsonb
#  history_past                 :jsonb
#  ict_index                    :decimal(, )
#  in_dreamteam                 :boolean
#  influence                    :decimal(, )
#  last_name                    :string
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
#  index_players_on_id_and_first_name    (id,first_name)
#  index_players_on_id_and_goals_scored  (id,goals_scored)
#  index_players_on_id_and_last_name     (id,last_name)
#  index_players_on_id_and_total_points  (id,total_points)
#  index_players_on_position_id          (position_id)
#  index_players_on_team_id              (team_id)
#
FactoryBot.define do
  factory :player do
    sequence :external_id do |n|
      n
    end

    sequence :first_name do |n|
      "First Name #{n}"
    end

    sequence :last_name do |n|
      "Last Name #{n}"
    end

    association :team
    association :position, :forward

    history { [] }
    history_past { [] }


    trait :with_history do
      history {
        fixture ||= create :fixture
        [
          {
            'element' => external_id,
            'fixture' => fixture.external_id,
            'opponent_team' => fixture.team_a_id,
            'total_points' => 7,
            'was_home' => false,
            'kickoff_time' => fixture.kickoff_time,
            'team_h_score' => fixture.team_h_score,
            'team_a_score' => fixture.team_a_score,
            'round' => fixture.round.external_id,
            'minutes' => fixture.minutes,
            'goals_scored' => 1,
            'assists' => 0,
            'clean_sheets' => 1,
            'goals_conceded' => 0,
            'own_goals' => 0,
            'penalties_saved' => 0,
            'penalties_missed' => 0,
            'yellow_cards' => 1,
            'red_cards' => 0,
            'saves' => 0,
            'bonus' => 0,
            'bps' => 19,
            'influence' => '36.6',
            'creativity' => '15.3',
            'threat' => '54.0',
            'ict_index' => '10.6',
            'value' => 120,
            'transfers_balance' => 0,
            'selected' => 2823465,
            'transfers_in' => 0,
            'transfers_out' => 0
          }
        ]
      }
    end

    trait :forward do
      association :position, :forward
    end

    trait :defender do
      association :position, :defender
    end

    trait :midfielder do
      association :position, :midfielder
    end

    trait :goalkeeper do
      association :position, :goalkeeper
    end
  end
end
