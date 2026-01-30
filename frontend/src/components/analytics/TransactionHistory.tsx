import React, { useState, useMemo } from 'react';
import { Card } from '../Card';
import { Badge } from '../Badge';
import { Button } from '../Button';
import { Input } from '../Input';
import { formatBalance } from '../../utils/format-balance';
import { formatDate } from '../../utils/format-date';
import { formatAddress } from '../../utils/format-address';

interface Transaction {
  id: string;
  hash: string;
  type: 'deposit' | 'withdraw' | 'create' | 'emergency_withdraw' | 'yield_claim' | 'fee_payment';
  amount: bigint;
  timestamp: number;
  blockNumber: number;
  gasUsed: bigint;
  gasPrice: bigint;
  from: string;
  to: string;
  vaultId?: number;
  status: 'pending' | 'confirmed' | 'failed';
  metadata?: {
    goalReached?: boolean;
    unlockTriggered?: boolean;
    yieldAmount?: bigint;
    feeAmount?: bigint;
    reason?: string;
  };
}

interface TransactionAnalytics {
  totalTransactions: number;
  totalVolume: bigint;
  totalFees: bigint;
  averageGasPrice: bigint;
  transactionsByType: Record<string, number>;
  monthlyVolume: Array<{ month: string; volume: bigint; count: number }>;
  topVaults: Array<{ vaultId: number; volume: bigint; transactions: number }>;
}

interface TransactionHistoryProps {
  transactions: Transaction[];
  analytics: TransactionAnalytics;
  isLoading?: boolean;
  className?: string;
}

