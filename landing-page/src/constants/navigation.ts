export interface NavLink {
  label: string;
  href: string;
}

export const mainNavLinks: NavLink[] = [
  { label: 'Funciones', href: '#features' },
  { label: 'Cómo funciona', href: '#how-it-works' },
  { label: 'Accesibilidad', href: '#accessibility' },
];

export const footerLinks: NavLink[] = [
  { label: 'Descargar App', href: '#' },
  { label: 'Políticas de Privacidad', href: '#' },
  { label: 'Términos de Servicio', href: '#' },
  { label: 'Soporte', href: '#' },
];
