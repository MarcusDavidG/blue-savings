import { useState } from 'react';

export function useAsync() {
  const [state, setState] = useState();
  return { state, setState };
}
