import React, { useState, useEffect } from 'react';
import { Button } from '../Button';
import { Card } from '../Card';
import { Badge } from '../Badge';
import { Modal } from '../Modal';
import { Input } from '../Input';
import { formatBalance } from '../../utils/format-balance';
import { formatDate } from '../../utils/format-date';

interface VaultTemplate {
  id: string;
  name: string;
  description: string;
  category: 'savings' | 'investment' | 'emergency' | 'goal' | 'retirement';
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  estimatedDuration: number; // in days
  suggestedAmount: {
    min: number;
    max: number;
    recommended: number;
  };
  features: string[];
  configuration: {
    hasTimelock: boolean;
    hasGoal: boolean;
    hasRecurring: boolean;
    hasYield: boolean;
    lockDuration?: number;
    goalAmount?: number;
    recurringAmount?: number;
    recurringFrequency?: 'daily' | 'weekly' | 'monthly';
  };
  popularity: number;
  successRate: number;
  averageReturn: number;
  tags: string[];
  createdBy: 'system' | 'community';
  isVerified: boolean;
}

interface VaultTemplatesProps {
  onSelectTemplate: (template: VaultTemplate) => void;
  className?: string;
}

const VAULT_TEMPLATES: VaultTemplate[] = [
  {
    id: 'emergency-fund',
    name: 'Emergency Fund',
    description: 'Build a safety net for unexpected expenses. Recommended 3-6 months of living expenses.',
    category: 'emergency',
    difficulty: 'beginner',
    estimatedDuration: 180,
    suggestedAmount: { min: 1, max: 10, recommended: 3 },
    features: ['Flexible access', 'No time lock', 'High liquidity'],
    configuration: {
      hasTimelock: false,
      hasGoal: true,
      hasRecurring: true,
      hasYield: false,
      goalAmount: 3,
      recurringAmount: 0.1,
      recurringFrequency: 'monthly'
    },
    popularity: 95,
    successRate: 87,
    averageReturn: 0,
    tags: ['emergency', 'safety', 'flexible'],
    createdBy: 'system',
    isVerified: true
  },
  {
    id: 'house-deposit',
    name: 'House Deposit',
    description: 'Save for your dream home deposit with a structured savings plan.',
    category: 'goal',
    difficulty: 'intermediate',
    estimatedDuration: 1095, // 3 years
    suggestedAmount: { min: 10, max: 100, recommended: 50 },
    features: ['Goal-based', 'Time-locked', 'Yield earning'],
    configuration: {
      hasTimelock: true,
      hasGoal: true,
      hasRecurring: true,
      hasYield: true,
      lockDuration: 1095,
      goalAmount: 50,
      recurringAmount: 1,
      recurringFrequency: 'monthly'
    },
    popularity: 78,
    successRate: 72,
    averageReturn: 4.2,
    tags: ['house', 'property', 'long-term'],
    createdBy: 'system',
    isVerified: true
  },
  {
    id: 'vacation-fund',
    name: 'Vacation Fund',
    description: 'Plan and save for your next adventure with automatic deposits.',
    category: 'goal',
    difficulty: 'beginner',
    estimatedDuration: 365,
    suggestedAmount: { min: 0.5, max: 5, recommended: 2 },
    features: ['Short-term goal', 'Flexible deposits', 'Visual progress'],
    configuration: {
      hasTimelock: false,
      hasGoal: true,
      hasRecurring: true,
      hasYield: false,
      goalAmount: 2,
      recurringAmount: 0.2,
      recurringFrequency: 'monthly'
    },
    popularity: 89,
    successRate: 91,
    averageReturn: 0,
    tags: ['vacation', 'travel', 'short-term'],
    createdBy: 'system',
    isVerified: true
  },
  {
    id: 'retirement-saver',
    name: 'Retirement Saver',
    description: 'Long-term retirement savings with compound yield strategies.',
    category: 'retirement',
    difficulty: 'advanced',
    estimatedDuration: 7300, // 20 years
    suggestedAmount: { min: 5, max: 1000, recommended: 100 },
    features: ['Long-term lock', 'High yield', 'Compound growth'],
    configuration: {
      hasTimelock: true,
      hasGoal: true,
      hasRecurring: true,
      hasYield: true,
      lockDuration: 7300,
      goalAmount: 100,
      recurringAmount: 2,
      recurringFrequency: 'monthly'
    },
    popularity: 65,
    successRate: 85,
    averageReturn: 7.8,
    tags: ['retirement', 'long-term', 'compound'],
    createdBy: 'system',
    isVerified: true
  },
  {
    id: 'crypto-dca',
    name: 'DCA Strategy',
    description: 'Dollar-cost averaging into crypto with automated deposits.',
    category: 'investment',
    difficulty: 'intermediate',
    estimatedDuration: 730, // 2 years
    suggestedAmount: { min: 1, max: 20, recommended: 5 },
    features: ['Automated DCA', 'Risk management', 'Yield optimization'],
    configuration: {
      hasTimelock: false,
      hasGoal: false,
      hasRecurring: true,
      hasYield: true,
      recurringAmount: 0.5,
      recurringFrequency: 'weekly'
    },
    popularity: 73,
    successRate: 68,
    averageReturn: 12.4,
    tags: ['dca', 'crypto', 'automated'],
    createdBy: 'community',
    isVerified: true
  },
  {
    id: 'wedding-fund',
    name: 'Wedding Fund',
    description: 'Save for your special day with milestone-based goals.',
    category: 'goal',
    difficulty: 'beginner',
    estimatedDuration: 545, // 18 months
    suggestedAmount: { min: 5, max: 50, recommended: 20 },
    features: ['Milestone tracking', 'Flexible access', 'Shared savings'],
    configuration: {
      hasTimelock: false,
      hasGoal: true,
      hasRecurring: true,
      hasYield: false,
      goalAmount: 20,
      recurringAmount: 1.2,
      recurringFrequency: 'monthly'
    },
    popularity: 82,
    successRate: 88,
    averageReturn: 0,
    tags: ['wedding', 'milestone', 'shared'],
    createdBy: 'system',
    isVerified: true
  }
];

