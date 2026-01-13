export const breakpoints = {
  xs: '320px',
  sm: '640px',
  md: '768px',
  lg: '1024px',
  xl: '1280px',
  '2xl': '1536px',
}

export const modalSizing = {
  mobile: {
    width: '100%',
    maxWidth: '100vw',
    height: '100vh',
    borderRadius: '0px',
    padding: '16px',
  },
  tablet: {
    width: '90%',
    maxWidth: '600px',
    height: 'auto',
    borderRadius: '16px',
    padding: '24px',
  },
  desktop: {
    width: '400px',
    maxWidth: '90vw',
    height: 'auto',
    borderRadius: '16px',
    padding: '24px',
  },
}

export const buttonSizing = {
  mobile: {
    padding: '10px 16px',
    fontSize: '14px',
    height: '40px',
  },
  desktop: {
    padding: '12px 24px',
    fontSize: '16px',
    height: '48px',
  },
}

export const mediaQueries = {
  mobile: `@media (max-width: ${breakpoints.sm})`,
  tablet: `@media (min-width: ${breakpoints.sm}) and (max-width: ${breakpoints.lg})`,
  desktop: `@media (min-width: ${breakpoints.lg})`,
  touch: '@media (hover: none) and (pointer: coarse)',
}
