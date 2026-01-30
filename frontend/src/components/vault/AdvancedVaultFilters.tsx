import React, { useState, useMemo } from 'react';
import { Input } from '../Input';
import { Select } from '../form/Select';
import { Button } from '../Button';
import { Badge } from '../Badge';

export interface VaultFilters {
  search: string;
  status: 'all' | 'active' | 'completed' | 'expired';
  type: 'all' | 'time-locked' | 'goal-based' | 'flexible';
  amountRange: {
    min: string;
    max: string;
  };
  dateRange: {
    start: string;
    end: string;
  };
  sortBy: 'created' | 'amount' | 'progress' | 'unlock-time';
  sortOrder: 'asc' | 'desc';
}

interface AdvancedVaultFiltersProps {
  filters: VaultFilters;
  onFiltersChange: (filters: VaultFilters) => void;
  onReset: () => void;
  totalResults: number;
  isLoading?: boolean;
}

export function AdvancedVaultFilters({
  filters,
  onFiltersChange,
  onReset,
  totalResults,
  isLoading = false
}: AdvancedVaultFiltersProps) {
  const [isExpanded, setIsExpanded] = useState(false);

  const activeFilterCount = useMemo(() => {
    let count = 0;
    if (filters.search) count++;
    if (filters.status !== 'all') count++;
    if (filters.type !== 'all') count++;
    if (filters.amountRange.min || filters.amountRange.max) count++;
    if (filters.dateRange.start || filters.dateRange.end) count++;
    return count;
  }, [filters]);

  const updateFilter = <K extends keyof VaultFilters>(
    key: K,
    value: VaultFilters[K]
  ) => {
    onFiltersChange({ ...filters, [key]: value });
  };

  const statusOptions = [
    { value: 'all', label: 'All Status' },
    { value: 'active', label: 'Active' },
    { value: 'completed', label: 'Completed' },
    { value: 'expired', label: 'Expired' }
  ];

  const typeOptions = [
    { value: 'all', label: 'All Types' },
    { value: 'time-locked', label: 'Time-Locked' },
    { value: 'goal-based', label: 'Goal-Based' },
    { value: 'flexible', label: 'Flexible' }
  ];

  const sortOptions = [
    { value: 'created', label: 'Date Created' },
    { value: 'amount', label: 'Amount' },
    { value: 'progress', label: 'Progress' },
    { value: 'unlock-time', label: 'Unlock Time' }
  ];

  return (
    <div className="bg-white border border-gray-200 rounded-lg p-4 space-y-4">
      {/* Basic Filters Row */}
      <div className="flex flex-wrap gap-4 items-center">
        <div className="flex-1 min-w-64">
          <Input
            placeholder="Search vaults by name or description..."
            value={filters.search}
            onChange={(e) => updateFilter('search', e.target.value)}
            className="w-full"
          />
        </div>
        
        <Select
          value={filters.status}
          onChange={(value) => updateFilter('status', value as VaultFilters['status'])}
          options={statusOptions}
          className="min-w-32"
        />
        
        <Select
          value={filters.type}
          onChange={(value) => updateFilter('type', value as VaultFilters['type'])}
          options={typeOptions}
          className="min-w-32"
        />
        
        <Button
          variant="outline"
          onClick={() => setIsExpanded(!isExpanded)}
          className="flex items-center space-x-2"
        >
          <span>Advanced</span>
          <svg
            className={`w-4 h-4 transition-transform ${isExpanded ? 'rotate-180' : ''}`}
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
          </svg>
        </Button>
      </div>

      {/* Advanced Filters */}
      {isExpanded && (
        <div className="border-t pt-4 space-y-4">
          {/* Amount Range */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Amount Range (ETH)
            </label>
            <div className="flex items-center space-x-2">
              <Input
                type="number"
                placeholder="Min"
                value={filters.amountRange.min}
                onChange={(e) => updateFilter('amountRange', {
                  ...filters.amountRange,
                  min: e.target.value
                })}
                className="w-24"
              />
              <span className="text-gray-500">to</span>
              <Input
                type="number"
                placeholder="Max"
                value={filters.amountRange.max}
                onChange={(e) => updateFilter('amountRange', {
                  ...filters.amountRange,
                  max: e.target.value
                })}
                className="w-24"
              />
            </div>
          </div>

          {/* Date Range */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Date Range
            </label>
            <div className="flex items-center space-x-2">
              <Input
                type="date"
                value={filters.dateRange.start}
                onChange={(e) => updateFilter('dateRange', {
                  ...filters.dateRange,
                  start: e.target.value
                })}
                className="w-40"
              />
              <span className="text-gray-500">to</span>
              <Input
                type="date"
                value={filters.dateRange.end}
                onChange={(e) => updateFilter('dateRange', {
                  ...filters.dateRange,
                  end: e.target.value
                })}
                className="w-40"
              />
            </div>
          </div>

          {/* Sort Options */}
          <div className="flex items-center space-x-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Sort By
              </label>
              <Select
                value={filters.sortBy}
                onChange={(value) => updateFilter('sortBy', value as VaultFilters['sortBy'])}
                options={sortOptions}
                className="w-40"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Order
              </label>
              <Select
                value={filters.sortOrder}
                onChange={(value) => updateFilter('sortOrder', value as VaultFilters['sortOrder'])}
                options={[
                  { value: 'desc', label: 'Descending' },
                  { value: 'asc', label: 'Ascending' }
                ]}
                className="w-32"
              />
            </div>
          </div>
        </div>
      )}

      {/* Results Summary and Actions */}
      <div className="flex items-center justify-between pt-2 border-t">
        <div className="flex items-center space-x-3">
          <span className="text-sm text-gray-600">
            {isLoading ? 'Loading...' : `${totalResults.toLocaleString()} results`}
          </span>
          
          {activeFilterCount > 0 && (
            <Badge variant="secondary" className="text-xs">
              {activeFilterCount} filter{activeFilterCount !== 1 ? 's' : ''} active
            </Badge>
          )}
        </div>
        
        {activeFilterCount > 0 && (
          <Button
            variant="ghost"
            size="sm"
            onClick={onReset}
            className="text-gray-500 hover:text-gray-700"
          >
            Clear all filters
          </Button>
        )}
      </div>
    </div>
  );
}
