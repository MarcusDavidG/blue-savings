import React, { Component, ErrorInfo, ReactNode } from 'react';

/**
 * Properties for the ErrorBoundary component.
 */
interface ErrorBoundaryProps {
  /**
   * The children components that the ErrorBoundary will protect.
   */
  children?: ReactNode;
  /**
   * Optional fallback UI to render when an error occurs.
   */
  fallback?: ReactNode;
}

/**
 * State for the ErrorBoundary component.
 */
interface ErrorBoundaryState {
  /**
   * Indicates if an error has occurred.
   */
  hasError: boolean;
}

/**
 * A React Error Boundary component that catches JavaScript errors anywhere in its child component tree,
 * logs those errors, and displays a fallback UI instead of the crashed component tree.
 * @augments Component<ErrorBoundaryProps, ErrorBoundaryState>
 */
export class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  public state: ErrorBoundaryState = {
    hasError: false
  };

  /**
   * Static method to update state when an error is caught.
   * @param {Error} error The error that was thrown.
   * @returns {ErrorBoundaryState} An object to update state.
   */
  public static getDerivedStateFromError(_: Error): ErrorBoundaryState {
    // Update state so the next render shows the fallback UI.
    return { hasError: true };
  }

  /**
   * Lifecycle method to catch errors and log them.
   * @param {Error} error The error that was thrown.
   * @param {ErrorInfo} errorInfo Information about the component stack where the error occurred.
   */
  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error("Uncaught error:", error, errorInfo);
  }

  /**
   * Renders the children components or a fallback UI if an error has occurred.
   * @returns {ReactNode} The children components or the fallback UI.
   */
  public render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }
      return (
        <div
          style={{
            border: '1px solid red',
            padding: '1rem',
            borderRadius: '0.5rem',
            backgroundColor: '#ffe0e0',
            textAlign: 'center',
            color: 'red',
          }}
        >
          <h2>Something went wrong.</h2>
          <p>Please try refreshing the page or contact support.</p>
        </div>
      );
    }

    return this.props.children;
  }
}
