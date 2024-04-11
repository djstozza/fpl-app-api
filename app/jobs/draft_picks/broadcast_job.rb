# Broadcast successful draft picks
class DraftPicks::BroadcastJob < ApplicationJob
  def perform(draft_pick, player, mini_draft)
    user = draft_pick.owner

    player_substr = "has drafted #{player&.name} (#{player&.team&.short_name})"
    mini_draft_substr = 'has made a mini draft pick'

    success_str = "#{user.username} #{mini_draft ? mini_draft_substr : player_substr}"

    ActionCable
      .server
      .broadcast(
        "league_#{draft_pick.league_id}_draft_picks",
        {
          updatedAt: draft_pick.reload.updated_at.to_i,
          message: success_str,
        },
      )
  end
end
