# == Schema Information
#
# Table name: trades
#
#  id               :bigint           not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  fpl_team_list_id :bigint
#  in_player_id     :bigint
#  out_player_id    :bigint
#
# Indexes
#
#  index_trades_on_fpl_team_list_id  (fpl_team_list_id)
#  index_trades_on_in_player_id      (in_player_id)
#  index_trades_on_out_player_id     (out_player_id)
#
# Foreign Keys
#
#  fk_rails_...  (in_player_id => players.id)
#  fk_rails_...  (out_player_id => players.id)
#
FactoryBot.define do
  factory :trade do
    association :fpl_team_list
    association :out_player, factory: :player
    association :in_player, factory: :player
  end
end
