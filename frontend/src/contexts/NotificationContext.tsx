import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';

export interface Notification {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  title: string;
  message: string;
  timestamp: number;
  read: boolean;
  persistent?: boolean;
  actionUrl?: string;
  actionLabel?: string;
}

export interface NotificationPreferences {
  email: boolean;
  push: boolean;
  inApp: boolean;
  vaultUnlocks: boolean;
  goalReached: boolean;
  deposits: boolean;
  withdrawals: boolean;
  yieldUpdates: boolean;
  securityAlerts: boolean;
}

interface NotificationContextType {
  notifications: Notification[];
  preferences: NotificationPreferences;
  unreadCount: number;
  addNotification: (notification: Omit<Notification, 'id' | 'timestamp' | 'read'>) => void;
  markAsRead: (id: string) => void;
  markAllAsRead: () => void;
  removeNotification: (id: string) => void;
  clearAll: () => void;
  updatePreferences: (preferences: Partial<NotificationPreferences>) => void;
}

const NotificationContext = createContext<NotificationContextType | undefined>(undefined);

const defaultPreferences: NotificationPreferences = {
  email: true,
  push: false,
  inApp: true,
  vaultUnlocks: true,
  goalReached: true,
  deposits: true,
  withdrawals: true,
  yieldUpdates: false,
  securityAlerts: true
};

export function NotificationProvider({ children }: { children: ReactNode }) {
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [preferences, setPreferences] = useState<NotificationPreferences>(defaultPreferences);

  // Load preferences from localStorage on mount
  useEffect(() => {
    const savedPreferences = localStorage.getItem('notification-preferences');
    if (savedPreferences) {
      try {
        setPreferences(JSON.parse(savedPreferences));
      } catch (error) {
        console.error('Failed to parse notification preferences:', error);
      }
    }
  }, []);

  // Save preferences to localStorage when they change
  useEffect(() => {
    localStorage.setItem('notification-preferences', JSON.stringify(preferences));
  }, [preferences]);

  const unreadCount = notifications.filter(n => !n.read).length;

  const addNotification = (notification: Omit<Notification, 'id' | 'timestamp' | 'read'>) => {
    const newNotification: Notification = {
      ...notification,
      id: `notification-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      timestamp: Date.now(),
      read: false
    };

    setNotifications(prev => [newNotification, ...prev]);

    // Auto-remove non-persistent notifications after 5 seconds
    if (!notification.persistent) {
      setTimeout(() => {
        removeNotification(newNotification.id);
      }, 5000);
    }

    // Request permission for push notifications if enabled
    if (preferences.push && 'Notification' in window) {
      if (Notification.permission === 'granted') {
        new Notification(notification.title, {
          body: notification.message,
          icon: '/favicon.ico'
        });
      } else if (Notification.permission !== 'denied') {
        Notification.requestPermission().then(permission => {
          if (permission === 'granted') {
            new Notification(notification.title, {
              body: notification.message,
              icon: '/favicon.ico'
            });
          }
        });
      }
    }
  };

  const markAsRead = (id: string) => {
    setNotifications(prev =>
      prev.map(notification =>
        notification.id === id ? { ...notification, read: true } : notification
      )
    );
  };

  const markAllAsRead = () => {
    setNotifications(prev =>
      prev.map(notification => ({ ...notification, read: true }))
    );
  };

  const removeNotification = (id: string) => {
    setNotifications(prev => prev.filter(notification => notification.id !== id));
  };

  const clearAll = () => {
    setNotifications([]);
  };

  const updatePreferences = (newPreferences: Partial<NotificationPreferences>) => {
    setPreferences(prev => ({ ...prev, ...newPreferences }));
  };

  const value: NotificationContextType = {
    notifications,
    preferences,
    unreadCount,
    addNotification,
    markAsRead,
    markAllAsRead,
    removeNotification,
    clearAll,
    updatePreferences
  };

  return (
    <NotificationContext.Provider value={value}>
      {children}
    </NotificationContext.Provider>
  );
}

export function useNotifications() {
  const context = useContext(NotificationContext);
  if (context === undefined) {
    throw new Error('useNotifications must be used within a NotificationProvider');
  }
  return context;
}

// Hook for easy notification creation
export function useNotify() {
  const { addNotification } = useNotifications();

  return {
    success: (title: string, message: string, options?: Partial<Notification>) =>
      addNotification({ type: 'success', title, message, ...options }),
    
    error: (title: string, message: string, options?: Partial<Notification>) =>
      addNotification({ type: 'error', title, message, persistent: true, ...options }),
    
    warning: (title: string, message: string, options?: Partial<Notification>) =>
      addNotification({ type: 'warning', title, message, ...options }),
    
    info: (title: string, message: string, options?: Partial<Notification>) =>
      addNotification({ type: 'info', title, message, ...options }),
    
    vaultUnlock: (vaultId: number) =>
      addNotification({
        type: 'success',
        title: 'Vault Unlocked!',
        message: `Your vault #${vaultId} is now available for withdrawal.`,
        persistent: true,
        actionUrl: `/vault/${vaultId}`,
        actionLabel: 'View Vault'
      }),
    
    goalReached: (vaultId: number, amount: string) =>
      addNotification({
        type: 'success',
        title: 'Goal Reached!',
        message: `Congratulations! Your vault #${vaultId} has reached its goal of ${amount} ETH.`,
        persistent: true,
        actionUrl: `/vault/${vaultId}`,
        actionLabel: 'View Vault'
      }),
    
    securityAlert: (message: string) =>
      addNotification({
        type: 'error',
        title: 'Security Alert',
        message,
        persistent: true
      })
  };
}
