import React, { useState, useEffect, useMemo } from 'react';
import { Card } from '../Card';
import { Badge } from '../Badge';
import { Button } from '../Button';
import { formatBalance } from '../../utils/format-balance';

interface PerformanceMetrics {
  timestamp: number;
  totalVaults: number;
  totalValueLocked: bigint;
  activeUsers: number;
  transactionCount: number;
  averageGasPrice: number;
  networkLatency: number;
  errorRate: number;
  uptime: number;
  throughput: number; // transactions per second
}

interface SystemHealth {
  overall: 'excellent' | 'good' | 'warning' | 'critical';
  components: {
    contracts: 'healthy' | 'degraded' | 'down';
    frontend: 'healthy' | 'degraded' | 'down';
    api: 'healthy' | 'degraded' | 'down';
    blockchain: 'healthy' | 'degraded' | 'down';
  };
  alerts: Array<{
    id: string;
    level: 'info' | 'warning' | 'error' | 'critical';
    message: string;
    timestamp: number;
    component: string;
  }>;
}

interface PerformanceAlert {
  id: string;
  type: 'high_gas' | 'low_throughput' | 'high_error_rate' | 'network_congestion' | 'contract_issue';
  severity: 'low' | 'medium' | 'high' | 'critical';
  message: string;
  timestamp: number;
  resolved: boolean;
  resolvedAt?: number;
}

interface PerformanceMonitoringProps {
  className?: string;
}

