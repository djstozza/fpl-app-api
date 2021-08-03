class InterTeamTradeGroups::Cancel < InterTeamTradeGroups::BaseService
  validate :user_can_trade
  validate :still_active?

  def initialize(inter_team_trade_group, user)
    @inter_team_trade_group = inter_team_trade_group
    @out_fpl_team_list = inter_team_trade_group.out_fpl_team_list
    @in_fpl_team_list = inter_team_trade_group.in_fpl_team_list
    @user = user
  end

  def call
    return unless valid?

    inter_team_trade_group.update(status: 'cancelled')
    errors.merge!(inter_team_trade_group.errors)
  end

  private

  def still_active?
    return if inter_team_trade_group.submitted? || inter_team_trade_group.pending?

    errors.add(:base, 'You cannot cancel this trade proposal, as it has already been processed')
  end
end
