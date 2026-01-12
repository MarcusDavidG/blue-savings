import { useState } from 'react';

export function useContract() {
  const [state, setState] = useState();
  return { state, setState };
}
