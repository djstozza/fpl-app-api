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
#  index_players_on_position_id  (position_id)
#  index_players_on_team_id      (team_id)
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
    association :position

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
