import { useState } from 'react';

export function useModal() {
  const [state, setState] = useState();
  return { state, setState };
}