export function PerformanceMonitoring({ className = '' }: PerformanceMonitoringProps) {
  const [metrics, setMetrics] = useState<PerformanceMetrics[]>([]);
  const [systemHealth, setSystemHealth] = useState<SystemHealth>({
    overall: 'good',
    components: {
      contracts: 'healthy',
      frontend: 'healthy',
      api: 'healthy',
      blockchain: 'healthy'
    },
    alerts: []
  });
  const [alerts, setAlerts] = useState<PerformanceAlert[]>([]);
  const [timeRange, setTimeRange] = useState<'1h' | '24h' | '7d' | '30d'>('24h');
  const [autoRefresh, setAutoRefresh] = useState(true);
  const [isLoading, setIsLoading] = useState(true);

  // Simulate real-time data updates
  useEffect(() => {
    const generateMockMetrics = (): PerformanceMetrics => ({
      timestamp: Date.now(),
      totalVaults: Math.floor(Math.random() * 1000) + 500,
      totalValueLocked: BigInt(Math.floor((Math.random() * 1000 + 100) * 1e18)),
      activeUsers: Math.floor(Math.random() * 200) + 50,
      transactionCount: Math.floor(Math.random() * 1000) + 100,
      averageGasPrice: Math.random() * 50 + 10,
      networkLatency: Math.random() * 500 + 100,
      errorRate: Math.random() * 5,
      uptime: 99.5 + Math.random() * 0.5,
      throughput: Math.random() * 10 + 5
    });

    const generateMockAlerts = (): PerformanceAlert[] => [
      {
        id: '1',
        type: 'high_gas',
        severity: 'medium',
        message: 'Gas prices are above 30 Gwei',
        timestamp: Date.now() - 300000,
        resolved: false
      },
      {
        id: '2',
        type: 'low_throughput',
        severity: 'low',
        message: 'Transaction throughput below expected levels',
        timestamp: Date.now() - 600000,
        resolved: true,
        resolvedAt: Date.now() - 300000
      }
    ];

    // Initial data load
    const initialMetrics = Array.from({ length: 24 }, (_, i) => ({
      ...generateMockMetrics(),
      timestamp: Date.now() - (23 - i) * 60 * 60 * 1000
    }));

    setMetrics(initialMetrics);
    setAlerts(generateMockAlerts());
    setIsLoading(false);

    // Auto-refresh interval
    let interval: NodeJS.Timeout;
    if (autoRefresh) {
      interval = setInterval(() => {
        setMetrics(prev => [...prev.slice(1), generateMockMetrics()]);
        
        // Update system health
        setSystemHealth(prev => ({
          ...prev,
          overall: Math.random() > 0.1 ? 'good' : 'warning',
          components: {
            contracts: Math.random() > 0.05 ? 'healthy' : 'degraded',
            frontend: Math.random() > 0.05 ? 'healthy' : 'degraded',
            api: Math.random() > 0.05 ? 'healthy' : 'degraded',
            blockchain: Math.random() > 0.02 ? 'healthy' : 'degraded'
          }
        }));
      }, 30000); // Update every 30 seconds
    }

    return () => {
      if (interval) clearInterval(interval);
    };
  }, [autoRefresh]);

  const currentMetrics = metrics[metrics.length - 1];
  const previousMetrics = metrics[metrics.length - 2];

  const calculateChange = (current: number, previous: number): { value: number; isPositive: boolean } => {
    if (!previous) return { value: 0, isPositive: true };
    const change = ((current - previous) / previous) * 100;
    return { value: Math.abs(change), isPositive: change >= 0 };
  };

  const getHealthColor = (status: string) => {
    switch (status) {
      case 'excellent':
      case 'healthy':
        return 'bg-green-100 text-green-800';
      case 'good':
        return 'bg-blue-100 text-blue-800';
      case 'warning':
      case 'degraded':
        return 'bg-yellow-100 text-yellow-800';
      case 'critical':
      case 'down':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const getSeverityColor = (severity: string) => {
    switch (severity) {
      case 'low':
        return 'bg-blue-100 text-blue-800';
      case 'medium':
        return 'bg-yellow-100 text-yellow-800';
      case 'high':
        return 'bg-orange-100 text-orange-800';
      case 'critical':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const activeAlerts = alerts.filter(alert => !alert.resolved);
  const resolvedAlerts = alerts.filter(alert => alert.resolved);

  const renderMetricCard = (
    title: string,
    value: string | number,
    change?: { value: number; isPositive: boolean },
    unit?: string,
    status?: 'good' | 'warning' | 'critical'
  ) => (
    <Card className="p-4">
      <div className="flex items-center justify-between mb-2">
        <h3 className="text-sm font-medium text-gray-500">{title}</h3>
        {status && (
          <div className={`w-3 h-3 rounded-full ${
            status === 'good' ? 'bg-green-500' :
            status === 'warning' ? 'bg-yellow-500' : 'bg-red-500'
          }`} />
        )}
      </div>
      <div className="flex items-end justify-between">
        <div>
          <div className="text-2xl font-bold text-gray-900">
            {value}{unit && <span className="text-sm text-gray-500 ml-1">{unit}</span>}
          </div>
          {change && (
            <div className={`text-sm ${change.isPositive ? 'text-green-600' : 'text-red-600'}`}>
              {change.isPositive ? '↗' : '↘'} {change.value.toFixed(1)}%
            </div>
          )}
        </div>
      </div>
    </Card>
  );

  const renderChart = (data: number[], label: string, color: string) => (
    <div className="h-32 flex items-end space-x-1">
      {data.slice(-20).map((value, index) => {
        const maxValue = Math.max(...data.slice(-20));
        const height = (value / maxValue) * 100;
        return (
          <div
            key={index}
            className={`flex-1 ${color} rounded-t`}
            style={{ height: `${height}%` }}
            title={`${label}: ${value}`}
          />
        );
      })}
    </div>
  );

  if (isLoading) {
    return (
      <div className={`${className} animate-pulse`}>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
          {[...Array(8)].map((_, i) => (
            <div key={i} className="h-24 bg-gray-200 rounded-lg" />
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className={className}>
      <div className="flex items-center justify-between mb-6">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Performance Monitoring</h2>
          <p className="text-gray-600">Real-time system performance and health metrics</p>
        </div>
        
        <div className="flex items-center space-x-4">
          <select
            value={timeRange}
            onChange={(e) => setTimeRange(e.target.value as typeof timeRange)}
            className="border border-gray-300 rounded-md px-3 py-2 text-sm"
          >
            <option value="1h">Last Hour</option>
            <option value="24h">Last 24 Hours</option>
            <option value="7d">Last 7 Days</option>
            <option value="30d">Last 30 Days</option>
          </select>
          
          <Button
            variant={autoRefresh ? 'default' : 'outline'}
            size="sm"
            onClick={() => setAutoRefresh(!autoRefresh)}
          >
            {autoRefresh ? 'Auto-refresh On' : 'Auto-refresh Off'}
          </Button>
        </div>
      </div>

      {/* System Health Overview */}
      <Card className="p-6 mb-6">
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-gray-900">System Health</h3>
          <Badge className={getHealthColor(systemHealth.overall)}>
            {systemHealth.overall.toUpperCase()}
          </Badge>
        </div>
        
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {Object.entries(systemHealth.components).map(([component, status]) => (
            <div key={component} className="text-center">
              <div className={`w-12 h-12 rounded-full mx-auto mb-2 flex items-center justify-center ${getHealthColor(status)}`}>
                <div className={`w-6 h-6 rounded-full ${
                  status === 'healthy' ? 'bg-green-500' :
                  status === 'degraded' ? 'bg-yellow-500' : 'bg-red-500'
                }`} />
              </div>
              <div className="text-sm font-medium text-gray-900 capitalize">{component}</div>
              <div className={`text-xs capitalize ${
                status === 'healthy' ? 'text-green-600' :
                status === 'degraded' ? 'text-yellow-600' : 'text-red-600'
              }`}>
                {status}
              </div>
            </div>
          ))}
        </div>
      </Card>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
        {currentMetrics && previousMetrics && (
          <>
            {renderMetricCard(
              'Total Value Locked',
              formatBalance(currentMetrics.totalValueLocked),
              calculateChange(Number(currentMetrics.totalValueLocked), Number(previousMetrics.totalValueLocked)),
              'ETH',
              'good'
            )}
            
            {renderMetricCard(
              'Active Vaults',
              currentMetrics.totalVaults.toLocaleString(),
              calculateChange(currentMetrics.totalVaults, previousMetrics.totalVaults),
              undefined,
              'good'
            )}
            
            {renderMetricCard(
              'Active Users',
              currentMetrics.activeUsers.toLocaleString(),
              calculateChange(currentMetrics.activeUsers, previousMetrics.activeUsers),
              undefined,
              'good'
            )}
            
            {renderMetricCard(
              'Transactions/Hour',
              currentMetrics.transactionCount.toLocaleString(),
              calculateChange(currentMetrics.transactionCount, previousMetrics.transactionCount),
              undefined,
              currentMetrics.transactionCount > 500 ? 'good' : 'warning'
            )}
            
            {renderMetricCard(
              'Average Gas Price',
              currentMetrics.averageGasPrice.toFixed(1),
              calculateChange(currentMetrics.averageGasPrice, previousMetrics.averageGasPrice),
              'Gwei',
              currentMetrics.averageGasPrice < 30 ? 'good' : currentMetrics.averageGasPrice < 50 ? 'warning' : 'critical'
            )}
            
            {renderMetricCard(
              'Network Latency',
              Math.round(currentMetrics.networkLatency).toString(),
              calculateChange(currentMetrics.networkLatency, previousMetrics.networkLatency),
              'ms',
              currentMetrics.networkLatency < 300 ? 'good' : currentMetrics.networkLatency < 500 ? 'warning' : 'critical'
            )}
            
            {renderMetricCard(
              'Error Rate',
              currentMetrics.errorRate.toFixed(2),
              calculateChange(currentMetrics.errorRate, previousMetrics.errorRate),
              '%',
              currentMetrics.errorRate < 1 ? 'good' : currentMetrics.errorRate < 3 ? 'warning' : 'critical'
            )}
            
            {renderMetricCard(
              'Uptime',
              currentMetrics.uptime.toFixed(2),
              calculateChange(currentMetrics.uptime, previousMetrics.uptime),
              '%',
              currentMetrics.uptime > 99 ? 'good' : currentMetrics.uptime > 95 ? 'warning' : 'critical'
            )}
          </>
        )}
      </div>

      {/* Performance Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <Card className="p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Transaction Volume</h3>
          {renderChart(
            metrics.map(m => m.transactionCount),
            'Transactions',
            'bg-blue-500'
          )}
        </Card>
        
        <Card className="p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Gas Price Trend</h3>
          {renderChart(
            metrics.map(m => m.averageGasPrice),
            'Gas Price (Gwei)',
            'bg-orange-500'
          )}
        </Card>
        
        <Card className="p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Network Latency</h3>
          {renderChart(
            metrics.map(m => m.networkLatency),
            'Latency (ms)',
            'bg-purple-500'
          )}
        </Card>
        
        <Card className="p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">Error Rate</h3>
          {renderChart(
            metrics.map(m => m.errorRate),
            'Error Rate (%)',
            'bg-red-500'
          )}
        </Card>
      </div>

      {/* Alerts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card className="p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">
            Active Alerts ({activeAlerts.length})
          </h3>
          
          {activeAlerts.length === 0 ? (
            <div className="text-center py-8 text-gray-500">
              <div className="text-green-500 mb-2">✓</div>
              <p>No active alerts</p>
            </div>
          ) : (
            <div className="space-y-3">
              {activeAlerts.map(alert => (
                <div key={alert.id} className="flex items-start space-x-3 p-3 bg-gray-50 rounded-lg">
                  <Badge className={getSeverityColor(alert.severity)}>
                    {alert.severity}
                  </Badge>
                  <div className="flex-1">
                    <p className="text-sm font-medium text-gray-900">{alert.message}</p>
                    <p className="text-xs text-gray-500">
                      {new Date(alert.timestamp).toLocaleString()} • {alert.component}
                    </p>
                  </div>
                  <Button size="sm" variant="ghost">
                    Resolve
                  </Button>
                </div>
              ))}
            </div>
          )}
        </Card>
        
        <Card className="p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-4">
            Recent Activity
          </h3>
          
          <div className="space-y-3">
            {resolvedAlerts.slice(0, 5).map(alert => (
              <div key={alert.id} className="flex items-start space-x-3 p-3 bg-green-50 rounded-lg">
                <div className="text-green-500 text-sm">✓</div>
                <div className="flex-1">
                  <p className="text-sm text-gray-900">{alert.message}</p>
                  <p className="text-xs text-gray-500">
                    Resolved {alert.resolvedAt ? new Date(alert.resolvedAt).toLocaleString() : 'recently'}
                  </p>
                </div>
              </div>
            ))}
            
            {resolvedAlerts.length === 0 && (
              <div className="text-center py-8 text-gray-500">
                <p>No recent activity</p>
              </div>
            )}
          </div>
        </Card>
      </div>
    </div>
  );
}
