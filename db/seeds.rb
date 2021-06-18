# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Positions::Populate.call
Rounds::Populate.call
Teams::Populate.call
Players::Populate.call
Fixtures::Populate.call
Teams::ProcessStats.call
Players::PopulateSummaries.call

League::MIN_FPL_TEAM_QUOTA.times do |i|
  j = i + 1
  user = User.find_or_initialize_by(
    username: "user #{j}",
    email: "user#{j}@example.com",
  )

  user.password = ENV['DEFAULT_PASSWORD']
  user.save!
end

league = League.find_or_initialize_by(
  name: 'League 1'
)
league.owner = User.first
league.code = ENV['DEFAULT_PASSWORD']
league.save!

League::MIN_FPL_TEAM_QUOTA.times do |i|
  j = i + 1

  fpl_team = FplTeam.find_or_initialize_by(
    name: "Fpl Team #{j}",
    league: League.first,
  )

  fpl_team.owner = User.all[i]
  fpl_team.save!
end
