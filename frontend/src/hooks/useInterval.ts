import { useState } from 'react';

export function useInterval() {
  const [state, setState] = useState();
  return { state, setState };
}
