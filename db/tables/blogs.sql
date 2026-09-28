CREATE TABLE blogs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(100) NOT NULL,
  short_description VARCHAR(300),
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT chk_blogs_title_not_empty CHECK (char_length(TRIM(title)) > 0)
);

CREATE TABLE blog_contents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blog_id UUID NOT NULL REFERENCES blogs(id) ON DELETE CASCADE,
  type_id INTEGER NOT NULL REFERENCES catalog(id),
  description VARCHAR(3000),
  image TEXT,
  image_attributes JSONB,
  image_direction_id INTEGER REFERENCES catalog(id),
  content_index INTEGER NOT NULL,
  position INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE blog_category_links (
  blog_id UUID NOT NULL REFERENCES blogs(id) ON DELETE CASCADE,
  category_id INTEGER NOT NULL REFERENCES term_categories(id) ON DELETE CASCADE,
  position INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (blog_id, category_id)
);

CREATE INDEX idx_blog_contents_blog_id ON blog_contents(blog_id);
CREATE INDEX idx_blog_contents_type_id ON blog_contents(type_id);
CREATE INDEX idx_blog_contents_image_direction_id
ON blog_contents(image_direction_id);
CREATE INDEX idx_blog_category_links_category_id
ON blog_category_links(category_id);

CREATE TRIGGER trg_blogs_updated_at
BEFORE UPDATE ON blogs
FOR EACH ROW
EXECUTE FUNCTION set_updated_at();
