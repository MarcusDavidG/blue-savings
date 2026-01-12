import { useState } from 'react';

export function useVault() {
  const [state, setState] = useState();
  return { state, setState };
}
