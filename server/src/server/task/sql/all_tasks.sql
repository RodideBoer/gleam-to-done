SELECT
  id,
  title,
  description,
  completed,
  created_at,
  updated_at
FROM task
ORDER BY created_at DESC, id DESC