import React, { useState, useEffect, useMemo } from 'react';
import { Input } from '../Input';
import { Button } from '../Button';
import { Card } from '../Card';
import { Badge } from '../Badge';
import { formatBalance } from '../../utils/format-balance';
import { formatDate } from '../../utils/format-date';
import { formatAddress } from '../../utils/format-address';

interface SearchableVault {
  id: number;
  name: string;
  description: string;
  owner: string;
  balance: bigint;
  goalAmount: bigint;
  unlockTimestamp: number;
  createdAt: number;
  category: string;
  tags: string[];
  isPublic: boolean;
  collaborators: number;
  successRate: number;
  yieldRate: number;
  riskLevel: 'low' | 'medium' | 'high';
  status: 'active' | 'completed' | 'locked' | 'expired';
}

interface SearchFilters {
  query: string;
  category: string;
  status: string;
  riskLevel: string;
  balanceRange: { min: string; max: string };
  yieldRange: { min: string; max: string };
  dateRange: { start: string; end: string };
  tags: string[];
  isPublic: boolean | null;
  hasCollaborators: boolean | null;
  sortBy: 'relevance' | 'balance' | 'yield' | 'created' | 'success';
  sortOrder: 'asc' | 'desc';
}

interface VaultDiscoveryProps {
  vaults: SearchableVault[];
  onVaultSelect: (vault: SearchableVault) => void;
  className?: string;
}

