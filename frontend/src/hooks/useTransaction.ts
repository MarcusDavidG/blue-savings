import { useState } from 'react';

export function useTransaction() {
  const [state, setState] = useState();
  return { state, setState };
}
