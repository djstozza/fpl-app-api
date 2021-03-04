class BasePopulateService < ApplicationService
  private

  def bootstrap_static_url
    'https://fantasy.premierleague.com/api/bootstrap-static/'
  end

  def fixtures_url
    'https://fantasy.premierleague.com/api/fixtures/'
  end

  def player_summary_url(external_id)
    "https://fantasy.premierleague.com/api/element-summary/#{external_id}/"
  end
end
