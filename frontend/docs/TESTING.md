# Testing Guide

## Running Tests

```bash
npm test
npm run test:watch
npm run test:coverage
```

## Test Structure

```
__tests__/
├── utils/          # Utility function tests
├── hooks/          # Custom hook tests
├── components/     # Component tests
└── helpers/        # Helper function tests
```

## Writing Tests

```tsx
import { render, screen } from '@testing-library/react'
import { MyComponent } from '@/components/MyComponent'

describe('MyComponent', () => {
  it('renders correctly', () => {
    render(<MyComponent />)
    expect(screen.getByText('Hello')).toBeInTheDocument()
  })
})
```
