WITH filtered_draft_picks AS (:filtered_draft_picks)

SELECT
*
FROM filtered_draft_picks
OFFSET :offset
LIMIT :limit
