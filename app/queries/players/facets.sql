SELECT
JSONB_AGG(
  DISTINCT
  JSONB_BUILD_OBJECT(
  	'label', teams.short_name,
  	'value', team_id::TEXT
  )
) AS teams,
JSONB_AGG(
  DISTINCT
  JSONB_BUILD_OBJECT(
  	'label', positions.singular_name_short,
  	'value', position_id::TEXT
  )
) AS positions,
JSONB_AGG(
  DISTINCT
  JSONB_BUILD_OBJECT(
  	'label',
  	CASE
    WHEN in_dreamteam
      THEN 'Yes'
      ELSE 'No'
    END,
    'value',
    in_dreamteam
  )
) AS in_dreamteam,
JSONB_AGG(
  DISTINCT
  JSONB_BUILD_OBJECT(
  	'label', COALESCE(chance_of_playing_next_round, 0) || '%',
  	'value', COALESCE(chance_of_playing_next_round, 0)
  )
) AS chance_of_playing_next_round,
JSONB_AGG(
  DISTINCT
  JSONB_BUILD_OBJECT(
  	'label', COALESCE(chance_of_playing_this_round, 0) || '%',
  	'value', COALESCE(chance_of_playing_this_round, 0)
  )
) AS chance_of_playing_this_round,
JSONB_AGG(
  DISTINCT
  JSONB_BUILD_OBJECT(
  	'label',
  	CASE
	  WHEN status = 'a'
	    THEN 'Available'
	  WHEN status = 'd'
	    THEN 'Doubtful'
	  WHEN status = 'i'
	    THEN 'Injured'
	  WHEN status = 'n'
	    THEN 'On Loan'
	  WHEN status = 's'
	    THEN 'Suspended'
	  WHEN status = 'u'
	  	THEN 'Unavailable'
  	END,
  	'value',
  	status
  )
) AS statuses
FROM players
JOIN teams ON teams.id = players.team_id
JOIN positions ON positions.id = players.position_id