export function VaultTemplates({ onSelectTemplate, className = '' }: VaultTemplatesProps) {
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [selectedDifficulty, setSelectedDifficulty] = useState<string>('all');
  const [searchTerm, setSearchTerm] = useState('');
  const [showTemplateModal, setShowTemplateModal] = useState(false);
  const [selectedTemplate, setSelectedTemplate] = useState<VaultTemplate | null>(null);
  const [sortBy, setSortBy] = useState<'popularity' | 'success' | 'return'>('popularity');

  const categories = ['all', 'savings', 'investment', 'emergency', 'goal', 'retirement'];
  const difficulties = ['all', 'beginner', 'intermediate', 'advanced'];

  const filteredTemplates = VAULT_TEMPLATES
    .filter(template => {
      const matchesCategory = selectedCategory === 'all' || template.category === selectedCategory;
      const matchesDifficulty = selectedDifficulty === 'all' || template.difficulty === selectedDifficulty;
      const matchesSearch = template.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                           template.description.toLowerCase().includes(searchTerm.toLowerCase()) ||
                           template.tags.some(tag => tag.toLowerCase().includes(searchTerm.toLowerCase()));
      
      return matchesCategory && matchesDifficulty && matchesSearch;
    })
    .sort((a, b) => {
      switch (sortBy) {
        case 'popularity': return b.popularity - a.popularity;
        case 'success': return b.successRate - a.successRate;
        case 'return': return b.averageReturn - a.averageReturn;
        default: return 0;
      }
    });

  const getCategoryColor = (category: VaultTemplate['category']) => {
    const colors = {
      savings: 'bg-blue-100 text-blue-800',
      investment: 'bg-green-100 text-green-800',
      emergency: 'bg-red-100 text-red-800',
      goal: 'bg-purple-100 text-purple-800',
      retirement: 'bg-orange-100 text-orange-800'
    };
    return colors[category] || 'bg-gray-100 text-gray-800';
  };

  const getDifficultyColor = (difficulty: VaultTemplate['difficulty']) => {
    const colors = {
      beginner: 'bg-green-100 text-green-800',
      intermediate: 'bg-yellow-100 text-yellow-800',
      advanced: 'bg-red-100 text-red-800'
    };
    return colors[difficulty] || 'bg-gray-100 text-gray-800';
  };

  const handleTemplateSelect = (template: VaultTemplate) => {
    setSelectedTemplate(template);
    setShowTemplateModal(true);
  };

  const confirmTemplateSelection = () => {
    if (selectedTemplate) {
      onSelectTemplate(selectedTemplate);
      setShowTemplateModal(false);
      setSelectedTemplate(null);
    }
  };

  return (
    <div className={className}>
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Vault Templates</h2>
        <p className="text-gray-600">
          Choose from pre-configured vault templates to get started quickly with proven strategies.
        </p>
      </div>

      {/* Filters */}
      <div className="mb-6 space-y-4">
        <div className="flex flex-wrap gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Category</label>
            <select
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
              className="border border-gray-300 rounded-md px-3 py-2 text-sm"
            >
              {categories.map(category => (
                <option key={category} value={category}>
                  {category.charAt(0).toUpperCase() + category.slice(1)}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Difficulty</label>
            <select
              value={selectedDifficulty}
              onChange={(e) => setSelectedDifficulty(e.target.value)}
              className="border border-gray-300 rounded-md px-3 py-2 text-sm"
            >
              {difficulties.map(difficulty => (
                <option key={difficulty} value={difficulty}>
                  {difficulty.charAt(0).toUpperCase() + difficulty.slice(1)}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Sort By</label>
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value as typeof sortBy)}
              className="border border-gray-300 rounded-md px-3 py-2 text-sm"
            >
              <option value="popularity">Popularity</option>
              <option value="success">Success Rate</option>
              <option value="return">Average Return</option>
            </select>
          </div>
        </div>

        <div>
          <Input
            placeholder="Search templates..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="max-w-md"
          />
        </div>
      </div>

      {/* Templates Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredTemplates.map((template) => (
          <Card key={template.id} className="p-6 hover:shadow-lg transition-shadow cursor-pointer">
            <div className="flex items-start justify-between mb-4">
              <div>
                <h3 className="text-lg font-semibold text-gray-900 mb-1">
                  {template.name}
                </h3>
                <div className="flex items-center space-x-2 mb-2">
                  <Badge className={getCategoryColor(template.category)}>
                    {template.category}
                  </Badge>
                  <Badge className={getDifficultyColor(template.difficulty)}>
                    {template.difficulty}
                  </Badge>
                  {template.isVerified && (
                    <Badge variant="success">Verified</Badge>
                  )}
                </div>
              </div>
              
              <div className="text-right text-sm text-gray-500">
                <div>{template.popularity}% popular</div>
                <div>{template.successRate}% success</div>
              </div>
            </div>

            <p className="text-gray-600 text-sm mb-4 line-clamp-3">
              {template.description}
            </p>

            <div className="space-y-3 mb-4">
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">Duration:</span>
                <span className="font-medium">
                  {Math.round(template.estimatedDuration / 30)} months
                </span>
              </div>
              
              <div className="flex justify-between text-sm">
                <span className="text-gray-500">Suggested Amount:</span>
                <span className="font-medium">
                  {formatBalance(BigInt(Math.floor(template.suggestedAmount.recommended * 1e18)))} ETH
                </span>
              </div>
              
              {template.averageReturn > 0 && (
                <div className="flex justify-between text-sm">
                  <span className="text-gray-500">Avg. Return:</span>
                  <span className="font-medium text-green-600">
                    {template.averageReturn}% APY
                  </span>
                </div>
              )}
            </div>

            <div className="mb-4">
              <div className="text-sm text-gray-500 mb-2">Features:</div>
              <div className="flex flex-wrap gap-1">
                {template.features.slice(0, 3).map((feature, index) => (
                  <Badge key={index} variant="secondary" className="text-xs">
                    {feature}
                  </Badge>
                ))}
                {template.features.length > 3 && (
                  <Badge variant="secondary" className="text-xs">
                    +{template.features.length - 3} more
                  </Badge>
                )}
              </div>
            </div>

            <Button
              onClick={() => handleTemplateSelect(template)}
              className="w-full"
              variant="outline"
            >
              Use Template
            </Button>
          </Card>
        ))}
      </div>

      {filteredTemplates.length === 0 && (
        <div className="text-center py-12">
          <div className="text-gray-400 mb-4">
            <svg className="mx-auto h-12 w-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
          </div>
          <h3 className="text-lg font-medium text-gray-900 mb-2">No templates found</h3>
          <p className="text-gray-500">Try adjusting your filters or search terms.</p>
        </div>
      )}

      {/* Template Details Modal */}
      <Modal
        isOpen={showTemplateModal}
        onClose={() => setShowTemplateModal(false)}
        title={selectedTemplate?.name || ''}
        size="lg"
      >
        {selectedTemplate && (
          <div className="space-y-6">
            <div>
              <p className="text-gray-600 mb-4">{selectedTemplate.description}</p>
              
              <div className="grid grid-cols-2 gap-4 mb-4">
                <div>
                  <div className="text-sm text-gray-500">Category</div>
                  <Badge className={getCategoryColor(selectedTemplate.category)}>
                    {selectedTemplate.category}
                  </Badge>
                </div>
                <div>
                  <div className="text-sm text-gray-500">Difficulty</div>
                  <Badge className={getDifficultyColor(selectedTemplate.difficulty)}>
                    {selectedTemplate.difficulty}
                  </Badge>
                </div>
              </div>
            </div>

            <div>
              <h4 className="font-medium text-gray-900 mb-3">Configuration</h4>
              <div className="space-y-2 text-sm">
                {selectedTemplate.configuration.hasTimelock && (
                  <div className="flex justify-between">
                    <span>Time Lock:</span>
                    <span>{Math.round((selectedTemplate.configuration.lockDuration || 0) / 30)} months</span>
                  </div>
                )}
                {selectedTemplate.configuration.hasGoal && (
                  <div className="flex justify-between">
                    <span>Goal Amount:</span>
                    <span>{selectedTemplate.configuration.goalAmount} ETH</span>
                  </div>
                )}
                {selectedTemplate.configuration.hasRecurring && (
                  <div className="flex justify-between">
                    <span>Recurring Deposits:</span>
                    <span>
                      {selectedTemplate.configuration.recurringAmount} ETH {selectedTemplate.configuration.recurringFrequency}
                    </span>
                  </div>
                )}
                <div className="flex justify-between">
                  <span>Yield Earning:</span>
                  <span>{selectedTemplate.configuration.hasYield ? 'Yes' : 'No'}</span>
                </div>
              </div>
            </div>

            <div>
              <h4 className="font-medium text-gray-900 mb-3">All Features</h4>
              <div className="flex flex-wrap gap-2">
                {selectedTemplate.features.map((feature, index) => (
                  <Badge key={index} variant="secondary">
                    {feature}
                  </Badge>
                ))}
              </div>
            </div>

            <div className="flex space-x-3">
              <Button
                variant="outline"
                onClick={() => setShowTemplateModal(false)}
                className="flex-1"
              >
                Cancel
              </Button>
              <Button
                onClick={confirmTemplateSelection}
                className="flex-1"
              >
                Use This Template
              </Button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  );
}