export function VaultDiscovery({ vaults, onVaultSelect, className = '' }: VaultDiscoveryProps) {
  const [filters, setFilters] = useState<SearchFilters>({
    query: '',
    category: 'all',
    status: 'all',
    riskLevel: 'all',
    balanceRange: { min: '', max: '' },
    yieldRange: { min: '', max: '' },
    dateRange: { start: '', end: '' },
    tags: [],
    isPublic: null,
    hasCollaborators: null,
    sortBy: 'relevance',
    sortOrder: 'desc'
  });

  const [searchSuggestions, setSearchSuggestions] = useState<string[]>([]);
  const [showAdvancedFilters, setShowAdvancedFilters] = useState(false);
  const [savedSearches, setSavedSearches] = useState<Array<{ name: string; filters: SearchFilters }>>([]);

  // Extract all available tags and categories
  const availableTags = useMemo(() => {
    const tagSet = new Set<string>();
    vaults.forEach(vault => {
      vault.tags.forEach(tag => tagSet.add(tag));
    });
    return Array.from(tagSet).sort();
  }, [vaults]);

  const availableCategories = useMemo(() => {
    const categorySet = new Set<string>();
    vaults.forEach(vault => {
      categorySet.add(vault.category);
    });
    return Array.from(categorySet).sort();
  }, [vaults]);

  // Generate search suggestions based on query
  useEffect(() => {
    if (filters.query.length < 2) {
      setSearchSuggestions([]);
      return;
    }

    const suggestions = new Set<string>();
    const query = filters.query.toLowerCase();

    vaults.forEach(vault => {
      // Add matching vault names
      if (vault.name.toLowerCase().includes(query)) {
        suggestions.add(vault.name);
      }
      
      // Add matching tags
      vault.tags.forEach(tag => {
        if (tag.toLowerCase().includes(query)) {
          suggestions.add(tag);
        }
      });
      
      // Add matching categories
      if (vault.category.toLowerCase().includes(query)) {
        suggestions.add(vault.category);
      }
    });

    setSearchSuggestions(Array.from(suggestions).slice(0, 5));
  }, [filters.query, vaults]);

  // Filter and sort vaults
  const filteredVaults = useMemo(() => {
    let filtered = vaults.filter(vault => {
      // Text search
      if (filters.query) {
        const query = filters.query.toLowerCase();
        const matchesText = 
          vault.name.toLowerCase().includes(query) ||
          vault.description.toLowerCase().includes(query) ||
          vault.tags.some(tag => tag.toLowerCase().includes(query)) ||
          vault.category.toLowerCase().includes(query) ||
          vault.owner.toLowerCase().includes(query);
        
        if (!matchesText) return false;
      }

      // Category filter
      if (filters.category !== 'all' && vault.category !== filters.category) {
        return false;
      }

      // Status filter
      if (filters.status !== 'all' && vault.status !== filters.status) {
        return false;
      }

      // Risk level filter
      if (filters.riskLevel !== 'all' && vault.riskLevel !== filters.riskLevel) {
        return false;
      }

      // Balance range filter
      if (filters.balanceRange.min) {
        const minBalance = BigInt(Math.floor(parseFloat(filters.balanceRange.min) * 1e18));
        if (vault.balance < minBalance) return false;
      }
      if (filters.balanceRange.max) {
        const maxBalance = BigInt(Math.floor(parseFloat(filters.balanceRange.max) * 1e18));
        if (vault.balance > maxBalance) return false;
      }

      // Yield range filter
      if (filters.yieldRange.min && vault.yieldRate < parseFloat(filters.yieldRange.min)) {
        return false;
      }
      if (filters.yieldRange.max && vault.yieldRate > parseFloat(filters.yieldRange.max)) {
        return false;
      }

      // Date range filter
      if (filters.dateRange.start) {
        const startDate = new Date(filters.dateRange.start).getTime();
        if (vault.createdAt < startDate) return false;
      }
      if (filters.dateRange.end) {
        const endDate = new Date(filters.dateRange.end).getTime();
        if (vault.createdAt > endDate) return false;
      }

      // Tags filter
      if (filters.tags.length > 0) {
        const hasAllTags = filters.tags.every(tag => vault.tags.includes(tag));
        if (!hasAllTags) return false;
      }

      // Public filter
      if (filters.isPublic !== null && vault.isPublic !== filters.isPublic) {
        return false;
      }

      // Collaborators filter
      if (filters.hasCollaborators !== null) {
        const hasCollaborators = vault.collaborators > 0;
        if (hasCollaborators !== filters.hasCollaborators) return false;
      }

      return true;
    });

    // Sort results
    filtered.sort((a, b) => {
      let comparison = 0;

      switch (filters.sortBy) {
        case 'balance':
          comparison = Number(a.balance - b.balance);
          break;
        case 'yield':
          comparison = a.yieldRate - b.yieldRate;
          break;
        case 'created':
          comparison = a.createdAt - b.createdAt;
          break;
        case 'success':
          comparison = a.successRate - b.successRate;
          break;
        case 'relevance':
        default:
          // Simple relevance scoring
          const aScore = calculateRelevanceScore(a, filters.query);
          const bScore = calculateRelevanceScore(b, filters.query);
          comparison = aScore - bScore;
          break;
      }

      return filters.sortOrder === 'asc' ? comparison : -comparison;
    });

    return filtered;
  }, [vaults, filters]);

  const calculateRelevanceScore = (vault: SearchableVault, query: string): number => {
    if (!query) return 0;

    let score = 0;
    const lowerQuery = query.toLowerCase();

    // Exact name match gets highest score
    if (vault.name.toLowerCase() === lowerQuery) score += 100;
    else if (vault.name.toLowerCase().includes(lowerQuery)) score += 50;

    // Category match
    if (vault.category.toLowerCase().includes(lowerQuery)) score += 30;

    // Tag matches
    vault.tags.forEach(tag => {
      if (tag.toLowerCase().includes(lowerQuery)) score += 20;
    });

    // Description match
    if (vault.description.toLowerCase().includes(lowerQuery)) score += 10;

    // Boost popular vaults
    score += vault.successRate / 10;
    score += Math.min(vault.collaborators * 5, 25);

    return score;
  };

  const updateFilter = <K extends keyof SearchFilters>(key: K, value: SearchFilters[K]) => {
    setFilters(prev => ({ ...prev, [key]: value }));
  };

  const addTag = (tag: string) => {
    if (!filters.tags.includes(tag)) {
      updateFilter('tags', [...filters.tags, tag]);
    }
  };

  const removeTag = (tag: string) => {
    updateFilter('tags', filters.tags.filter(t => t !== tag));
  };

  const clearFilters = () => {
    setFilters({
      query: '',
      category: 'all',
      status: 'all',
      riskLevel: 'all',
      balanceRange: { min: '', max: '' },
      yieldRange: { min: '', max: '' },
      dateRange: { start: '', end: '' },
      tags: [],
      isPublic: null,
      hasCollaborators: null,
      sortBy: 'relevance',
      sortOrder: 'desc'
    });
  };

  const saveSearch = () => {
    const name = prompt('Enter a name for this search:');
    if (name) {
      setSavedSearches(prev => [...prev, { name, filters: { ...filters } }]);
    }
  };

  const loadSavedSearch = (savedFilters: SearchFilters) => {
    setFilters(savedFilters);
  };

  const getStatusColor = (status: SearchableVault['status']) => {
    const colors = {
      active: 'bg-green-100 text-green-800',
      completed: 'bg-blue-100 text-blue-800',
      locked: 'bg-yellow-100 text-yellow-800',
      expired: 'bg-red-100 text-red-800'
    };
    return colors[status];
  };

  const getRiskColor = (risk: SearchableVault['riskLevel']) => {
    const colors = {
      low: 'bg-green-100 text-green-800',
      medium: 'bg-yellow-100 text-yellow-800',
      high: 'bg-red-100 text-red-800'
    };
    return colors[risk];
  };

  return (
    <div className={className}>
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Discover Vaults</h2>
        <p className="text-gray-600">
          Explore and find vaults that match your investment goals and risk tolerance.
        </p>
      </div>

      {/* Search Bar */}
      <div className="relative mb-6">
        <Input
          value={filters.query}
          onChange={(e) => updateFilter('query', e.target.value)}
          placeholder="Search vaults by name, description, tags, or category..."
          className="w-full text-lg py-3 pr-12"
        />
        
        {searchSuggestions.length > 0 && (
          <div className="absolute top-full left-0 right-0 bg-white border border-gray-300 rounded-md shadow-lg z-10 mt-1">
            {searchSuggestions.map((suggestion, index) => (
              <button
                key={index}
                onClick={() => updateFilter('query', suggestion)}
                className="w-full text-left px-4 py-2 hover:bg-gray-50 first:rounded-t-md last:rounded-b-md"
              >
                {suggestion}
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Quick Filters */}
      <div className="flex flex-wrap gap-4 mb-6">
        <select
          value={filters.category}
          onChange={(e) => updateFilter('category', e.target.value)}
          className="border border-gray-300 rounded-md px-3 py-2"
        >
          <option value="all">All Categories</option>
          {availableCategories.map(category => (
            <option key={category} value={category}>
              {category.charAt(0).toUpperCase() + category.slice(1)}
            </option>
          ))}
        </select>

        <select
          value={filters.status}
          onChange={(e) => updateFilter('status', e.target.value)}
          className="border border-gray-300 rounded-md px-3 py-2"
        >
          <option value="all">All Status</option>
          <option value="active">Active</option>
          <option value="completed">Completed</option>
          <option value="locked">Locked</option>
          <option value="expired">Expired</option>
        </select>

        <select
          value={filters.sortBy}
          onChange={(e) => updateFilter('sortBy', e.target.value as SearchFilters['sortBy'])}
          className="border border-gray-300 rounded-md px-3 py-2"
        >
          <option value="relevance">Relevance</option>
          <option value="balance">Balance</option>
          <option value="yield">Yield Rate</option>
          <option value="created">Date Created</option>
          <option value="success">Success Rate</option>
        </select>

        <Button
          variant="outline"
          onClick={() => setShowAdvancedFilters(!showAdvancedFilters)}
        >
          Advanced Filters
        </Button>

        {Object.values(filters).some(v => 
          (typeof v === 'string' && v !== '' && v !== 'all') ||
          (Array.isArray(v) && v.length > 0) ||
          (typeof v === 'object' && v !== null && Object.values(v).some(val => val !== ''))
        ) && (
          <Button variant="ghost" onClick={clearFilters}>
            Clear All
          </Button>
        )}
      </div>

      {/* Advanced Filters */}
      {showAdvancedFilters && (
        <Card className="p-4 mb-6">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Risk Level</label>
              <select
                value={filters.riskLevel}
                onChange={(e) => updateFilter('riskLevel', e.target.value)}
                className="w-full border border-gray-300 rounded-md px-3 py-2"
              >
                <option value="all">All Risk Levels</option>
                <option value="low">Low Risk</option>
                <option value="medium">Medium Risk</option>
                <option value="high">High Risk</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Balance Range (ETH)</label>
              <div className="flex space-x-2">
                <Input
                  type="number"
                  placeholder="Min"
                  value={filters.balanceRange.min}
                  onChange={(e) => updateFilter('balanceRange', { ...filters.balanceRange, min: e.target.value })}
                  className="w-20"
                />
                <Input
                  type="number"
                  placeholder="Max"
                  value={filters.balanceRange.max}
                  onChange={(e) => updateFilter('balanceRange', { ...filters.balanceRange, max: e.target.value })}
                  className="w-20"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Yield Range (%)</label>
              <div className="flex space-x-2">
                <Input
                  type="number"
                  placeholder="Min"
                  value={filters.yieldRange.min}
                  onChange={(e) => updateFilter('yieldRange', { ...filters.yieldRange, min: e.target.value })}
                  className="w-20"
                />
                <Input
                  type="number"
                  placeholder="Max"
                  value={filters.yieldRange.max}
                  onChange={(e) => updateFilter('yieldRange', { ...filters.yieldRange, max: e.target.value })}
                  className="w-20"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Created Date Range</label>
              <div className="flex space-x-2">
                <Input
                  type="date"
                  value={filters.dateRange.start}
                  onChange={(e) => updateFilter('dateRange', { ...filters.dateRange, start: e.target.value })}
                  className="w-32"
                />
                <Input
                  type="date"
                  value={filters.dateRange.end}
                  onChange={(e) => updateFilter('dateRange', { ...filters.dateRange, end: e.target.value })}
                  className="w-32"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Visibility</label>
              <select
                value={filters.isPublic === null ? 'all' : filters.isPublic ? 'public' : 'private'}
                onChange={(e) => updateFilter('isPublic', e.target.value === 'all' ? null : e.target.value === 'public')}
                className="w-full border border-gray-300 rounded-md px-3 py-2"
              >
                <option value="all">All Vaults</option>
                <option value="public">Public Only</option>
                <option value="private">Private Only</option>
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">Collaboration</label>
              <select
                value={filters.hasCollaborators === null ? 'all' : filters.hasCollaborators ? 'yes' : 'no'}
                onChange={(e) => updateFilter('hasCollaborators', e.target.value === 'all' ? null : e.target.value === 'yes')}
                className="w-full border border-gray-300 rounded-md px-3 py-2"
              >
                <option value="all">All Vaults</option>
                <option value="yes">With Collaborators</option>
                <option value="no">Solo Vaults</option>
              </select>
            </div>
          </div>

          {/* Tags */}
          <div className="mt-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">Tags</label>
            <div className="flex flex-wrap gap-2 mb-2">
              {filters.tags.map(tag => (
                <Badge key={tag} variant="secondary" className="cursor-pointer" onClick={() => removeTag(tag)}>
                  {tag} ✕
                </Badge>
              ))}
            </div>
            <div className="flex flex-wrap gap-2">
              {availableTags.filter(tag => !filters.tags.includes(tag)).slice(0, 10).map(tag => (
                <Badge key={tag} variant="outline" className="cursor-pointer" onClick={() => addTag(tag)}>
                  + {tag}
                </Badge>
              ))}
            </div>
          </div>

          <div className="mt-4 flex space-x-2">
            <Button variant="outline" size="sm" onClick={saveSearch}>
              Save Search
            </Button>
            {savedSearches.length > 0 && (
              <select
                onChange={(e) => {
                  const search = savedSearches.find(s => s.name === e.target.value);
                  if (search) loadSavedSearch(search.filters);
                }}
                className="border border-gray-300 rounded px-2 py-1 text-sm"
              >
                <option value="">Load Saved Search</option>
                {savedSearches.map(search => (
                  <option key={search.name} value={search.name}>
                    {search.name}
                  </option>
                ))}
              </select>
            )}
          </div>
        </Card>
      )}

      {/* Results */}
      <div className="mb-4 flex items-center justify-between">
        <div className="text-sm text-gray-600">
          {filteredVaults.length} vault{filteredVaults.length !== 1 ? 's' : ''} found
        </div>
        <div className="flex items-center space-x-2">
          <select
            value={filters.sortOrder}
            onChange={(e) => updateFilter('sortOrder', e.target.value as 'asc' | 'desc')}
            className="border border-gray-300 rounded px-2 py-1 text-sm"
          >
            <option value="desc">Descending</option>
            <option value="asc">Ascending</option>
          </select>
        </div>
      </div>

      {/* Vault Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredVaults.map(vault => (
          <Card key={vault.id} className="p-6 hover:shadow-lg transition-shadow cursor-pointer" onClick={() => onVaultSelect(vault)}>
            <div className="flex items-start justify-between mb-4">
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-1">{vault.name}</h3>
                <div className="flex items-center space-x-2 mb-2">
                  <Badge className={getStatusColor(vault.status)}>
                    {vault.status}
                  </Badge>
                  <Badge className={getRiskColor(vault.riskLevel)}>
                    {vault.riskLevel} risk
                  </Badge>
                  {vault.isPublic && <Badge variant="info">Public</Badge>}
                </div>
              </div>
              <div className="text-right text-sm text-gray-500">
                <div>{vault.successRate}% success</div>
                {vault.yieldRate > 0 && <div>{vault.yieldRate}% APY</div>}
              </div>
            </div>

            <p className="text-gray-600 text-sm mb-4 line-clamp-2">{vault.description}</p>

            <div className="space-y-2 mb-4">
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">Balance:</span>
                <span className="font-medium">{formatBalance(vault.balance)} ETH</span>
              </div>
              {vault.goalAmount > 0n && (
                <div className="flex justify-between text-sm">
                  <span className="text-gray-500">Goal:</span>
                  <span className="font-medium">{formatBalance(vault.goalAmount)} ETH</span>
                </div>
              )}
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">Owner:</span>
                <span className="font-mono">{formatAddress(vault.owner)}</span>
              </div>
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">Created:</span>
                <span>{formatDate(vault.createdAt)}</span>
              </div>
            </div>

            <div className="flex flex-wrap gap-1 mb-4">
              {vault.tags.slice(0, 3).map(tag => (
                <Badge key={tag} variant="secondary" className="text-xs">
                  {tag}
                </Badge>
              ))}
              {vault.tags.length > 3 && (
                <Badge variant="secondary" className="text-xs">
                  +{vault.tags.length - 3}
                </Badge>
              )}
            </div>

            <div className="flex items-center justify-between">
              <div className="text-sm text-gray-500">
                {vault.collaborators > 0 && `${vault.collaborators} collaborators`}
              </div>
              <Button size="sm" variant="outline">
                View Details
              </Button>
            </div>
          </Card>
        ))}
      </div>

      {filteredVaults.length === 0 && (
        <div className="text-center py-12">
          <div className="text-gray-400 mb-4">
            <svg className="mx-auto h-12 w-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>
          <h3 className="text-lg font-medium text-gray-900 mb-2">No vaults found</h3>
          <p className="text-gray-500">Try adjusting your search criteria or filters.</p>
        </div>
      )}
    </div>
  );
}
