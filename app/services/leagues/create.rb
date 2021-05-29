# Create a league and the owner's fpl_team
class Leagues::Create < Leagues::BaseService
  validate :valid_league
  validate :valid_fpl_team
end
