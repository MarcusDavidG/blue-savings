import React, { useState, useEffect, useMemo } from 'react';
import { Card } from '../Card';
import { Select } from '../form/Select';
import { Button } from '../Button';

interface PerformanceDataPoint {
  timestamp: number;
  balance: number;
  deposits: number;
  withdrawals: number;
  yield: number;
}

interface VaultPerformanceChartProps {
  vaultId: number;
  className?: string;
}

export function VaultPerformanceChart({ vaultId, className = '' }: VaultPerformanceChartProps) {
  const [data, setData] = useState<PerformanceDataPoint[]>([]);
  const [timeRange, setTimeRange] = useState<'7d' | '30d' | '90d' | '1y'>('30d');
  const [chartType, setChartType] = useState<'balance' | 'yield' | 'activity'>('balance');
  const [loading, setLoading] = useState(true);

  // Mock data generation - in real app, this would come from API
  useEffect(() => {
    const generateMockData = () => {
      const now = Date.now();
      const days = timeRange === '7d' ? 7 : timeRange === '30d' ? 30 : timeRange === '90d' ? 90 : 365;
      const points: PerformanceDataPoint[] = [];
      
      let balance = 1000; // Starting balance
      
      for (let i = days; i >= 0; i--) {
        const timestamp = now - (i * 24 * 60 * 60 * 1000);
        const dailyYield = balance * 0.0001 * Math.random(); // Random yield
        const deposits = Math.random() > 0.8 ? Math.random() * 500 : 0;
        const withdrawals = Math.random() > 0.9 ? Math.random() * 200 : 0;
        
        balance += dailyYield + deposits - withdrawals;
        
        points.push({
          timestamp,
          balance: Math.max(0, balance),
          deposits,
          withdrawals,
          yield: dailyYield
        });
      }
      
      setData(points);
      setLoading(false);
    };

    setLoading(true);
    setTimeout(generateMockData, 500); // Simulate API delay
  }, [vaultId, timeRange]);

  const chartData = useMemo(() => {
    if (!data.length) return { values: [], labels: [], maxValue: 0 };
    
    const values = data.map(point => {
      switch (chartType) {
        case 'balance': return point.balance;
        case 'yield': return point.yield;
        case 'activity': return point.deposits + point.withdrawals;
        default: return point.balance;
      }
    });
    
    const labels = data.map(point => 
      new Date(point.timestamp).toLocaleDateString('en-US', { 
        month: 'short', 
        day: 'numeric' 
      })
    );
    
    const maxValue = Math.max(...values);
    
    return { values, labels, maxValue };
  }, [data, chartType]);

  const renderSVGChart = () => {
    if (!chartData.values.length) return null;
    
    const width = 600;
    const height = 300;
    const padding = 40;
    const chartWidth = width - 2 * padding;
    const chartHeight = height - 2 * padding;
    
    const points = chartData.values.map((value, index) => {
      const x = padding + (index / (chartData.values.length - 1)) * chartWidth;
      const y = padding + (1 - value / chartData.maxValue) * chartHeight;
      return `${x},${y}`;
    }).join(' ');
    
    const pathD = `M ${points.split(' ').map((point, index) => 
      index === 0 ? `M ${point}` : `L ${point}`
    ).join(' ')}`;
    
    return (
      <svg width="100%" height="300" viewBox={`0 0 ${width} ${height}`} className="overflow-visible">
        {/* Grid lines */}
        <defs>
          <pattern id="grid" width="50" height="30" patternUnits="userSpaceOnUse">
            <path d="M 50 0 L 0 0 0 30" fill="none" stroke="#f3f4f6" strokeWidth="1"/>
          </pattern>
        </defs>
        <rect width={chartWidth} height={chartHeight} x={padding} y={padding} fill="url(#grid)" />
        
        {/* Chart area */}
        <path
          d={pathD}
          fill="none"
          stroke={chartType === 'balance' ? '#3b82f6' : chartType === 'yield' ? '#10b981' : '#f59e0b'}
          strokeWidth="2"
          className="drop-shadow-sm"
        />
        
        {/* Data points */}
        {chartData.values.map((value, index) => {
          const x = padding + (index / (chartData.values.length - 1)) * chartWidth;
          const y = padding + (1 - value / chartData.maxValue) * chartHeight;
          return (
            <circle
              key={index}
              cx={x}
              cy={y}
              r="3"
              fill={chartType === 'balance' ? '#3b82f6' : chartType === 'yield' ? '#10b981' : '#f59e0b'}
              className="hover:r-4 transition-all cursor-pointer"
            >
              <title>{`${chartData.labels[index]}: ${value.toFixed(4)} ETH`}</title>
            </circle>
          );
        })}
        
        {/* Y-axis labels */}
        {[0, 0.25, 0.5, 0.75, 1].map(ratio => (
          <g key={ratio}>
            <text
              x={padding - 10}
              y={padding + (1 - ratio) * chartHeight + 5}
              textAnchor="end"
              className="text-xs fill-gray-500"
            >
              {(chartData.maxValue * ratio).toFixed(2)}
            </text>
            <line
              x1={padding}
              y1={padding + (1 - ratio) * chartHeight}
              x2={padding + chartWidth}
              y2={padding + (1 - ratio) * chartHeight}
              stroke="#e5e7eb"
              strokeWidth="1"
              strokeDasharray="2,2"
            />
          </g>
        ))}
        
        {/* X-axis labels */}
        {chartData.labels.filter((_, index) => index % Math.ceil(chartData.labels.length / 6) === 0).map((label, index) => {
          const originalIndex = index * Math.ceil(chartData.labels.length / 6);
          const x = padding + (originalIndex / (chartData.values.length - 1)) * chartWidth;
          return (
            <text
              key={index}
              x={x}
              y={height - 10}
              textAnchor="middle"
              className="text-xs fill-gray-500"
            >
              {label}
            </text>
          );
        })}
      </svg>
    );
  };

  const timeRangeOptions = [
    { value: '7d', label: '7 Days' },
    { value: '30d', label: '30 Days' },
    { value: '90d', label: '90 Days' },
    { value: '1y', label: '1 Year' }
  ];

  const chartTypeOptions = [
    { value: 'balance', label: 'Balance' },
    { value: 'yield', label: 'Yield' },
    { value: 'activity', label: 'Activity' }
  ];

  return (
    <Card className={`p-6 ${className}`}>
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-lg font-semibold text-gray-900">Performance Analytics</h3>
        
        <div className="flex items-center space-x-3">
          <Select
            value={chartType}
            onChange={(value) => setChartType(value as typeof chartType)}
            options={chartTypeOptions}
            className="w-32"
          />
          
          <Select
            value={timeRange}
            onChange={(value) => setTimeRange(value as typeof timeRange)}
            options={timeRangeOptions}
            className="w-32"
          />
        </div>
      </div>

      {loading ? (
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        </div>
      ) : (
        <div className="space-y-4">
          <div className="bg-gray-50 rounded-lg p-4 overflow-x-auto">
            {renderSVGChart()}
          </div>
          
          {/* Summary Stats */}
          <div className="grid grid-cols-3 gap-4 text-center">
            <div>
              <div className="text-sm text-gray-500">Current Balance</div>
              <div className="text-lg font-semibold text-blue-600">
                {data[data.length - 1]?.balance.toFixed(4) || '0'} ETH
              </div>
            </div>
            <div>
              <div className="text-sm text-gray-500">Total Yield</div>
              <div className="text-lg font-semibold text-green-600">
                {data.reduce((sum, point) => sum + point.yield, 0).toFixed(4)} ETH
              </div>
            </div>
            <div>
              <div className="text-sm text-gray-500">Growth Rate</div>
              <div className="text-lg font-semibold text-purple-600">
                {data.length > 1 ? 
                  (((data[data.length - 1]?.balance || 0) / (data[0]?.balance || 1) - 1) * 100).toFixed(2) 
                  : '0'
                }%
              </div>
            </div>
          </div>
        </div>
      )}
    </Card>
  );
}
