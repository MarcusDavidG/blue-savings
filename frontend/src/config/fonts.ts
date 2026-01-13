export const fontConfig = {
  family: {
    primary: 'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
    secondary: '"Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
    mono: '"Fira Code", "Courier New", monospace',
  },
  size: {
    xs: '0.75rem',    // 12px
    sm: '0.875rem',   // 14px
    base: '1rem',     // 16px
    lg: '1.125rem',   // 18px
    xl: '1.25rem',    // 20px
    '2xl': '1.5rem',  // 24px
    '3xl': '1.875rem', // 30px
    '4xl': '2.25rem', // 36px
    '5xl': '3rem',    // 48px
  },
  weight: {
    light: 300,
    normal: 400,
    medium: 500,
    semibold: 600,
    bold: 700,
    extrabold: 800,
  },
  lineHeight: {
    tight: 1.25,
    normal: 1.5,
    relaxed: 1.75,
    loose: 2,
  },
}

export const typographyStyles = {
  h1: {
    fontSize: fontConfig.size['4xl'],
    fontWeight: fontConfig.weight.bold,
    lineHeight: fontConfig.lineHeight.tight,
  },
  h2: {
    fontSize: fontConfig.size['3xl'],
    fontWeight: fontConfig.weight.bold,
    lineHeight: fontConfig.lineHeight.tight,
  },
  h3: {
    fontSize: fontConfig.size['2xl'],
    fontWeight: fontConfig.weight.semibold,
    lineHeight: fontConfig.lineHeight.tight,
  },
  body: {
    fontSize: fontConfig.size.base,
    fontWeight: fontConfig.weight.normal,
    lineHeight: fontConfig.lineHeight.normal,
  },
  small: {
    fontSize: fontConfig.size.sm,
    fontWeight: fontConfig.weight.normal,
    lineHeight: fontConfig.lineHeight.normal,
  },
}
