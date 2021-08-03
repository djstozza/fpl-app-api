class WaiverPicks::Destroy < WaiverPicks::BaseService
  attr_reader :fpl_team_list, :waiver_pick, :waiver_picks, :user

  validate :user_can_waiver_pick
  validate :waiver_pick_pending?

  def initialize(waiver_pick, user)
    @waiver_pick = waiver_pick
    @fpl_team_list = waiver_pick.fpl_team_list
    @waiver_picks = fpl_team_list.waiver_picks.includes(:out_player, :in_player)
    @user = user
  end

  def call
    return unless valid?

    waiver_pick.destroy

    update_waiver_pick_order
  end

  private

  def update_waiver_pick_order
    waiver_picks.where('pick_number > ?', waiver_pick.pick_number).order(:pick_number).each do |waiver_pick|
      waiver_pick.update(pick_number: waiver_pick.pick_number - 1)
      errors.merge!(waiver_pick.errors)
    end
  end
end
