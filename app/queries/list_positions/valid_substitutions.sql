WITH out_list_position AS (
  SELECT
  list_positions.id,
  list_positions.role,
  fpl_team_list_id,
  singular_name_short
  FROM list_positions
  JOIN players ON list_positions.player_id = players.id
  JOIN positions ON players.position_id = positions.id
  WHERE list_positions.id = :list_position_id
),

in_list_positions AS (
  SELECT
  fpl_team_list_id,
  list_positions.id,
  positions.singular_name_short,
  positions.id AS position_id,
  list_positions.role
  FROM list_positions
  JOIN players ON list_positions.player_id = players.id
  JOIN positions ON players.position_id = positions.id
  LEFT OUTER JOIN out_list_position USING(fpl_team_list_id)
  WHERE list_positions.id != out_list_position.id
    AND (
      CASE
        /*
          If the out list position is a starting one (role = 0) and the player is not a goalkeeper, return all the list
          positions that are substitutes but not substitute goalkeepers i.e. substitute_1, substitute_2, substitute_3
        */
        WHEN out_list_position.role = 0 AND out_list_position.singular_name_short != 'GKP'
          THEN list_positions.role != 0 AND list_positions.role != 4
        /*
          If the out list position is a starting one (role = 0) and the player is a goalkeeper, return all the
          substitute_gkp list position (role = 4)
        */
        WHEN out_list_position.role = 0 AND out_list_position.singular_name_short = 'GKP' THEN list_positions.role = 4
        -- If the out list position is a substitute goalkeeper (role = 4), return the starting goalkeeper
        WHEN out_list_position.role = 4 THEN positions.singular_name_short = 'GKP' AND list_positions.role = 0
        /*
          This will return all starting players (role = 0) who are not goalkeepers if the out list position player is a
          non-goalkeeper substitute i.e. role = 1 (substitute_1), role = 2 (substitute_2), role = 3 (substitute_3)
        */
        ELSE list_positions.role = 0 AND positions.singular_name_short != 'GKP'
      END
    )
)

SELECT
in_list_positions.id::TEXT
FROM list_positions
LEFT OUTER JOIN out_list_position USING (fpl_team_list_id)
LEFT JOIN in_list_positions USING (fpl_team_list_id)
JOIN players ON list_positions.player_id = players.id
JOIN positions ON players.position_id = positions.id
WHERE fpl_team_list_id = out_list_position.fpl_team_list_id
  AND (list_positions.role = 0 OR list_positions.id = in_list_positions.id)
  AND list_positions.id != out_list_position.id
GROUP BY in_list_positions.id, out_list_position.singular_name_short, in_list_positions.singular_name_short
/*
  There must always be a minimum of 3 starting defenders, 2 starting midfielders and 1 starting forward.
  This check removes invalid substitutions i.e. subbing out a starting defender for a substitute midfielder when there
  are only 3 starting defenders would be invalid
*/
HAVING (
  CASE
    WHEN out_list_position.singular_name_short != 'DEF' AND in_list_positions.singular_name_short = 'DEF'
      THEN COUNT(CASE WHEN positions.singular_name_short = 'DEF' THEN 1 END) - 1
    ELSE COUNT(CASE WHEN positions.singular_name_short = 'DEF' THEN 1 END)
  END >= 3
) AND (
  CASE
    WHEN out_list_position.singular_name_short != 'MID' AND in_list_positions.singular_name_short = 'MID'
      THEN COUNT(CASE WHEN positions.singular_name_short = 'DEF' THEN 1 END) - 1
    ELSE COUNT(CASE WHEN positions.singular_name_short = 'DEF' THEN 1 END)
  END >= 2
) AND (
  CASE
    WHEN out_list_position.singular_name_short != 'FWD' AND in_list_positions.singular_name_short = 'FWD'
      THEN COUNT(CASE WHEN positions.singular_name_short = 'FWD' THEN 1 END) - 1
    ELSE COUNT(CASE WHEN positions.singular_name_short = 'FWD' THEN 1 END)
  END > 0
)
