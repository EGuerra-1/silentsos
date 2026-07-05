import type { Feature } from '@/types';

export const features: Feature[] = [
  {
    icon: 'emergency_home',
    iconFilled: true,
    iconBgClass: 'bg-sos-red/10',
    iconColorClass: 'text-sos-red',
    title: 'Botón de SOS Instantáneo',
    description:
      'Activación de emergencia en 1-tap que inicia automáticamente una llamada de emergencia silenciosa y envía alertas de geolocalización por WhatsApp a sus contactos de confianza.',
  },
  {
    icon: 'smart_toy',
    iconFilled: true,
    iconBgClass: 'bg-secondary/10',
    iconColorClass: 'text-secondary',
    decorativeIcon: 'psychology',
    title: 'IA de Contexto',
    description:
      'Impulsada por ChatGPT y ElevenLabs. La IA interpreta fotos de la escena y convierte texto a una voz hiper-realista para comunicarse directamente con el 911.',
  },
  {
    icon: 'health_metrics',
    iconFilled: true,
    iconBgClass: 'bg-primary-fixed-dim/30',
    iconColorClass: 'text-deep-navy',
    title: 'Gestión de Salud Conectada',
    description:
      'Log médico avanzado que sincroniza sus condiciones críticas. Notificaciones automáticas a la familia vía WhatsApp para asegurar la adherencia a medicamentos.',
  },
];
