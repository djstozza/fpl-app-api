class BasePopulateService < ApplicationService
  private

  def bootstrap_static_url
    @bootstrap_static_url ||= 'https://fantasy.premierleague.com/api/bootstrap-static/'
  end
end
