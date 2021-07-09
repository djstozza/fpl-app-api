# == Schema Information
#
# Table name: inter_team_trades
#
#  id                        :bigint           not null, primary key
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  in_player_id              :bigint
#  inter_team_trade_group_id :bigint
#  out_player_id             :bigint
#
# Indexes
#
#  index_inter_team_trades_on_in_player_id               (in_player_id)
#  index_inter_team_trades_on_inter_team_trade_group_id  (inter_team_trade_group_id)
#  index_inter_team_trades_on_out_player_id              (out_player_id)
#
# Foreign Keys
#
#  fk_rails_...  (in_player_id => players.id)
#  fk_rails_...  (out_player_id => players.id)
#
require 'rails_helper'

RSpec.describe InterTeamTrade, type: :model do
  it ('has a valid factory') do
    expect(build :inter_team_trade).to be_valid
  end
end
