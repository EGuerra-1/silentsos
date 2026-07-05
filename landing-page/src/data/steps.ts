import type { ProcessStep } from '@/types';

export const processSteps: ProcessStep[] = [
  {
    number: 1,
    title: 'Activación',
    description: 'Un toque al botón SOS o toma una foto rápida de la escena.',
  },
  {
    number: 2,
    title: 'Procesamiento IA',
    description:
      'La IA analiza la situación y genera un reporte de voz/texto en tiempo real.',
  },
  {
    number: 3,
    title: 'Respuesta Inmediata',
    description:
      'Llamada automática al 911 con reporte de voz y alertas a familiares.',
    completed: true,
  },
];
