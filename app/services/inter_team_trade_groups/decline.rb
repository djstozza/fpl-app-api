class InterTeamTradeGroups::Decline < InterTeamTradeGroups::BaseService
  validate :user_can_approve
  validate :submitted?

  def initialize(inter_team_trade_group, user)
    @inter_team_trade_group = inter_team_trade_group
    @out_fpl_team_list = inter_team_trade_group.out_fpl_team_list
    @in_fpl_team_list = inter_team_trade_group.in_fpl_team_list
    @user = user
  end

  def call
    return unless valid?

    inter_team_trade_group.update(status: 'declined')
    errors.merge!(inter_team_trade_group.errors)
  end

  private

  def submitted?
    return if inter_team_trade_group.submitted?

    errors.add(:base, 'You can only decline submitted trade proposals')
  end
end
