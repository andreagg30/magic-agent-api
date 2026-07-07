CREATE TABLE catalog (
    id SERIAL PRIMARY KEY,
    category_code TEXT NOT NULL,
    label TEXT NOT NULL,
    is_active BOOLEAN DEFAULT true,
    
    -- Evita que en la misma categoría haya dos nombres iguales
    UNIQUE(category_code, label) 
);

-- CREATE INDEX idx_catalog_category ON catalog(category_code);

-- Ejemplo de inserción:
-- INSERT INTO catalog (category_code, label,) VALUES ('user_type', 'User');