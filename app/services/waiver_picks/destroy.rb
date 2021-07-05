class WaiverPicks::Destroy < WaiverPicks::BaseService
  attr_reader :fpl_team_list, :waiver_pick, :user

  validate :user_can_waiver_pick
  validate :waiver_pick_is_pending

  def initialize(waiver_pick, user)
    @waiver_pick = waiver_pick
    @fpl_team_list = waiver_pick.fpl_team_list
    @user = user
  end

  def call
    return unless valid?

    waiver_picks = fpl_team_list.waiver_picks.includes(:out_player, :in_player)

    waiver_pick.destroy

    waiver_picks.where('pick_number > ?', waiver_pick.pick_number).order(:pick_number).each do |waiver_pick|
      waiver_pick.update(pick_number: waiver_pick.pick_number - 1)
      errors.merge!(waiver_pick.errors)
    end
  end
end
