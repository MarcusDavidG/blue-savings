import React, { useState } from 'react';
import { Button } from '../Button';
import { Card } from '../Card';
import { useNotify } from '../../contexts/NotificationContext';
import { formatDate } from '../../utils/format-date';

interface VaultData {
  id: number;
  name: string;
  description: string;
  balance: string;
  goalAmount: string;
  unlockTimestamp: number;
  createdAt: number;
  deposits: Array<{
    amount: string;
    timestamp: number;
    txHash: string;
  }>;
  withdrawals: Array<{
    amount: string;
    timestamp: number;
    txHash: string;
  }>;
}

interface VaultBackupExportProps {
  vaults: VaultData[];
  className?: string;
}

export function VaultBackupExport({ vaults, className = '' }: VaultBackupExportProps) {
  const [isExporting, setIsExporting] = useState(false);
  const [exportFormat, setExportFormat] = useState<'json' | 'csv'>('json');
  const notify = useNotify();

  const exportToJSON = (data: VaultData[]) => {
    const exportData = {
      exportedAt: new Date().toISOString(),
      version: '1.0',
      totalVaults: data.length,
      vaults: data.map(vault => ({
        ...vault,
        createdAtFormatted: formatDate(vault.createdAt),
        unlockTimestampFormatted: vault.unlockTimestamp > 0 ? formatDate(vault.unlockTimestamp) : 'No lock',
        totalDeposits: vault.deposits.reduce((sum, deposit) => sum + parseFloat(deposit.amount), 0),
        totalWithdrawals: vault.withdrawals.reduce((sum, withdrawal) => sum + parseFloat(withdrawal.amount), 0)
      }))
    };

    const blob = new Blob([JSON.stringify(exportData, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `vault-backup-${new Date().toISOString().split('T')[0]}.json`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  };

  const exportToCSV = (data: VaultData[]) => {
    const headers = [
      'Vault ID',
      'Name',
      'Description',
      'Current Balance (ETH)',
      'Goal Amount (ETH)',
      'Unlock Date',
      'Created Date',
      'Total Deposits',
      'Total Withdrawals',
      'Deposit Count',
      'Withdrawal Count',
      'Status'
    ];

    const rows = data.map(vault => [
      vault.id,
      `"${vault.name}"`,
      `"${vault.description}"`,
      vault.balance,
      vault.goalAmount,
      vault.unlockTimestamp > 0 ? formatDate(vault.unlockTimestamp) : 'No lock',
      formatDate(vault.createdAt),
      vault.deposits.reduce((sum, deposit) => sum + parseFloat(deposit.amount), 0),
      vault.withdrawals.reduce((sum, withdrawal) => sum + parseFloat(withdrawal.amount), 0),
      vault.deposits.length,
      vault.withdrawals.length,
      vault.unlockTimestamp > 0 && vault.unlockTimestamp > Date.now() ? 'Locked' : 'Unlocked'
    ]);

    const csvContent = [headers.join(','), ...rows.map(row => row.join(','))].join('\n');
    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `vault-export-${new Date().toISOString().split('T')[0]}.csv`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
  };

  const handleExport = async () => {
    if (!vaults.length) {
      notify.warning('No Data', 'No vaults available to export.');
      return;
    }

    setIsExporting(true);
    
    try {
      // Simulate processing time
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      if (exportFormat === 'json') {
        exportToJSON(vaults);
        notify.success('Export Complete', `Successfully exported ${vaults.length} vaults to JSON format.`);
      } else {
        exportToCSV(vaults);
        notify.success('Export Complete', `Successfully exported ${vaults.length} vaults to CSV format.`);
      }
    } catch (error) {
      notify.error('Export Failed', 'An error occurred while exporting your vault data.');
      console.error('Export error:', error);
    } finally {
      setIsExporting(false);
    }
  };

  const createBackup = async () => {
    if (!vaults.length) {
      notify.warning('No Data', 'No vaults available to backup.');
      return;
    }

    try {
      const backupData = {
        timestamp: Date.now(),
        version: '1.0',
        userAddress: 'current-user-address', // Would come from wallet context
        vaults: vaults,
        metadata: {
          totalVaults: vaults.length,
          totalValue: vaults.reduce((sum, vault) => sum + parseFloat(vault.balance), 0),
          createdAt: new Date().toISOString()
        }
      };

      // Store in localStorage as backup
      const backupKey = `vault-backup-${Date.now()}`;
      localStorage.setItem(backupKey, JSON.stringify(backupData));

      // Also download as file
      const blob = new Blob([JSON.stringify(backupData, null, 2)], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = `vault-backup-${new Date().toISOString().split('T')[0]}.json`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);

      notify.success('Backup Created', 'Your vault data has been backed up locally and downloaded.');
    } catch (error) {
      notify.error('Backup Failed', 'An error occurred while creating the backup.');
      console.error('Backup error:', error);
    }
  };

  const getStoredBackups = () => {
    const backups = [];
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key && key.startsWith('vault-backup-')) {
        try {
          const data = JSON.parse(localStorage.getItem(key) || '{}');
          backups.push({
            key,
            timestamp: data.timestamp,
            vaultCount: data.vaults?.length || 0,
            totalValue: data.metadata?.totalValue || 0
          });
        } catch (error) {
          console.error('Error parsing backup:', error);
        }
      }
    }
    return backups.sort((a, b) => b.timestamp - a.timestamp);
  };

  const storedBackups = getStoredBackups();

  return (
    <Card className={`p-6 ${className}`}>
      <h3 className="text-lg font-semibold text-gray-900 mb-4">Backup & Export</h3>
      
      <div className="space-y-6">
        {/* Export Section */}
        <div>
          <h4 className="text-md font-medium text-gray-700 mb-3">Export Vault Data</h4>
          <div className="flex items-center space-x-4 mb-4">
            <label className="flex items-center">
              <input
                type="radio"
                name="exportFormat"
                value="json"
                checked={exportFormat === 'json'}
                onChange={(e) => setExportFormat(e.target.value as 'json')}
                className="mr-2"
              />
              JSON (Complete data with transaction history)
            </label>
            <label className="flex items-center">
              <input
                type="radio"
                name="exportFormat"
                value="csv"
                checked={exportFormat === 'csv'}
                onChange={(e) => setExportFormat(e.target.value as 'csv')}
                className="mr-2"
              />
              CSV (Summary data for spreadsheets)
            </label>
          </div>
          
          <Button
            onClick={handleExport}
            disabled={isExporting || !vaults.length}
            className="w-full sm:w-auto"
          >
            {isExporting ? 'Exporting...' : `Export ${vaults.length} Vaults`}
          </Button>
        </div>

        {/* Backup Section */}
        <div className="border-t pt-6">
          <h4 className="text-md font-medium text-gray-700 mb-3">Create Backup</h4>
          <p className="text-sm text-gray-600 mb-4">
            Create a complete backup of your vault data including transaction history and metadata.
            Backups are stored locally and downloaded as files.
          </p>
          
          <Button
            onClick={createBackup}
            variant="outline"
            disabled={!vaults.length}
            className="w-full sm:w-auto"
          >
            Create Backup
          </Button>
        </div>

        {/* Stored Backups */}
        {storedBackups.length > 0 && (
          <div className="border-t pt-6">
            <h4 className="text-md font-medium text-gray-700 mb-3">Local Backups</h4>
            <div className="space-y-2">
              {storedBackups.slice(0, 5).map((backup) => (
                <div key={backup.key} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                  <div>
                    <div className="text-sm font-medium">
                      {formatDate(backup.timestamp)}
                    </div>
                    <div className="text-xs text-gray-500">
                      {backup.vaultCount} vaults • {backup.totalValue.toFixed(4)} ETH total
                    </div>
                  </div>
                  <Button
                    size="sm"
                    variant="ghost"
                    onClick={() => {
                      const data = localStorage.getItem(backup.key);
                      if (data) {
                        const blob = new Blob([data], { type: 'application/json' });
                        const url = URL.createObjectURL(blob);
                        const link = document.createElement('a');
                        link.href = url;
                        link.download = `${backup.key}.json`;
                        link.click();
                        URL.revokeObjectURL(url);
                      }
                    }}
                  >
                    Download
                  </Button>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Info */}
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
          <div className="flex">
            <div className="flex-shrink-0">
              <svg className="h-5 w-5 text-blue-400" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clipRule="evenodd" />
              </svg>
            </div>
            <div className="ml-3">
              <h3 className="text-sm font-medium text-blue-800">
                Data Security
              </h3>
              <div className="mt-2 text-sm text-blue-700">
                <p>
                  Your vault data is exported directly from the blockchain and stored locally. 
                  No sensitive information is transmitted to external servers.
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Card>
  );
}
