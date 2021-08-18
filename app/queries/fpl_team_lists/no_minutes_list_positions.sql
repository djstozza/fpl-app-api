WITH list_positions AS (:list_positions),

/*
  Need to check if the player has two fixtures in the round i.e. may not have played in the first but might still play
  in the second so don't allow a premature substitution
*/
counted_list_positions AS (
  SELECT
  id
  FROM list_positions
  WHERE finished = FALSE OR minutes IS NOT NULL
)

SELECT
COALESCE(
  ARRAY_AGG(
    id
    ORDER BY kickoff_time ASC
  ), '{}'
) AS ids
FROM list_positions
WHERE id NOT IN (SELECT id FROM counted_list_positions)
  AND minutes IS NULL
  AND finished = TRUE
  AND role = 0 -- Must be starting
