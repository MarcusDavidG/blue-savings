import React, { useState, useEffect } from 'react';
import { Button } from '../Button';
import { Input } from '../Input';
import { Card } from '../Card';
import { Modal } from '../Modal';
import { Badge } from '../Badge';
import { useNotify } from '../../contexts/NotificationContext';
import { formatAddress } from '../../utils/format-address';
import { formatBalance } from '../../utils/format-balance';

interface VaultCollaborator {
  address: string;
  role: 'viewer' | 'contributor' | 'manager';
  addedAt: number;
  permissions: {
    canView: boolean;
    canDeposit: boolean;
    canWithdraw: boolean;
    canManage: boolean;
  };
}

interface SharedVault {
  id: number;
  name: string;
  description: string;
  owner: string;
  balance: bigint;
  collaborators: VaultCollaborator[];
  shareCode: string;
  isPublic: boolean;
  createdAt: number;
}

interface VaultSharingProps {
  vault: SharedVault;
  isOwner: boolean;
  onUpdate: (vault: SharedVault) => void;
  className?: string;
}

export function VaultSharing({ vault, isOwner, onUpdate, className = '' }: VaultSharingProps) {
  const [showShareModal, setShowShareModal] = useState(false);
  const [showInviteModal, setShowInviteModal] = useState(false);
  const [inviteAddress, setInviteAddress] = useState('');
  const [inviteRole, setInviteRole] = useState<VaultCollaborator['role']>('viewer');
  const [shareLink, setShareLink] = useState('');
  const [isGeneratingLink, setIsGeneratingLink] = useState(false);
  const notify = useNotify();

  useEffect(() => {
    if (vault.shareCode) {
      setShareLink(`${window.location.origin}/vault/shared/${vault.shareCode}`);
    }
  }, [vault.shareCode]);

  const generateShareCode = async () => {
    setIsGeneratingLink(true);
    try {
      // Simulate API call to generate share code
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      const newShareCode = Math.random().toString(36).substring(2, 15);
      const updatedVault = { ...vault, shareCode: newShareCode };
      
      onUpdate(updatedVault);
      notify.success('Share Link Generated', 'Your vault share link has been created.');
    } catch (error) {
      notify.error('Generation Failed', 'Failed to generate share link.');
    } finally {
      setIsGeneratingLink(false);
    }
  };

  const copyShareLink = async () => {
    try {
      await navigator.clipboard.writeText(shareLink);
      notify.success('Link Copied', 'Share link copied to clipboard.');
    } catch (error) {
      notify.error('Copy Failed', 'Failed to copy link to clipboard.');
    }
  };

  const inviteCollaborator = async () => {
    if (!inviteAddress) {
      notify.warning('Address Required', 'Please enter a valid address.');
      return;
    }

    // Check if already a collaborator
    const existingCollaborator = vault.collaborators.find(c => c.address === inviteAddress);
    if (existingCollaborator) {
      notify.warning('Already Invited', 'This address is already a collaborator.');
      return;
    }

    try {
      const permissions = {
        canView: true,
        canDeposit: inviteRole === 'contributor' || inviteRole === 'manager',
        canWithdraw: inviteRole === 'manager',
        canManage: inviteRole === 'manager'
      };

      const newCollaborator: VaultCollaborator = {
        address: inviteAddress,
        role: inviteRole,
        addedAt: Date.now(),
        permissions
      };

      const updatedVault = {
        ...vault,
        collaborators: [...vault.collaborators, newCollaborator]
      };

      onUpdate(updatedVault);
      setInviteAddress('');
      setInviteModal(false);
      
      notify.success('Collaborator Added', `${formatAddress(inviteAddress)} has been invited as ${inviteRole}.`);
    } catch (error) {
      notify.error('Invitation Failed', 'Failed to add collaborator.');
    }
  };

  const removeCollaborator = async (address: string) => {
    try {
      const updatedVault = {
        ...vault,
        collaborators: vault.collaborators.filter(c => c.address !== address)
      };

      onUpdate(updatedVault);
      notify.success('Collaborator Removed', `${formatAddress(address)} has been removed.`);
    } catch (error) {
      notify.error('Removal Failed', 'Failed to remove collaborator.');
    }
  };

  const updateCollaboratorRole = async (address: string, newRole: VaultCollaborator['role']) => {
    try {
      const permissions = {
        canView: true,
        canDeposit: newRole === 'contributor' || newRole === 'manager',
        canWithdraw: newRole === 'manager',
        canManage: newRole === 'manager'
      };

      const updatedVault = {
        ...vault,
        collaborators: vault.collaborators.map(c => 
          c.address === address 
            ? { ...c, role: newRole, permissions }
            : c
        )
      };

      onUpdate(updatedVault);
      notify.success('Role Updated', `${formatAddress(address)} role updated to ${newRole}.`);
    } catch (error) {
      notify.error('Update Failed', 'Failed to update collaborator role.');
    }
  };

  const togglePublicAccess = async () => {
    try {
      const updatedVault = { ...vault, isPublic: !vault.isPublic };
      onUpdate(updatedVault);
      
      notify.success(
        'Visibility Updated', 
        vault.isPublic ? 'Vault is now private.' : 'Vault is now public.'
      );
    } catch (error) {
      notify.error('Update Failed', 'Failed to update vault visibility.');
    }
  };

  const getRoleColor = (role: VaultCollaborator['role']) => {
    switch (role) {
      case 'viewer': return 'bg-blue-100 text-blue-800';
      case 'contributor': return 'bg-green-100 text-green-800';
      case 'manager': return 'bg-purple-100 text-purple-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <Card className={`p-6 ${className}`}>
      <div className="flex items-center justify-between mb-6">
        <h3 className="text-lg font-semibold text-gray-900">Vault Sharing</h3>
        
        {isOwner && (
          <div className="flex items-center space-x-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowInviteModal(true)}
            >
              Invite Collaborator
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setShowShareModal(true)}
            >
              Share Link
            </Button>
          </div>
        )}
      </div>

      {/* Vault Info */}
      <div className="mb-6 p-4 bg-gray-50 rounded-lg">
        <div className="flex items-center justify-between mb-2">
          <h4 className="font-medium text-gray-900">{vault.name}</h4>
          <div className="flex items-center space-x-2">
            <Badge variant={vault.isPublic ? 'success' : 'secondary'}>
              {vault.isPublic ? 'Public' : 'Private'}
            </Badge>
            {vault.shareCode && (
              <Badge variant="info">Shareable</Badge>
            )}
          </div>
        </div>
        <p className="text-sm text-gray-600 mb-2">{vault.description}</p>
        <div className="text-sm text-gray-500">
          Balance: {formatBalance(vault.balance)} ETH • Owner: {formatAddress(vault.owner)}
        </div>
      </div>

      {/* Collaborators List */}
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <h4 className="font-medium text-gray-900">
            Collaborators ({vault.collaborators.length})
          </h4>
          
          {isOwner && (
            <Button
              variant="ghost"
              size="sm"
              onClick={togglePublicAccess}
              className="text-sm"
            >
              {vault.isPublic ? 'Make Private' : 'Make Public'}
            </Button>
          )}
        </div>

        {vault.collaborators.length === 0 ? (
          <div className="text-center py-8 text-gray-500">
            <svg className="mx-auto h-12 w-12 text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
            </svg>
            <p>No collaborators yet</p>
            <p className="text-sm">Invite others to view or contribute to this vault</p>
          </div>
        ) : (
          <div className="space-y-3">
            {vault.collaborators.map((collaborator) => (
              <div key={collaborator.address} className="flex items-center justify-between p-3 bg-white border border-gray-200 rounded-lg">
                <div className="flex items-center space-x-3">
                  <div className="w-8 h-8 bg-gray-300 rounded-full flex items-center justify-center">
                    <span className="text-xs font-medium text-gray-600">
                      {collaborator.address.slice(2, 4).toUpperCase()}
                    </span>
                  </div>
                  <div>
                    <div className="font-medium text-gray-900">
                      {formatAddress(collaborator.address)}
                    </div>
                    <div className="text-sm text-gray-500">
                      Added {new Date(collaborator.addedAt).toLocaleDateString()}
                    </div>
                  </div>
                </div>
                
                <div className="flex items-center space-x-2">
                  {isOwner ? (
                    <select
                      value={collaborator.role}
                      onChange={(e) => updateCollaboratorRole(
                        collaborator.address, 
                        e.target.value as VaultCollaborator['role']
                      )}
                      className="text-sm border border-gray-300 rounded px-2 py-1"
                    >
                      <option value="viewer">Viewer</option>
                      <option value="contributor">Contributor</option>
                      <option value="manager">Manager</option>
                    </select>
                  ) : (
                    <Badge className={getRoleColor(collaborator.role)}>
                      {collaborator.role}
                    </Badge>
                  )}
                  
                  {isOwner && (
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => removeCollaborator(collaborator.address)}
                      className="text-red-600 hover:text-red-700"
                    >
                      Remove
                    </Button>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Share Modal */}
      <Modal
        isOpen={showShareModal}
        onClose={() => setShowShareModal(false)}
        title="Share Vault"
      >
        <div className="space-y-4">
          <p className="text-gray-600">
            Generate a shareable link that allows others to view your vault details.
          </p>
          
          {shareLink ? (
            <div className="space-y-3">
              <div className="p-3 bg-gray-50 rounded-lg">
                <div className="text-sm font-medium text-gray-700 mb-1">Share Link</div>
                <div className="text-sm text-gray-600 break-all">{shareLink}</div>
              </div>
              
              <div className="flex space-x-2">
                <Button onClick={copyShareLink} className="flex-1">
                  Copy Link
                </Button>
                <Button variant="outline" onClick={generateShareCode}>
                  Regenerate
                </Button>
              </div>
            </div>
          ) : (
            <Button
              onClick={generateShareCode}
              disabled={isGeneratingLink}
              className="w-full"
            >
              {isGeneratingLink ? 'Generating...' : 'Generate Share Link'}
            </Button>
          )}
        </div>
      </Modal>

      {/* Invite Modal */}
      <Modal
        isOpen={showInviteModal}
        onClose={() => setShowInviteModal(false)}
        title="Invite Collaborator"
      >
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Wallet Address
            </label>
            <Input
              value={inviteAddress}
              onChange={(e) => setInviteAddress(e.target.value)}
              placeholder="0x..."
              className="w-full"
            />
          </div>
          
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Role
            </label>
            <select
              value={inviteRole}
              onChange={(e) => setInviteRole(e.target.value as VaultCollaborator['role'])}
              className="w-full border border-gray-300 rounded-md px-3 py-2"
            >
              <option value="viewer">Viewer - Can view vault details</option>
              <option value="contributor">Contributor - Can view and deposit</option>
              <option value="manager">Manager - Full access except ownership</option>
            </select>
          </div>
          
          <div className="flex space-x-2">
            <Button
              variant="outline"
              onClick={() => setShowInviteModal(false)}
              className="flex-1"
            >
              Cancel
            </Button>
            <Button
              onClick={inviteCollaborator}
              className="flex-1"
            >
              Send Invite
            </Button>
          </div>
        </div>
      </Modal>
    </Card>
  );
}
