/*
  # Cookie Flavors Management Table
  
  - Create cookie_flavors table for managing bundle selection options
  - Allows admin to add/remove/edit cookie flavors with images
  - Auto-generated UUID IDs
*/

-- Create cookie_flavors table
CREATE TABLE IF NOT EXISTS cookie_flavors (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  image_url text,
  active boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE cookie_flavors ENABLE ROW LEVEL SECURITY;

-- Policies for public read access (only active flavors, but admin can see all)
CREATE POLICY "Anyone can read active cookie flavors"
  ON cookie_flavors
  FOR SELECT
  TO public
  USING (active = true);
  
CREATE POLICY "Public can read all cookie flavors"
  ON cookie_flavors
  FOR SELECT
  TO public
  USING (true);

-- Policies for authenticated admin access
CREATE POLICY "Authenticated users can manage cookie flavors"
  ON cookie_flavors
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create updated_at trigger for cookie_flavors
CREATE TRIGGER update_cookie_flavors_updated_at
  BEFORE UPDATE ON cookie_flavors
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Insert default cookie flavors (if they don't exist)
INSERT INTO cookie_flavors (name, image_url, active, sort_order) VALUES
  ('Original chocolate chip', NULL, true, 1),
  ('Double chocolate', NULL, true, 2),
  ('Red velvet cream cheese', NULL, true, 3),
  ('Carrot cream cheese', NULL, true, 4),
  ('Oatmeal trail mix', NULL, true, 5)
ON CONFLICT (name) DO NOTHING;

-- Create storage bucket for cookie flavor images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'cookie-flavor-images',
  'cookie-flavor-images',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
) ON CONFLICT (id) DO NOTHING;

-- Allow public read access to cookie flavor images
CREATE POLICY "Public read access for cookie flavor images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'cookie-flavor-images');

-- Allow public to upload cookie flavor images
CREATE POLICY "Public can upload cookie flavor images"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'cookie-flavor-images');

-- Allow authenticated users to upload cookie flavor images
CREATE POLICY "Authenticated users can upload cookie flavor images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'cookie-flavor-images');

-- Allow public to update cookie flavor images
CREATE POLICY "Public can update cookie flavor images"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'cookie-flavor-images');

-- Allow public to delete cookie flavor images
CREATE POLICY "Public can delete cookie flavor images"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'cookie-flavor-images');

-- Allow authenticated users to update cookie flavor images
CREATE POLICY "Authenticated users can update cookie flavor images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'cookie-flavor-images');

-- Allow authenticated users to delete cookie flavor images
CREATE POLICY "Authenticated users can delete cookie flavor images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'cookie-flavor-images');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_cookie_flavors_active ON cookie_flavors(active);
CREATE INDEX IF NOT EXISTS idx_cookie_flavors_sort ON cookie_flavors(sort_order);

