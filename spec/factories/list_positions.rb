# == Schema Information
#
# Table name: list_positions
#
#  id               :bigint           not null, primary key
#  role             :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  fpl_team_list_id :bigint
#  player_id        :bigint
#
# Indexes
#
#  index_list_positions_on_fpl_team_list_id                (fpl_team_list_id)
#  index_list_positions_on_player_id                       (player_id)
#  index_list_positions_on_player_id_and_fpl_team_list_id  (player_id,fpl_team_list_id) UNIQUE
#
FactoryBot.define do
  factory :list_position do
    association :fpl_team_list, factory: :fpl_team_list
    association :player

    role { 'starting' }

    trait :starting do
      role { 'starting' }
    end

    trait :substitute_1 do
      role { 'substitute_1' }
    end

    trait :substitute_2 do
      role { 'substitute_2' }
    end

    trait :substitute_3 do
      role { 'substitute_3' }
    end

    trait :substitute_gkp do
      role { 'substitute_gkp' }
      association :player, :goalkeeper
    end

    trait :forward do
      association :player, :forward
    end

    trait :midfielder do
      association :player, :midfielder
    end

    trait :defender do
      association :player, :defender
    end

    trait :goalkeeper do
      association :player, :goalkeeper
    end
  end
end
