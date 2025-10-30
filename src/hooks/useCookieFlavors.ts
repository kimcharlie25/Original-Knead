import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';

export interface CookieFlavor {
  id: string;
  name: string;
  image_url: string | null;
  active: boolean;
  sort_order: number;
  created_at: string;
  updated_at: string;
}

export const useCookieFlavors = () => {
  const [cookieFlavors, setCookieFlavors] = useState<CookieFlavor[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchCookieFlavors = async () => {
    try {
      setLoading(true);
      
      const { data, error: fetchError } = await supabase
        .from('cookie_flavors')
        .select('*')
        .order('sort_order', { ascending: true });

      if (fetchError) throw fetchError;

      setCookieFlavors(data || []);
      setError(null);
    } catch (err) {
      console.error('Error fetching cookie flavors:', err);
      setError(err instanceof Error ? err.message : 'Failed to fetch cookie flavors');
    } finally {
      setLoading(false);
    }
  };

  const addCookieFlavor = async (flavor: Omit<CookieFlavor, 'id' | 'created_at' | 'updated_at'>) => {
    try {
      const { data, error: insertError } = await supabase
        .from('cookie_flavors')
        .insert({
          name: flavor.name,
          image_url: flavor.image_url || null,
          active: flavor.active,
          sort_order: flavor.sort_order
        })
        .select()
        .single();

      if (insertError) throw insertError;

      await fetchCookieFlavors();
      return data;
    } catch (err) {
      console.error('Error adding cookie flavor:', err);
      throw err;
    }
  };

  const updateCookieFlavor = async (id: string, updates: Partial<CookieFlavor>) => {
    try {
      const { error: updateError } = await supabase
        .from('cookie_flavors')
        .update({
          name: updates.name,
          image_url: updates.image_url || null,
          active: updates.active,
          sort_order: updates.sort_order
        })
        .eq('id', id);

      if (updateError) throw updateError;

      await fetchCookieFlavors();
    } catch (err) {
      console.error('Error updating cookie flavor:', err);
      throw err;
    }
  };

  const deleteCookieFlavor = async (id: string) => {
    try {
      const { error: deleteError } = await supabase
        .from('cookie_flavors')
        .delete()
        .eq('id', id);

      if (deleteError) throw deleteError;

      await fetchCookieFlavors();
    } catch (err) {
      console.error('Error deleting cookie flavor:', err);
      throw err;
    }
  };

  useEffect(() => {
    fetchCookieFlavors();
  }, []);

  return {
    cookieFlavors,
    loading,
    error,
    addCookieFlavor,
    updateCookieFlavor,
    deleteCookieFlavor,
    refetch: fetchCookieFlavors
  };
};

