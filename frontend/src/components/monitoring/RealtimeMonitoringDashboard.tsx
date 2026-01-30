import React, { useState, useEffect } from 'react';
import { useContract } from '../hooks/useContract';
import { formatBalance } from '../utils/format-balance';
import { Card } from '../components/Card';
import { Spinner } from '../components/Spinner';

interface VaultMetrics {
  totalVaults: number;
  totalValue: bigint;
  activeVaults: number;
  averageBalance: bigint;
  successRate: number;
}

interface RealtimeData {
  metrics: VaultMetrics;
  recentActivity: Array<{
    type: 'deposit' | 'withdraw' | 'create';
    amount: bigint;
    timestamp: number;
    vaultId: number;
  }>;
}

export function RealtimeMonitoringDashboard() {
  const [data, setData] = useState<RealtimeData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { contract } = useContract();

  useEffect(() => {
    const fetchMetrics = async () => {
      try {
        if (!contract) return;

        // Fetch vault metrics
        const totalVaults = await contract.read.vaultCounter();
        const totalValue = await contract.read.getTotalValue();
        const activeVaults = await contract.read.getActiveVaultCount();
        
        const metrics: VaultMetrics = {
          totalVaults: Number(totalVaults),
          totalValue,
          activeVaults: Number(activeVaults),
          averageBalance: totalValue / BigInt(Math.max(Number(totalVaults), 1)),
          successRate: 85.5 // Mock data - would come from analytics
        };

        // Fetch recent activity (mock data for now)
        const recentActivity = [
          {
            type: 'deposit' as const,
            amount: BigInt('1000000000000000000'), // 1 ETH
            timestamp: Date.now() - 300000, // 5 minutes ago
            vaultId: 123
          },
          {
            type: 'create' as const,
            amount: BigInt('500000000000000000'), // 0.5 ETH
            timestamp: Date.now() - 600000, // 10 minutes ago
            vaultId: 124
          }
        ];

        setData({ metrics, recentActivity });
        setLoading(false);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Failed to fetch data');
        setLoading(false);
      }
    };

    fetchMetrics();
    const interval = setInterval(fetchMetrics, 30000); // Update every 30 seconds

    return () => clearInterval(interval);
  }, [contract]);

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <Spinner />
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-red-500 text-center p-4">
        Error: {error}
      </div>
    );
  }

  if (!data) return null;

  return (
    <div className="space-y-6">
      <h2 className="text-2xl font-bold text-gray-900">Real-time Monitoring</h2>
      
      {/* Metrics Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card className="p-4">
          <div className="text-sm text-gray-500">Total Vaults</div>
          <div className="text-2xl font-bold text-blue-600">
            {data.metrics.totalVaults.toLocaleString()}
          </div>
        </Card>
        
        <Card className="p-4">
          <div className="text-sm text-gray-500">Total Value Locked</div>
          <div className="text-2xl font-bold text-green-600">
            {formatBalance(data.metrics.totalValue)} ETH
          </div>
        </Card>
        
        <Card className="p-4">
          <div className="text-sm text-gray-500">Active Vaults</div>
          <div className="text-2xl font-bold text-purple-600">
            {data.metrics.activeVaults.toLocaleString()}
          </div>
        </Card>
        
        <Card className="p-4">
          <div className="text-sm text-gray-500">Success Rate</div>
          <div className="text-2xl font-bold text-orange-600">
            {data.metrics.successRate}%
          </div>
        </Card>
      </div>

      {/* Recent Activity */}
      <Card className="p-6">
        <h3 className="text-lg font-semibold mb-4">Recent Activity</h3>
        <div className="space-y-3">
          {data.recentActivity.map((activity, index) => (
            <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
              <div className="flex items-center space-x-3">
                <div className={`w-3 h-3 rounded-full ${
                  activity.type === 'deposit' ? 'bg-green-500' :
                  activity.type === 'withdraw' ? 'bg-red-500' : 'bg-blue-500'
                }`} />
                <div>
                  <div className="font-medium capitalize">{activity.type}</div>
                  <div className="text-sm text-gray-500">
                    Vault #{activity.vaultId}
                  </div>
                </div>
              </div>
              <div className="text-right">
                <div className="font-medium">
                  {formatBalance(activity.amount)} ETH
                </div>
                <div className="text-sm text-gray-500">
                  {new Date(activity.timestamp).toLocaleTimeString()}
                </div>
              </div>
            </div>
          ))}
        </div>
      </Card>

      {/* Live Status Indicator */}
      <div className="flex items-center justify-center space-x-2 text-sm text-gray-500">
        <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
        <span>Live data - Updates every 30 seconds</span>
      </div>
    </div>
  );
}
