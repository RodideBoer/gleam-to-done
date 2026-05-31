INSERT INTO task (title, description, completed)
VALUES ($1, $2, $3)
RETURNING
  id,
  title,
  description,
  completed,
  created_at,
  updated_at
