WITH stat_object AS (
  SELECT
  fixtures.id AS fixture_id,
  JSONB_BUILD_OBJECT(
    'identifier', stats.identifier,
    'home', COALESCE(
      JSONB_AGG(
        DISTINCT
        JSONB_BUILD_OBJECT(
         'value', home.value,
         'player', JSONB_BUILD_OBJECT(
           'id', home_player.id::TEXT,
           'name', home_player.last_name
          )
        )
      ) FILTER (WHERE home.value IS NOT NULL), '[]'
    ),
    'away', COALESCE(
      JSONB_AGG(
        DISTINCT
        JSONB_BUILD_OBJECT(
         'value', away.value,
         'player',
          JSONB_BUILD_OBJECT(
           'id', away_player.id::TEXT,
           'name', away_player.last_name
          )
        )
      ) FILTER (WHERE away.value IS NOT NULL), '[]'
    )
  ) AS stat
  FROM rounds
  JOIN fixtures ON fixtures.round_id = rounds.id
  LEFT JOIN LATERAL JSONB_TO_RECORDSET(fixtures.stats) stats(identifier TEXT, a JSONB, h JSONB)
    ON stats.identifier NOT IN :unneded_identifiers
  LEFT JOIN LATERAL JSONB_TO_RECORDSET(stats.h) home(value INTEGER, element INTEGER) ON TRUE
  LEFT JOIN LATERAL JSONB_TO_RECORDSET(stats.a) away(value INTEGER, element INTEGER) ON TRUE
  LEFT JOIN players home_player
    ON home.element = home_player.external_id
  LEFT JOIN players away_player
    ON away.element = away_player.external_id
  WHERE rounds.id = :round_id
  GROUP BY
  rounds.id,
  fixtures.id,
  stats.identifier
)

SELECT
fixtures.id::TEXT,
fixtures.kickoff_time,
fixtures.minutes,
fixtures.started,
fixtures.finished,
fixtures.team_a_score AS away_team_score,
fixtures.team_h_score AS home_team_score,
JSONB_BUILD_OBJECT(
  'id', home_team.id::TEXT,
  'name', home_team.name
) AS home_team,
JSON_BUILD_OBJECT(
  'id', away_team.id::TEXT,
  'name', away_team.name
) AS away_team,
COALESCE(JSONB_AGG(stat) FILTER (WHERE stat ->> 'identifier' IS NOT NULL), '[]') AS stats
FROM fixtures
JOIN stat_object ON fixtures.id = fixture_id
JOIN teams home_team ON home_team.id = fixtures.team_h_id
JOIN teams away_team ON away_team.id = fixtures.team_a_id
GROUP BY
fixtures.id,
home_team.id,
away_team.id
