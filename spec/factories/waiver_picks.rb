# == Schema Information
#
# Table name: waiver_picks
#
#  id               :bigint           not null, primary key
#  pick_number      :integer          not null
#  status           :integer          default("pending"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  fpl_team_list_id :bigint
#  in_player_id     :bigint
#  out_player_id    :bigint
#
# Indexes
#
#  index_waiver_picks_on_fpl_team_list_id  (fpl_team_list_id)
#  index_waiver_picks_on_in_player_id      (in_player_id)
#  index_waiver_picks_on_out_player_id     (out_player_id)
#
# Foreign Keys
#
#  fk_rails_...  (in_player_id => players.id)
#  fk_rails_...  (out_player_id => players.id)
#
FactoryBot.define do
  factory :waiver_pick do
    sequence :pick_number do |n|
      n
    end

    status { 'pending' }
    association :out_player, factory: :player
    association :in_player, factory: :player
    association :fpl_team_list

    trait :pending do
      status { 'pending' }
    end

    trait :approved do
      status { 'approved' }
    end

    trait :declined do
      status { 'declined' }
    end

    trait :cancelled do
      status { 'cancelled' }
    end
  end
end
