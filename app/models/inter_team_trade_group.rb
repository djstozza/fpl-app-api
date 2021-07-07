# == Schema Information
#
# Table name: inter_team_trade_groups
#
#  id                   :bigint           not null, primary key
#  status               :integer          default("pending"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  in_fpl_team_list_id  :bigint
#  out_fpl_team_list_id :bigint
#
# Indexes
#
#  index_inter_team_trade_groups_on_in_fpl_team_list_id   (in_fpl_team_list_id)
#  index_inter_team_trade_groups_on_out_fpl_team_list_id  (out_fpl_team_list_id)
#
# Foreign Keys
#
#  fk_rails_...  (in_fpl_team_list_id => fpl_team_lists.id)
#  fk_rails_...  (out_fpl_team_list_id => fpl_team_lists.id)
#
class InterTeamTradeGroup < ApplicationRecord
  belongs_to :out_fpl_team_list, class_name: 'FplTeamList', foreign_key: :out_fpl_team_list_id
  belongs_to :in_fpl_team_list, class_name: 'FplTeamList', foreign_key: :in_fpl_team_list_id

  has_many :inter_team_trades, dependent: :destroy
  has_many :in_players, class_name: 'Player', foreign_key: :in_player_id, through: :inter_team_trades
  has_many :out_players, class_name: 'Player', foreign_key: :out_player_id, through: :inter_team_trades

  delegate :fpl_team, to: :in_fpl_team_list, prefix: :in
  delegate :fpl_team, to: :out_fpl_team_list, prefix: :out
  delegate :league, :owner, to: :out_fpl_team
  delegate :round, to: :out_fpl_team_list

  enum status: { pending: 0, submitted: 1, approved: 2, declined: 3, expired: 4, cancelled: 5 }
end
