class Leagues::Create < Leagues::BaseService
  validate :valid_league
  validate :valid_fpl_team
end
