export function fadeIn(element: HTMLElement, duration = 300): void {
  element.style.opacity = '0'
  element.style.transition = `opacity ${duration}ms`
  
  requestAnimationFrame(() => {
    element.style.opacity = '1'
  })
}

export function fadeOut(element: HTMLElement, duration = 300): Promise<void> {
  return new Promise(resolve => {
    element.style.transition = `opacity ${duration}ms`
    element.style.opacity = '0'
    
    setTimeout(() => resolve(), duration)
  })
}
