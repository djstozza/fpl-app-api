class BasePopulateService < ApplicationService
  private

  def bootstrap_static_url
    'https://fantasy.premierleague.com/api/bootstrap-static/'
  end

  def fixtures_url(round_external_id)
    base_url = 'https://fantasy.premierleague.com/api/fixtures/'
    round_external_id ? "#{base_url}?event=#{round_external_id}" : base_url
  end

  def player_summary_url(external_id)
    "https://fantasy.premierleague.com/api/element-summary/#{external_id}/"
  end
end
