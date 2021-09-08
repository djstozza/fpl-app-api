require 'rails_helper'

RSpec.describe MiniDraftPicks::BroadcastJob do
  it 'broadcasts player picks to the league' do
    mini_draft_pick = create(:mini_draft_pick)
    out_player = mini_draft_pick.out_player
    in_player = mini_draft_pick.in_player
    user = mini_draft_pick.owner

    expect { described_class.perform_now(mini_draft_pick) }
      .to have_broadcasted_to("league_#{mini_draft_pick.league_id}_mini_draft_picks").with(
        updatedAt: mini_draft_pick.updated_at.to_i,
        message: "#{user.username} has traded out #{out_player&.name} (#{out_player&.team&.short_name}) for " \
          "#{in_player&.name} #{in_player&.team&.short_name}"
      )
  end

  it 'broadcasts mini draft picks to the league' do
    mini_draft_pick = create(:mini_draft_pick, :passed)
    user = mini_draft_pick.owner

    expect { described_class.perform_now(mini_draft_pick) }
      .to have_broadcasted_to("league_#{mini_draft_pick.league_id}_mini_draft_picks").with(
        updatedAt: mini_draft_pick.updated_at.to_i,
        message: "#{user.username} has passed"
      )
  end
end
