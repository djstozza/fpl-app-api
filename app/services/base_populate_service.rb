class BasePopulateService < ApplicationService
  MAX_RETRIES = 3
  DEFAULT_RETRY_AFTER = 5

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

  # The FPL API has no published rate limit, but will start returning 429s if
  # hit too hard. Back off and retry, honouring Retry-After when it's given.
  def fpl_get(url, retries: MAX_RETRIES)
    response = ::HTTParty.get(url)

    if response.code == 429 && retries.positive?
      sleep(retry_after(response))
      return fpl_get(url, retries: retries - 1)
    end

    response
  end

  def retry_after(response)
    (response.headers['Retry-After'].presence || DEFAULT_RETRY_AFTER).to_i
  end
end
