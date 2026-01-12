import { useState } from 'react';

export function useWallet() {
  const [state, setState] = useState();
  return { state, setState };
}
