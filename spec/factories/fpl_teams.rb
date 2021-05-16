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
#  index_fpl_teams_on_league_id  (league_id)
#  index_fpl_teams_on_owner_id   (owner_id)
#
FactoryBot.define do
  factory :fpl_team do
    sequence :name do |n|
      "Fpl Team #{n}"
    end

    association :owner, factory: :user
    association :league
  end
end
