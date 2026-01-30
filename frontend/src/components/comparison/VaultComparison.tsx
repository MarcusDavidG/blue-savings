import React, { useState, useMemo } from 'react';
import { Card } from '../Card';
import { Button } from '../Button';
import { Badge } from '../Badge';
import { formatBalance } from '../../utils/format-balance';
import { formatDate } from '../../utils/format-date';
import { formatAddress } from '../../utils/format-address';

interface ComparableVault {
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
  riskLevel: 'low' | 'medium' | 'high';
  status: 'active' | 'completed' | 'locked' | 'expired';
  yieldRate: number;
  successRate: number;
  collaborators: number;
  totalDeposits: bigint;
  totalWithdrawals: bigint;
  averageDepositSize: bigint;
  holdingPeriod: number; // in days
  fees: bigint;
  isPublic: boolean;
}

interface ComparisonMetric {
  key: keyof ComparableVault;
  label: string;
  type: 'text' | 'number' | 'currency' | 'percentage' | 'date' | 'address' | 'badge' | 'boolean';
  category: 'basic' | 'financial' | 'performance' | 'social' | 'technical';
  importance: 'high' | 'medium' | 'low';
  format?: (value: any) => string;
}

const COMPARISON_METRICS: ComparisonMetric[] = [
  // Basic Information
  { key: 'name', label: 'Name', type: 'text', category: 'basic', importance: 'high' },
  { key: 'category', label: 'Category', type: 'badge', category: 'basic', importance: 'high' },
  { key: 'status', label: 'Status', type: 'badge', category: 'basic', importance: 'high' },
  { key: 'riskLevel', label: 'Risk Level', type: 'badge', category: 'basic', importance: 'high' },
  { key: 'owner', label: 'Owner', type: 'address', category: 'basic', importance: 'medium' },
  { key: 'createdAt', label: 'Created', type: 'date', category: 'basic', importance: 'medium' },
  { key: 'isPublic', label: 'Public', type: 'boolean', category: 'basic', importance: 'low' },

  // Financial Metrics
  { key: 'balance', label: 'Current Balance', type: 'currency', category: 'financial', importance: 'high' },
  { key: 'goalAmount', label: 'Goal Amount', type: 'currency', category: 'financial', importance: 'high' },
  { key: 'totalDeposits', label: 'Total Deposits', type: 'currency', category: 'financial', importance: 'medium' },
  { key: 'totalWithdrawals', label: 'Total Withdrawals', type: 'currency', category: 'financial', importance: 'medium' },
  { key: 'averageDepositSize', label: 'Avg Deposit Size', type: 'currency', category: 'financial', importance: 'medium' },
  { key: 'fees', label: 'Total Fees', type: 'currency', category: 'financial', importance: 'low' },

  // Performance Metrics
  { key: 'yieldRate', label: 'Yield Rate', type: 'percentage', category: 'performance', importance: 'high' },
  { key: 'successRate', label: 'Success Rate', type: 'percentage', category: 'performance', importance: 'high' },
  { key: 'holdingPeriod', label: 'Holding Period', type: 'number', category: 'performance', importance: 'medium', format: (days: number) => `${days} days` },

  // Social Metrics
  { key: 'collaborators', label: 'Collaborators', type: 'number', category: 'social', importance: 'medium' },

  // Technical Metrics
  { key: 'unlockTimestamp', label: 'Unlock Date', type: 'date', category: 'technical', importance: 'medium' }
];

interface VaultComparisonProps {
  vaults: ComparableVault[];
  selectedVaultIds: number[];
  onVaultSelect: (vaultId: number) => void;
  onVaultDeselect: (vaultId: number) => void;
  className?: string;
}

