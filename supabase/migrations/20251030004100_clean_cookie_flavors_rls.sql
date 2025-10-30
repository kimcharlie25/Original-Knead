/*
  # Clean Cookie Flavors RLS Policies
  
  Drop ALL existing policies and recreate with proper public access
  This ensures no conflicting policies exist.
*/

-- Drop all existing policies for cookie_flavors
DROP POLICY IF EXISTS "Anyone can read active cookie flavors" ON cookie_flavors;
DROP POLICY IF EXISTS "Public can read all cookie flavors" ON cookie_flavors;
DROP POLICY IF EXISTS "Authenticated users can manage cookie flavors" ON cookie_flavors;
DROP POLICY IF EXISTS "Public can insert cookie flavors" ON cookie_flavors;
DROP POLICY IF EXISTS "Public can update cookie flavors" ON cookie_flavors;
DROP POLICY IF EXISTS "Public can delete cookie flavors" ON cookie_flavors;

-- Recreate all policies fresh
CREATE POLICY "Public can read all cookie flavors"
  ON cookie_flavors
  FOR SELECT
  TO public
  USING (true);

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

