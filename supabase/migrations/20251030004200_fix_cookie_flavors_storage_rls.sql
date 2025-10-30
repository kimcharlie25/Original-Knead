/*
  # Fix Cookie Flavor Storage RLS Policies
  
  Drop and recreate storage policies for cookie-flavor-images bucket
  to ensure public upload access.
*/

-- Drop all existing storage policies for cookie-flavor-images
DROP POLICY IF EXISTS "Public read access for cookie flavor images" ON storage.objects;
DROP POLICY IF EXISTS "Public can upload cookie flavor images" ON storage.objects;
DROP POLICY IF EXISTS "Public can update cookie flavor images" ON storage.objects;
DROP POLICY IF EXISTS "Public can delete cookie flavor images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload cookie flavor images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update cookie flavor images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete cookie flavor images" ON storage.objects;

-- Recreate storage policies with public access
CREATE POLICY "Public read access for cookie flavor images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'cookie-flavor-images');

CREATE POLICY "Public can upload cookie flavor images"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'cookie-flavor-images');

CREATE POLICY "Public can update cookie flavor images"
ON storage.objects
FOR UPDATE
TO public
USING (bucket_id = 'cookie-flavor-images');

CREATE POLICY "Public can delete cookie flavor images"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'cookie-flavor-images');

