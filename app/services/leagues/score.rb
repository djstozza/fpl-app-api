class Leagues::Score < ApplicationService
  attr_reader :league, :fpl_teams

  def initialize(league)
    @league = league
    @fpl_teams = league.fpl_teams
  end

  def call
    return unless round

    score_fpl_team_lists
    rank_fpl_team_lists
    rank_fpl_teams
  end

  private

  def round
    @round ||= Round.find_by(is_current: true)
  end

  def league_fpl_team_lists
    @league_fpl_team_lists ||= league.fpl_team_lists.where(round: round)
  end

  def score_fpl_team_lists
    league_fpl_team_lists.each { |fpl_team_list| FplTeamLists::Score.new(fpl_team_list).call }
  end

  def fpl_team_list_scores
    league_fpl_team_lists.order(total_score: :desc).pluck(:total_score)
  end

  def rank_fpl_team_lists
    league_fpl_team_lists.each do |fpl_team_list|
      fpl_team_list.update!(round_rank: fpl_team_list_scores.index(fpl_team_list.total_score) + 1)
    end
  end

  def fpl_team_scores_arr
    @fpl_team_scores_arr ||=
      fpl_teams
      .joins(:fpl_team_lists)
      .group(:fpl_team_id)
      .order('SUM(fpl_team_lists.total_score) DESC')
      .pluck('SUM(fpl_team_lists.total_score)')
  end

  def rank_fpl_teams
    fpl_teams.each do |fpl_team|
      total = fpl_team.fpl_team_lists.sum(&:total_score)

      fpl_team.update!(rank: fpl_team_scores_arr.index(total) + 1)
    end
  end
end
