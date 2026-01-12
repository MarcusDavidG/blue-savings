import { useState } from 'react';

export function useToast() {
  const [state, setState] = useState();
  return { state, setState };
}
