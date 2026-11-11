CREATE TABLE IF NOT EXISTS course_user_progress (
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  lesson_id UUID NOT NULL REFERENCES course_lessons(id) ON DELETE CASCADE,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, course_id, lesson_id)
);
CREATE INDEX IF NOT EXISTS idx_course_user_progress_lesson ON course_user_progress(lesson_id);
CREATE INDEX IF NOT EXISTS idx_course_user_progress_course ON course_user_progress(course_id);
