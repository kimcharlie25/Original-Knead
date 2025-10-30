import React, { useState } from 'react';
import { Plus, Edit, Trash2, Save, X, ArrowLeft } from 'lucide-react';
import { useCookieFlavors, CookieFlavor } from '../hooks/useCookieFlavors';
import CookieFlavorImageUpload from './CookieFlavorImageUpload';

interface CookieFlavorManagerProps {
  onBack: () => void;
}

const CookieFlavorManager: React.FC<CookieFlavorManagerProps> = ({ onBack }) => {
  const { cookieFlavors, addCookieFlavor, updateCookieFlavor, deleteCookieFlavor } = useCookieFlavors();
  const [currentView, setCurrentView] = useState<'list' | 'add' | 'edit'>('list');
  const [editingFlavor, setEditingFlavor] = useState<CookieFlavor | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    image_url: '',
    sort_order: 0,
    active: true
  });

  const handleAddFlavor = () => {
    const nextSortOrder = Math.max(...cookieFlavors.map(c => c.sort_order), 0) + 1;
    setFormData({
      name: '',
      image_url: '',
      sort_order: nextSortOrder,
      active: true
    });
    setCurrentView('add');
  };

  const handleEditFlavor = (flavor: CookieFlavor) => {
    setEditingFlavor(flavor);
    setFormData({
      name: flavor.name,
      image_url: flavor.image_url || '',
      sort_order: flavor.sort_order,
      active: flavor.active
    });
    setCurrentView('edit');
  };

  const handleDeleteFlavor = async (id: string) => {
    if (confirm('Are you sure you want to delete this cookie flavor? This action cannot be undone.')) {
      try {
        await deleteCookieFlavor(id);
      } catch (error) {
        alert(error instanceof Error ? error.message : 'Failed to delete cookie flavor');
      }
    }
  };

  const handleSaveFlavor = async () => {
    if (!formData.name) {
      alert('Please fill in the cookie flavor name');
      return;
    }

    try {
      if (editingFlavor) {
        await updateCookieFlavor(editingFlavor.id, formData);
      } else {
        await addCookieFlavor(formData);
      }
      setCurrentView('list');
      setEditingFlavor(null);
    } catch (error) {
      alert(error instanceof Error ? error.message : 'Failed to save cookie flavor');
    }
  };

  const handleCancel = () => {
    setCurrentView('list');
    setEditingFlavor(null);
  };

  // Form View (Add/Edit)
  if (currentView === 'add' || currentView === 'edit') {
    return (
      <div className="min-h-screen bg-gray-50">
        <div className="bg-white shadow-sm border-b">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex items-center justify-between h-16">
              <div className="flex items-center space-x-4">
                <button
                  onClick={handleCancel}
                  className="flex items-center space-x-2 text-gray-600 hover:text-black transition-colors duration-200"
                >
                  <ArrowLeft className="h-5 w-5" />
                  <span>Back</span>
                </button>
                <h1 className="text-2xl font-more-sugar font-semibold text-black">
                  {currentView === 'add' ? 'Add Cookie Flavor' : 'Edit Cookie Flavor'}
                </h1>
              </div>
              <div className="flex space-x-3">
                <button
                  onClick={handleCancel}
                  className="px-4 py-2 border border-gray-300 rounded-lg hover:bg-gray-50 transition-colors duration-200 flex items-center space-x-2"
                >
                  <X className="h-4 w-4" />
                  <span>Cancel</span>
                </button>
                <button
                  onClick={handleSaveFlavor}
                  className="px-4 py-2 bg-cookie-primary text-white rounded-lg hover:bg-cookie-dark transition-colors duration-200 flex items-center space-x-2"
                >
                  <Save className="h-4 w-4" />
                  <span>Save</span>
                </button>
              </div>
            </div>
          </div>
        </div>

        <div className="max-w-2xl mx-auto px-4 py-8">
          <div className="bg-white rounded-xl shadow-sm p-8">
            <div className="space-y-6">
              <div>
                <label className="block text-sm font-medium text-black mb-2">Cookie Flavor Name *</label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cookie-secondary focus:border-transparent"
                  placeholder="e.g., Chocolate Chip Cookie"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-black mb-2">Sort Order</label>
                <input
                  type="number"
                  value={formData.sort_order}
                  onChange={(e) => setFormData({ ...formData, sort_order: parseInt(e.target.value) || 0 })}
                  className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-cookie-secondary focus:border-transparent"
                />
                <p className="text-xs text-gray-500 mt-1">Lower numbers appear first in the selection menu</p>
              </div>

              <div className="flex items-center">
                <label className="flex items-center space-x-2">
                  <input
                    type="checkbox"
                    checked={formData.active}
                    onChange={(e) => setFormData({ ...formData, active: e.target.checked })}
                    className="rounded border-gray-300 text-cookie-secondary focus:ring-cookie-secondary"
                  />
                  <span className="text-sm font-medium text-black">Active</span>
                </label>
              </div>

              <div>
                <label className="block text-sm font-medium text-black mb-2">Cookie Image</label>
                <CookieFlavorImageUpload
                  currentImage={formData.image_url}
                  onImageChange={(imageUrl) => setFormData({ ...formData, image_url: imageUrl })}
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // List View
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-4">
              <button
                onClick={onBack}
                className="flex items-center space-x-2 text-gray-600 hover:text-black transition-colors duration-200"
              >
                <ArrowLeft className="h-5 w-5" />
                <span>Dashboard</span>
              </button>
              <h1 className="text-2xl font-more-sugar font-semibold text-black">Cookie Flavors</h1>
            </div>
            <button
              onClick={handleAddFlavor}
              className="flex items-center space-x-2 bg-cookie-primary text-white px-4 py-2 rounded-lg hover:bg-cookie-dark transition-colors duration-200"
            >
              <Plus className="h-4 w-4" />
              <span>Add New</span>
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 py-8">
        <div className="bg-white rounded-xl shadow-sm overflow-hidden">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 p-6">
            {cookieFlavors.map((flavor) => (
              <div key={flavor.id} className="border border-gray-200 rounded-xl overflow-hidden hover:shadow-lg transition-shadow duration-200">
                <div className="relative h-48 bg-gradient-to-br from-gray-50 to-gray-100">
                  {flavor.image_url ? (
                    <img
                      src={flavor.image_url}
                      alt={flavor.name}
                      className="w-full h-full object-cover"
                    />
                  ) : (
                    <div className="w-full h-full flex items-center justify-center">
                      <div className="text-6xl opacity-20">🍪</div>
                    </div>
                  )}
                  {!flavor.active && (
                    <div className="absolute top-2 right-2 bg-red-500 text-white text-xs font-bold px-2 py-1 rounded-full">
                      Inactive
                    </div>
                  )}
                </div>
                <div className="p-4">
                  <h3 className="font-semibold text-black mb-2">{flavor.name}</h3>
                  <div className="flex items-center justify-between">
                    <span className="text-sm text-gray-500">Order: {flavor.sort_order}</span>
                    <div className="flex space-x-2">
                      <button
                        onClick={() => handleEditFlavor(flavor)}
                        className="p-2 text-gray-400 hover:text-cookie-secondary hover:bg-gray-100 rounded transition-colors duration-200"
                      >
                        <Edit className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => handleDeleteFlavor(flavor.id)}
                        className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded transition-colors duration-200"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

export default CookieFlavorManager;