export function TransactionHistory({ 
  transactions, 
  analytics, 
  isLoading = false, 
  className = '' 
}: TransactionHistoryProps) {
  const [filter, setFilter] = useState<{
    type: string;
    status: string;
    dateRange: { start: string; end: string };
    search: string;
    vaultId: string;
  }>({
    type: 'all',
    status: 'all',
    dateRange: { start: '', end: '' },
    search: '',
    vaultId: ''
  });

  const [sortBy, setSortBy] = useState<'timestamp' | 'amount' | 'gasUsed'>('timestamp');
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('desc');
  const [showAnalytics, setShowAnalytics] = useState(false);
  const [selectedTransaction, setSelectedTransaction] = useState<Transaction | null>(null);

  const filteredTransactions = useMemo(() => {
    return transactions
      .filter(tx => {
        const matchesType = filter.type === 'all' || tx.type === filter.type;
        const matchesStatus = filter.status === 'all' || tx.status === filter.status;
        const matchesVault = !filter.vaultId || tx.vaultId?.toString() === filter.vaultId;
        const matchesSearch = !filter.search || 
          tx.hash.toLowerCase().includes(filter.search.toLowerCase()) ||
          tx.from.toLowerCase().includes(filter.search.toLowerCase()) ||
          tx.to.toLowerCase().includes(filter.search.toLowerCase());
        
        let matchesDate = true;
        if (filter.dateRange.start) {
          matchesDate = matchesDate && tx.timestamp >= new Date(filter.dateRange.start).getTime();
        }
        if (filter.dateRange.end) {
          matchesDate = matchesDate && tx.timestamp <= new Date(filter.dateRange.end).getTime();
        }

        return matchesType && matchesStatus && matchesVault && matchesSearch && matchesDate;
      })
      .sort((a, b) => {
        let comparison = 0;
        switch (sortBy) {
          case 'timestamp':
            comparison = a.timestamp - b.timestamp;
            break;
          case 'amount':
            comparison = Number(a.amount - b.amount);
            break;
          case 'gasUsed':
            comparison = Number(a.gasUsed - b.gasUsed);
            break;
        }
        return sortOrder === 'asc' ? comparison : -comparison;
      });
  }, [transactions, filter, sortBy, sortOrder]);

  const getTransactionIcon = (type: Transaction['type']) => {
    const icons = {
      deposit: '↗️',
      withdraw: '↙️',
      create: '🆕',
      emergency_withdraw: '🚨',
      yield_claim: '💰',
      fee_payment: '💳'
    };
    return icons[type] || '📄';
  };

  const getStatusColor = (status: Transaction['status']) => {
    const colors = {
      pending: 'bg-yellow-100 text-yellow-800',
      confirmed: 'bg-green-100 text-green-800',
      failed: 'bg-red-100 text-red-800'
    };
    return colors[status];
  };

  const getTypeColor = (type: Transaction['type']) => {
    const colors = {
      deposit: 'bg-green-100 text-green-800',
      withdraw: 'bg-blue-100 text-blue-800',
      create: 'bg-purple-100 text-purple-800',
      emergency_withdraw: 'bg-red-100 text-red-800',
      yield_claim: 'bg-orange-100 text-orange-800',
      fee_payment: 'bg-gray-100 text-gray-800'
    };
    return colors[type] || 'bg-gray-100 text-gray-800';
  };

  const exportTransactions = () => {
    const csvContent = [
      ['Date', 'Type', 'Amount (ETH)', 'Hash', 'Status', 'Gas Used', 'Vault ID'].join(','),
      ...filteredTransactions.map(tx => [
        formatDate(tx.timestamp),
        tx.type,
        formatBalance(tx.amount),
        tx.hash,
        tx.status,
        tx.gasUsed.toString(),
        tx.vaultId?.toString() || ''
      ].join(','))
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `transactions-${new Date().toISOString().split('T')[0]}.csv`;
    link.click();
    URL.revokeObjectURL(url);
  };

  if (isLoading) {
    return (
      <Card className={`p-6 ${className}`}>
        <div className="animate-pulse space-y-4">
          <div className="h-4 bg-gray-200 rounded w-1/4"></div>
          <div className="space-y-3">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="h-16 bg-gray-200 rounded"></div>
            ))}
          </div>
        </div>
      </Card>
    );
  }

  return (
    <div className={className}>
      <div className="flex items-center justify-between mb-6">
        <h2 className="text-2xl font-bold text-gray-900">Transaction History</h2>
        <div className="flex items-center space-x-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => setShowAnalytics(!showAnalytics)}
          >
            {showAnalytics ? 'Hide' : 'Show'} Analytics
          </Button>
          <Button
            variant="outline"
            size="sm"
            onClick={exportTransactions}
            disabled={filteredTransactions.length === 0}
          >
            Export CSV
          </Button>
        </div>
      </div>

      {/* Analytics Panel */}
      {showAnalytics && (
        <Card className="p-6 mb-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Analytics Overview</h3>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
            <div className="text-center">
              <div className="text-2xl font-bold text-blue-600">
                {analytics.totalTransactions.toLocaleString()}
              </div>
              <div className="text-sm text-gray-500">Total Transactions</div>
            </div>
            
            <div className="text-center">
              <div className="text-2xl font-bold text-green-600">
                {formatBalance(analytics.totalVolume)} ETH
              </div>
              <div className="text-sm text-gray-500">Total Volume</div>
            </div>
            
            <div className="text-center">
              <div className="text-2xl font-bold text-orange-600">
                {formatBalance(analytics.totalFees)} ETH
              </div>
              <div className="text-sm text-gray-500">Total Fees</div>
            </div>
            
            <div className="text-center">
              <div className="text-2xl font-bold text-purple-600">
                {(Number(analytics.averageGasPrice) / 1e9).toFixed(1)} Gwei
              </div>
              <div className="text-sm text-gray-500">Avg Gas Price</div>
            </div>
          </div>

          {/* Transaction Types Breakdown */}
          <div className="mb-4">
            <h4 className="font-medium text-gray-900 mb-2">Transaction Types</h4>
            <div className="flex flex-wrap gap-2">
              {Object.entries(analytics.transactionsByType).map(([type, count]) => (
                <Badge key={type} className={getTypeColor(type as Transaction['type'])}>
                  {type.replace('_', ' ')}: {count}
                </Badge>
              ))}
            </div>
          </div>
        </Card>
      )}

      {/* Filters */}
      <Card className="p-4 mb-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-6 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Type</label>
            <select
              value={filter.type}
              onChange={(e) => setFilter(prev => ({ ...prev, type: e.target.value }))}
              className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm"
            >
              <option value="all">All Types</option>
              <option value="deposit">Deposits</option>
              <option value="withdraw">Withdrawals</option>
              <option value="create">Vault Creation</option>
              <option value="emergency_withdraw">Emergency</option>
              <option value="yield_claim">Yield Claims</option>
              <option value="fee_payment">Fee Payments</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
            <select
              value={filter.status}
              onChange={(e) => setFilter(prev => ({ ...prev, status: e.target.value }))}
              className="w-full border border-gray-300 rounded-md px-3 py-2 text-sm"
            >
              <option value="all">All Status</option>
              <option value="confirmed">Confirmed</option>
              <option value="pending">Pending</option>
              <option value="failed">Failed</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Vault ID</label>
            <Input
              value={filter.vaultId}
              onChange={(e) => setFilter(prev => ({ ...prev, vaultId: e.target.value }))}
              placeholder="Vault ID"
              className="text-sm"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">From Date</label>
            <Input
              type="date"
              value={filter.dateRange.start}
              onChange={(e) => setFilter(prev => ({ 
                ...prev, 
                dateRange: { ...prev.dateRange, start: e.target.value }
              }))}
              className="text-sm"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">To Date</label>
            <Input
              type="date"
              value={filter.dateRange.end}
              onChange={(e) => setFilter(prev => ({ 
                ...prev, 
                dateRange: { ...prev.dateRange, end: e.target.value }
              }))}
              className="text-sm"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Search</label>
            <Input
              value={filter.search}
              onChange={(e) => setFilter(prev => ({ ...prev, search: e.target.value }))}
              placeholder="Hash or address"
              className="text-sm"
            />
          </div>
        </div>

        <div className="flex items-center justify-between mt-4">
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2">
              <label className="text-sm font-medium text-gray-700">Sort by:</label>
              <select
                value={sortBy}
                onChange={(e) => setSortBy(e.target.value as typeof sortBy)}
                className="border border-gray-300 rounded px-2 py-1 text-sm"
              >
                <option value="timestamp">Date</option>
                <option value="amount">Amount</option>
                <option value="gasUsed">Gas Used</option>
              </select>
              <select
                value={sortOrder}
                onChange={(e) => setSortOrder(e.target.value as typeof sortOrder)}
                className="border border-gray-300 rounded px-2 py-1 text-sm"
              >
                <option value="desc">Descending</option>
                <option value="asc">Ascending</option>
              </select>
            </div>
          </div>
          
          <div className="text-sm text-gray-500">
            {filteredTransactions.length} of {transactions.length} transactions
          </div>
        </div>
      </Card>

      {/* Transactions List */}
      <Card className="overflow-hidden">
        {filteredTransactions.length === 0 ? (
          <div className="p-8 text-center">
            <div className="text-gray-400 mb-4">
              <svg className="mx-auto h-12 w-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v10a2 2 0 002 2h8a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
              </svg>
            </div>
            <h3 className="text-lg font-medium text-gray-900 mb-2">No transactions found</h3>
            <p className="text-gray-500">Try adjusting your filters to see more results.</p>
          </div>
        ) : (
          <div className="divide-y divide-gray-200">
            {filteredTransactions.map((transaction) => (
              <div
                key={transaction.id}
                className="p-4 hover:bg-gray-50 cursor-pointer"
                onClick={() => setSelectedTransaction(transaction)}
              >
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-4">
                    <div className="text-2xl">{getTransactionIcon(transaction.type)}</div>
                    
                    <div>
                      <div className="flex items-center space-x-2 mb-1">
                        <Badge className={getTypeColor(transaction.type)}>
                          {transaction.type.replace('_', ' ')}
                        </Badge>
                        <Badge className={getStatusColor(transaction.status)}>
                          {transaction.status}
                        </Badge>
                        {transaction.vaultId && (
                          <Badge variant="secondary">
                            Vault #{transaction.vaultId}
                          </Badge>
                        )}
                      </div>
                      
                      <div className="text-sm text-gray-600">
                        {formatDate(transaction.timestamp)} • Block #{transaction.blockNumber.toLocaleString()}
                      </div>
                      
                      <div className="text-xs text-gray-500">
                        {formatAddress(transaction.hash)}
                      </div>
                    </div>
                  </div>
                  
                  <div className="text-right">
                    <div className="text-lg font-semibold text-gray-900">
                      {formatBalance(transaction.amount)} ETH
                    </div>
                    <div className="text-sm text-gray-500">
                      Gas: {formatBalance(transaction.gasUsed * transaction.gasPrice)} ETH
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </Card>

      {/* Transaction Details Modal */}
      {selectedTransaction && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-2xl w-full max-h-96 overflow-y-auto">
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold">Transaction Details</h3>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setSelectedTransaction(null)}
                >
                  ✕
                </Button>
              </div>
              
              <div className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <div className="text-sm text-gray-500">Hash</div>
                    <div className="font-mono text-sm break-all">{selectedTransaction.hash}</div>
                  </div>
                  <div>
                    <div className="text-sm text-gray-500">Type</div>
                    <Badge className={getTypeColor(selectedTransaction.type)}>
                      {selectedTransaction.type.replace('_', ' ')}
                    </Badge>
                  </div>
                  <div>
                    <div className="text-sm text-gray-500">Amount</div>
                    <div className="font-semibold">{formatBalance(selectedTransaction.amount)} ETH</div>
                  </div>
                  <div>
                    <div className="text-sm text-gray-500">Status</div>
                    <Badge className={getStatusColor(selectedTransaction.status)}>
                      {selectedTransaction.status}
                    </Badge>
                  </div>
                  <div>
                    <div className="text-sm text-gray-500">From</div>
                    <div className="font-mono text-sm">{formatAddress(selectedTransaction.from)}</div>
                  </div>
                  <div>
                    <div className="text-sm text-gray-500">To</div>
                    <div className="font-mono text-sm">{formatAddress(selectedTransaction.to)}</div>
                  </div>
                  <div>
                    <div className="text-sm text-gray-500">Gas Used</div>
                    <div>{selectedTransaction.gasUsed.toLocaleString()}</div>
                  </div>
                  <div>
                    <div className="text-sm text-gray-500">Gas Price</div>
                    <div>{(Number(selectedTransaction.gasPrice) / 1e9).toFixed(2)} Gwei</div>
                  </div>
                </div>
                
                {selectedTransaction.metadata && (
                  <div>
                    <div className="text-sm text-gray-500 mb-2">Additional Info</div>
                    <div className="bg-gray-50 p-3 rounded text-sm">
                      {Object.entries(selectedTransaction.metadata).map(([key, value]) => (
                        <div key={key} className="flex justify-between">
                          <span className="capitalize">{key.replace(/([A-Z])/g, ' $1').toLowerCase()}:</span>
                          <span>{typeof value === 'bigint' ? formatBalance(value) + ' ETH' : String(value)}</span>
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
