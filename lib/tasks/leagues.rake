namespace :leagues do
  desc "reset counter_cache for fpl_teams in existing leagues"
  
  task reset_fpl_teams_counter_cache: :environment do
    League.find_each { |league| League.reset_counters(league.id, :fpl_teams) }
  end
end