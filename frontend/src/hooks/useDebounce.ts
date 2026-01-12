import { useState } from 'react';

export function useDebounce() {
  const [state, setState] = useState();
  return { state, setState };
}
