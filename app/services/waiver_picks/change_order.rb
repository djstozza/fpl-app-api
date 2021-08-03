class WaiverPicks::ChangeOrder < WaiverPicks::BaseService
  attr_reader :fpl_team_list, :waiver_pick, :original_pick_number, :user, :new_pick_number

  validate :user_can_waiver_pick
  validate :waiver_pick_pending?
  validate :valid_pick_number
  validate :change_in_pick_number

  def initialize(data, waiver_pick, user)
    @new_pick_number = data[:new_pick_number].to_i
    @fpl_team_list = waiver_pick.fpl_team_list
    @waiver_pick = waiver_pick
    @original_pick_number = waiver_pick.pick_number
    @user = user
  end

  def call
    return unless valid?

    waiver_pick.update(pick_number: 0)

    if original_pick_number > new_pick_number
      reorder_higher_pick_numbers
    elsif original_pick_number <= new_pick_number
      reorder_lower_pick_numbers
    end

    waiver_pick.update(pick_number: new_pick_number)
    errors.merge!(waiver_pick.errors)
  end

  private

  def valid_pick_number
    return if fpl_team_list.waiver_picks.find_by(pick_number: new_pick_number)

    errors.add(:base, 'Pick number is invalid')
  end

  def change_in_pick_number
    return if waiver_pick.pick_number != new_pick_number

    errors.add(:base, 'No change in pick number')
  end

  def waiver_picks
    fpl_team_list.waiver_picks.includes(:out_player, :in_player)
  end

  def reorder_higher_pick_numbers
    waiver_picks.where(
      'pick_number >= :new_pick_number AND pick_number <= :old_pick_number',
      new_pick_number: new_pick_number,
      old_pick_number: original_pick_number,
    ).order(pick_number: :desc).each do |pick|
      pick.update(pick_number: pick.pick_number + 1)
      errors.merge!(pick.errors)
    end
  end

  def reorder_lower_pick_numbers
    waiver_picks.where(
      'pick_number <= :new_pick_number AND pick_number >= :old_pick_number',
      new_pick_number: new_pick_number,
      old_pick_number: original_pick_number,
    ).order(:pick_number).each do |pick|
      pick.update(pick_number: pick.pick_number - 1)
      errors.merge!(pick.errors)
    end
  end
end
