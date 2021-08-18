WITH list_positions AS (:list_positions)

SELECT
id
FROM list_positions
WHERE id IN :valid_substitutions
  AND (finished = FALSE OR (finished = TRUE AND minutes IS NOT NULL))
ORDER BY role ASC
LIMIT 1
