# Broadcast successful mini draft picks
class MiniDraftPicks::BroadcastJob < ApplicationJob
  def perform(mini_draft_pick)
    user = mini_draft_pick.owner

    success_str = "#{user.username} #{mini_draft_pick.passed ? 'has passed' : player_substr(mini_draft_pick)}"

    ActionCable
      .server
      .broadcast(
        "league_#{mini_draft_pick.league_id}_mini_draft_picks",
        {
          updatedAt: mini_draft_pick.updated_at.to_i,
          message: success_str,
        },
      )
  end

  private

  def player_substr(mini_draft_pick)
    in_player = mini_draft_pick.in_player
    out_player = mini_draft_pick.out_player

    "has traded out #{out_player&.name} (#{out_player&.team&.short_name}) for " \
      "#{in_player&.name} (#{in_player&.team&.short_name})"
  end
end
