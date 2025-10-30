/*
  # Fix Cookie Flavors RLS - Add Public Policies
  
  This migration adds public INSERT, UPDATE, and DELETE policies for cookie_flavors
  to match the pattern used for menu_images storage bucket.
*/

-- Add public write policies for cookie_flavors (check for existing policies first)
DO $$
BEGIN
  -- Drop all existing policies
  DROP POLICY IF EXISTS "Anyone can read active cookie flavors" ON cookie_flavors;
  DROP POLICY IF EXISTS "Public can read all cookie flavors" ON cookie_flavors;
  DROP POLICY IF EXISTS "Authenticated users can manage cookie flavors" ON cookie_flavors;

  -- Add public read policy
  CREATE POLICY "Public can read all cookie flavors"
    ON cookie_flavors
    FOR SELECT
    TO public
    USING (true);

  -- Add public write policies
  CREATE POLICY "Public can insert cookie flavors"
    ON cookie_flavors
    FOR INSERT
    TO public
    WITH CHECK (true);

  CREATE POLICY "Public can update cookie flavors"
    ON cookie_flavors
    FOR UPDATE
    TO public
    USING (true)
    WITH CHECK (true);

  CREATE POLICY "Public can delete cookie flavors"
    ON cookie_flavors
    FOR DELETE
    TO public
    USING (true);
END $$;

