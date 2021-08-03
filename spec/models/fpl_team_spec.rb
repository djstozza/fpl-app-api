# == Schema Information
#
# Table name: fpl_teams
#
#  id                     :bigint           not null, primary key
#  draft_pick_number      :integer
#  mini_draft_pick_number :integer
#  name                   :string           not null
#  rank                   :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  league_id              :bigint
#  owner_id               :bigint
#
# Indexes
#
#  index_fpl_teams_on_draft_pick_number_and_league_id       (draft_pick_number,league_id) UNIQUE
#  index_fpl_teams_on_league_id                             (league_id)
#  index_fpl_teams_on_mini_draft_pick_number_and_league_id  (mini_draft_pick_number,league_id) UNIQUE
#  index_fpl_teams_on_name                                  (name) UNIQUE
#  index_fpl_teams_on_owner_id                              (owner_id)
#
require 'rails_helper'

RSpec.describe FplTeam, type: :model do
  it 'has a valid factory' do
    expect(build(:fpl_team)).to be_valid
  end

  it 'validates name uniqueness' do
    fpl_team = create(:fpl_team)

    expect { create(:fpl_team, name: fpl_team.name.upcase) }
      .to raise_error(ActiveRecord::RecordInvalid, /Name has already been taken/)
  end
end
