CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  image TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT chk_courses_title_not_empty CHECK (char_length(TRIM(title)) > 0)
);

CREATE TABLE course_modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title VARCHAR(50) NOT NULL,
  position INTEGER NOT NULL DEFAULT 0,
  CONSTRAINT chk_course_modules_title_not_empty
    CHECK (char_length(TRIM(title)) > 0)
);

CREATE TABLE course_lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID NOT NULL REFERENCES course_modules(id) ON DELETE CASCADE,
  title VARCHAR(50) NOT NULL,
  description TEXT NOT NULL,
  type_id INTEGER REFERENCES catalog(id),
  lesson_index INTEGER,
  youtube_url TEXT,
  file_url TEXT,
  position INTEGER NOT NULL DEFAULT 0,
  CONSTRAINT chk_course_lessons_title_not_empty
    CHECK (char_length(TRIM(title)) > 0),
  CONSTRAINT chk_course_lessons_description_length
    CHECK (char_length(description) <= 400)
);

CREATE TABLE course_lesson_contents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES course_lessons(id) ON DELETE CASCADE,
  type_id INTEGER NOT NULL REFERENCES catalog(id),
  title VARCHAR(100),
  button_text VARCHAR(60),
  go_to TEXT,
  description TEXT,
  image TEXT,
  image_attributes JSONB,
  image_direction_id INTEGER REFERENCES catalog(id),
  content_index INTEGER NOT NULL,
  position INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE course_product_links (
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  position INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (course_id, product_id)
);

CREATE INDEX idx_course_modules_course_id ON course_modules(course_id);
CREATE INDEX idx_course_lessons_module_id ON course_lessons(module_id);
CREATE INDEX idx_course_lessons_type_id ON course_lessons(type_id);
CREATE INDEX idx_course_lesson_contents_lesson_id
ON course_lesson_contents(lesson_id);
CREATE INDEX idx_course_product_links_product_id
ON course_product_links(product_id);

CREATE TRIGGER trg_courses_updated_at
BEFORE UPDATE ON courses
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
