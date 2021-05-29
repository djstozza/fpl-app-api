class Leagues::Update < Leagues::BaseService
  validate :user_is_owner
  validate :valid_league
end
