import { useState } from 'react';

export function useLocalStorage() {
  const [state, setState] = useState();
  return { state, setState };
}
