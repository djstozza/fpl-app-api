require 'rails_helper'

RSpec.describe DraftPicks::BroadcastJob do
  it 'broadcasts player picks to the league' do
    draft_pick = create(:draft_pick)
    player = draft_pick.player
    user = draft_pick.owner

    expect { described_class.perform_now(draft_pick, player, false) }
      .to have_broadcasted_to("league_#{draft_pick.league_id}_draft_picks").with(
        updatedAt: draft_pick.updated_at.to_i,
        message: "#{user.username} has drafted #{player.name} (#{player.team.short_name})"
      )
  end

  it 'broadcasts mini draft picks to the league' do
    draft_pick = create(:draft_pick, :mini_draft)
    user = draft_pick.owner

    expect { described_class.perform_now(draft_pick, nil, true) }
      .to have_broadcasted_to("league_#{draft_pick.league_id}_draft_picks").with(
        updatedAt: draft_pick.updated_at.to_i,
        message: "#{user.username} has made a mini draft pick"
      )
  end
end
