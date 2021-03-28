class RoundDetailQuery
  UNNEEDED_IDENTIFIERS = %w[bps].freeze

  def initialize(round)
    @round = round
  end

  def as_json(*)
    serializable_round.merge(
      fixtures: fixtures,
    )
  end

  def updated_at
    @updated_at ||= SqlQuery.run('round_detail_query/cache', round_id: round.id).first[:updated_at]
  end

  def cache_key
    updated_at
  end

  private

  attr_reader :round

  def serializable_round
    {
      id: round.to_param,
      name: round.name,
      is_current: round.is_current,
      is_next: round.is_next,
      is_previous: round.is_previous,
      finished: round.finished,
      data_checked: round.data_checked,
      deadline_time: round.deadline_time,
    }
  end

  def fixtures
    SqlQuery.results(
      'round_detail_query/fixtures',
      round_id: round.id,
      unneeded_identifiers: UNNEEDED_IDENTIFIERS,
    )
  end
end
