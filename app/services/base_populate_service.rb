class BasePopulateService < ApplicationService
  private

  def bootstrap_static_url
    'https://fantasy.premierleague.com/api/bootstrap-static/'
  end

  def fixtures_url
    'https://fantasy.premierleague.com/api/fixtures/'
  end
end
