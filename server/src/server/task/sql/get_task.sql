SELECT
  id,
  title,
  description,
  completed,
  created_at,
  updated_at
FROM task
WHERE id = $1
