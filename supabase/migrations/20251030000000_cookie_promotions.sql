/*
  # Cookie Promotions and Items Seed

  - Ensure `cookies` category exists
  - Create `promotions` table (auto-generated uuid ids)
  - Insert sweet deals promotions
  - Insert cookie flavors as menu_items (id auto-generated)
*/

-- Ensure cookies category exists
INSERT INTO categories (id, name, icon, sort_order, active)
VALUES ('cookies', 'Cookies', '🍪', 1, true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  icon = EXCLUDED.icon,
  sort_order = EXCLUDED.sort_order,
  active = EXCLUDED.active;

-- Create promotions table
CREATE TABLE IF NOT EXISTS promotions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  quantity integer NOT NULL DEFAULT 0,
  free_quantity integer NOT NULL DEFAULT 0,
  price decimal(10,2) NOT NULL,
  active boolean NOT NULL DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS and policies to mirror other public tables
ALTER TABLE promotions ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'promotions' AND policyname = 'Anyone can read promotions'
  ) THEN
    CREATE POLICY "Anyone can read promotions"
      ON promotions
      FOR SELECT
      TO public
      USING (active = true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'promotions' AND policyname = 'Authenticated users can manage promotions'
  ) THEN
    CREATE POLICY "Authenticated users can manage promotions"
      ON promotions
      FOR ALL
      TO authenticated
      USING (true)
      WITH CHECK (true);
  END IF;
END $$;

-- Insert sweet deals (avoid duplicates by price/quantities)
INSERT INTO promotions (title, description, quantity, free_quantity, price, active)
SELECT 'Sweet deals fresh from our oven! 🍪', 'Buy 3, get 1 FREE — ₱285', 3, 1, 285.00, true
WHERE NOT EXISTS (
  SELECT 1 FROM promotions WHERE quantity = 3 AND free_quantity = 1 AND price = 285.00
);

INSERT INTO promotions (title, description, quantity, free_quantity, price, active)
SELECT 'Sweet deals fresh from our oven! 🍪', 'Buy 5, get 1 FREE — ₱475', 5, 1, 475.00, true
WHERE NOT EXISTS (
  SELECT 1 FROM promotions WHERE quantity = 5 AND free_quantity = 1 AND price = 475.00
);

INSERT INTO promotions (title, description, quantity, free_quantity, price, active)
SELECT 'Sweet deals fresh from our oven! 🍪', 'Buy 10, get 1 FREE — ₱950', 10, 1, 950.00, true
WHERE NOT EXISTS (
  SELECT 1 FROM promotions WHERE quantity = 10 AND free_quantity = 1 AND price = 950.00
);

-- Seed cookie flavors as menu items under 'cookies' category (id auto-generated)
-- Uses base_price = 0.00 as a placeholder; update actual pricing in admin
WITH to_insert(name) AS (
  VALUES
    ('oatmeal trail mix'),
    ('red velvet cream cheese'),
    ('double chocolate'),
    ('carrot cream cheese'),
    ('original chocolate chip')
)
INSERT INTO menu_items (name, description, base_price, category, popular, image_url, available)
SELECT 
  ti.name,
  'Freshly baked cookie',
  0.00,
  'cookies',
  false,
  NULL,
  true
FROM to_insert ti
WHERE NOT EXISTS (
  SELECT 1 FROM menu_items mi WHERE lower(mi.name) = lower(ti.name)
);

-- Optional: mark some as popular
UPDATE menu_items SET popular = true
WHERE name IN ('original chocolate chip', 'red velvet cream cheese');

-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_promotions_active ON promotions(active);