export function VaultComparison({ 
  vaults, 
  selectedVaultIds, 
  onVaultSelect, 
  onVaultDeselect, 
  className = '' 
}: VaultComparisonProps) {
  const [selectedCategories, setSelectedCategories] = useState<string[]>(['basic', 'financial', 'performance']);
  const [showOnlyDifferences, setShowOnlyDifferences] = useState(false);
  const [comparisonMode, setComparisonMode] = useState<'side-by-side' | 'table'>('side-by-side');

  const selectedVaults = useMemo(() => {
    return vaults.filter(vault => selectedVaultIds.includes(vault.id));
  }, [vaults, selectedVaultIds]);

  const availableVaults = useMemo(() => {
    return vaults.filter(vault => !selectedVaultIds.includes(vault.id));
  }, [vaults, selectedVaultIds]);

  const filteredMetrics = useMemo(() => {
    let metrics = COMPARISON_METRICS.filter(metric => 
      selectedCategories.includes(metric.category)
    );

    if (showOnlyDifferences && selectedVaults.length > 1) {
      metrics = metrics.filter(metric => {
        const values = selectedVaults.map(vault => vault[metric.key]);
        return !values.every(value => JSON.stringify(value) === JSON.stringify(values[0]));
      });
    }

    return metrics;
  }, [selectedCategories, showOnlyDifferences, selectedVaults]);

  const formatValue = (value: any, metric: ComparisonMetric): string => {
    if (value === null || value === undefined) return 'N/A';

    if (metric.format) {
      return metric.format(value);
    }

    switch (metric.type) {
      case 'currency':
        return `${formatBalance(BigInt(value))} ETH`;
      case 'percentage':
        return `${value}%`;
      case 'date':
        return value === 0 ? 'No date set' : formatDate(value);
      case 'address':
        return formatAddress(value);
      case 'boolean':
        return value ? 'Yes' : 'No';
      case 'badge':
        return value;
      default:
        return String(value);
    }
  };

  const getBadgeColor = (value: string, metricKey: string) => {
    if (metricKey === 'status') {
      const colors = {
        active: 'bg-green-100 text-green-800',
        completed: 'bg-blue-100 text-blue-800',
        locked: 'bg-yellow-100 text-yellow-800',
        expired: 'bg-red-100 text-red-800'
      };
      return colors[value as keyof typeof colors] || 'bg-gray-100 text-gray-800';
    }

    if (metricKey === 'riskLevel') {
      const colors = {
        low: 'bg-green-100 text-green-800',
        medium: 'bg-yellow-100 text-yellow-800',
        high: 'bg-red-100 text-red-800'
      };
      return colors[value as keyof typeof colors] || 'bg-gray-100 text-gray-800';
    }

    if (metricKey === 'category') {
      const colors = {
        savings: 'bg-blue-100 text-blue-800',
        investment: 'bg-green-100 text-green-800',
        emergency: 'bg-red-100 text-red-800',
        goal: 'bg-purple-100 text-purple-800',
        retirement: 'bg-orange-100 text-orange-800'
      };
      return colors[value as keyof typeof colors] || 'bg-gray-100 text-gray-800';
    }

    return 'bg-gray-100 text-gray-800';
  };

  const getComparisonInsights = () => {
    if (selectedVaults.length < 2) return [];

    const insights: string[] = [];

    // Balance comparison
    const balances = selectedVaults.map(v => Number(v.balance));
    const maxBalance = Math.max(...balances);
    const minBalance = Math.min(...balances);
    if (maxBalance > minBalance * 2) {
      const highestVault = selectedVaults.find(v => Number(v.balance) === maxBalance);
      insights.push(`${highestVault?.name} has significantly higher balance than others`);
    }

    // Yield comparison
    const yields = selectedVaults.map(v => v.yieldRate).filter(y => y > 0);
    if (yields.length > 1) {
      const maxYield = Math.max(...yields);
      const minYield = Math.min(...yields);
      if (maxYield > minYield * 1.5) {
        const highestYieldVault = selectedVaults.find(v => v.yieldRate === maxYield);
        insights.push(`${highestYieldVault?.name} offers the highest yield at ${maxYield}%`);
      }
    }

    // Risk comparison
    const riskLevels = selectedVaults.map(v => v.riskLevel);
    const uniqueRisks = [...new Set(riskLevels)];
    if (uniqueRisks.length > 1) {
      insights.push(`Vaults have different risk levels: ${uniqueRisks.join(', ')}`);
    }

    // Success rate comparison
    const successRates = selectedVaults.map(v => v.successRate);
    const maxSuccess = Math.max(...successRates);
    const minSuccess = Math.min(...successRates);
    if (maxSuccess > minSuccess + 20) {
      const bestVault = selectedVaults.find(v => v.successRate === maxSuccess);
      insights.push(`${bestVault?.name} has the highest success rate at ${maxSuccess}%`);
    }

    return insights;
  };

  const renderSideBySideComparison = () => (
    <div className="grid gap-6" style={{ gridTemplateColumns: `repeat(${selectedVaults.length}, 1fr)` }}>
      {selectedVaults.map(vault => (
        <Card key={vault.id} className="p-6">
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900">{vault.name}</h3>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => onVaultDeselect(vault.id)}
              className="text-red-600 hover:text-red-700"
            >
              Remove
            </Button>
          </div>

          <div className="space-y-3">
            {filteredMetrics.map(metric => (
              <div key={metric.key} className="flex justify-between">
                <span className="text-sm text-gray-500">{metric.label}:</span>
                <span className="text-sm font-medium">
                  {metric.type === 'badge' ? (
                    <Badge className={getBadgeColor(String(vault[metric.key]), metric.key)}>
                      {formatValue(vault[metric.key], metric)}
                    </Badge>
                  ) : (
                    formatValue(vault[metric.key], metric)
                  )}
                </span>
              </div>
            ))}
          </div>
        </Card>
      ))}
    </div>
  );

  const renderTableComparison = () => (
    <div className="overflow-x-auto">
      <table className="w-full border-collapse border border-gray-300">
        <thead>
          <tr className="bg-gray-50">
            <th className="border border-gray-300 px-4 py-2 text-left font-medium text-gray-900">
              Metric
            </th>
            {selectedVaults.map(vault => (
              <th key={vault.id} className="border border-gray-300 px-4 py-2 text-left font-medium text-gray-900">
                <div className="flex items-center justify-between">
                  {vault.name}
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => onVaultDeselect(vault.id)}
                    className="text-red-600 hover:text-red-700 ml-2"
                  >
                    ✕
                  </Button>
                </div>
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {filteredMetrics.map(metric => (
            <tr key={metric.key} className="hover:bg-gray-50">
              <td className="border border-gray-300 px-4 py-2 font-medium text-gray-700">
                {metric.label}
              </td>
              {selectedVaults.map(vault => (
                <td key={vault.id} className="border border-gray-300 px-4 py-2">
                  {metric.type === 'badge' ? (
                    <Badge className={getBadgeColor(String(vault[metric.key]), metric.key)}>
                      {formatValue(vault[metric.key], metric)}
                    </Badge>
                  ) : (
                    formatValue(vault[metric.key], metric)
                  )}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );

  const insights = getComparisonInsights();

  return (
    <div className={className}>
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Vault Comparison</h2>
        <p className="text-gray-600">
          Compare multiple vaults side by side to make informed decisions.
        </p>
      </div>

      {/* Vault Selection */}
      {selectedVaults.length < 4 && (
        <Card className="p-4 mb-6">
          <h3 className="font-medium text-gray-900 mb-3">Add Vaults to Compare</h3>
          <div className="flex flex-wrap gap-2">
            {availableVaults.slice(0, 10).map(vault => (
              <Button
                key={vault.id}
                variant="outline"
                size="sm"
                onClick={() => onVaultSelect(vault.id)}
              >
                + {vault.name}
              </Button>
            ))}
          </div>
        </Card>
      )}

      {selectedVaults.length === 0 && (
        <div className="text-center py-12">
          <div className="text-gray-400 mb-4">
            <svg className="mx-auto h-12 w-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
            </svg>
          </div>
          <h3 className="text-lg font-medium text-gray-900 mb-2">No vaults selected</h3>
          <p className="text-gray-500">Select at least 2 vaults to start comparing.</p>
        </Card>
      )}

      {selectedVaults.length > 0 && (
        <>
          {/* Controls */}
          <div className="flex flex-wrap items-center justify-between gap-4 mb-6">
            <div className="flex items-center space-x-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">View Mode</label>
                <select
                  value={comparisonMode}
                  onChange={(e) => setComparisonMode(e.target.value as 'side-by-side' | 'table')}
                  className="border border-gray-300 rounded-md px-3 py-2 text-sm"
                >
                  <option value="side-by-side">Side by Side</option>
                  <option value="table">Table</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Categories</label>
                <div className="flex space-x-2">
                  {['basic', 'financial', 'performance', 'social', 'technical'].map(category => (
                    <label key={category} className="flex items-center">
                      <input
                        type="checkbox"
                        checked={selectedCategories.includes(category)}
                        onChange={(e) => {
                          if (e.target.checked) {
                            setSelectedCategories(prev => [...prev, category]);
                          } else {
                            setSelectedCategories(prev => prev.filter(c => c !== category));
                          }
                        }}
                        className="mr-1"
                      />
                      <span className="text-sm capitalize">{category}</span>
                    </label>
                  ))}
                </div>
              </div>
            </div>

            <div className="flex items-center space-x-2">
              <label className="flex items-center">
                <input
                  type="checkbox"
                  checked={showOnlyDifferences}
                  onChange={(e) => setShowOnlyDifferences(e.target.checked)}
                  className="mr-2"
                />
                <span className="text-sm">Show only differences</span>
              </label>
            </div>
          </div>

          {/* Insights */}
          {insights.length > 0 && (
            <Card className="p-4 mb-6 bg-blue-50 border-blue-200">
              <h3 className="font-medium text-blue-900 mb-2">Comparison Insights</h3>
              <ul className="space-y-1">
                {insights.map((insight, index) => (
                  <li key={index} className="text-sm text-blue-800">
                    • {insight}
                  </li>
                ))}
              </ul>
            </Card>
          )}

          {/* Comparison Display */}
          {comparisonMode === 'side-by-side' ? renderSideBySideComparison() : renderTableComparison()}

          {/* Export Options */}
          <div className="mt-6 flex justify-center">
            <Button
              variant="outline"
              onClick={() => {
                const data = selectedVaults.map(vault => {
                  const row: any = { name: vault.name };
                  filteredMetrics.forEach(metric => {
                    row[metric.label] = formatValue(vault[metric.key], metric);
                  });
                  return row;
                });

                const csv = [
                  ['Metric', ...selectedVaults.map(v => v.name)].join(','),
                  ...filteredMetrics.map(metric => [
                    metric.label,
                    ...selectedVaults.map(vault => formatValue(vault[metric.key], metric))
                  ].join(','))
                ].join('\n');

                const blob = new Blob([csv], { type: 'text/csv' });
                const url = URL.createObjectURL(blob);
                const link = document.createElement('a');
                link.href = url;
                link.download = 'vault-comparison.csv';
                link.click();
                URL.revokeObjectURL(url);
              }}
            >
              Export Comparison
            </Button>
          </div>
        </>
      )}
    </div>
  );
}
