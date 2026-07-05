# Silent SOS — Landing Page

Landing page estática de **Silent SOS**, plataforma de emergencias accesible para personas con discapacidad auditiva y del habla. Presenta el producto, sus funciones y la propuesta de valor del proyecto comunitario gratuito.

**Producción:** [landinghack.danielmorales.tech](https://landinghack.danielmorales.tech)

---

## Qué es

Silent SOS coordina emergencias sin depender del habla: activación SOS, análisis de contexto con IA, llamada al 911 y alertas a contactos de confianza. Esta landing explica el producto de forma clara, accesible y optimizada para conversión (descarga de la app).

---

## Stack

| Tecnología | Uso |
|---|---|
| **Astro 4** | Sitio estático, HTML en build time |
| **TypeScript** | Tipado en datos y configuración |
| **Tailwind CSS** | Estilos y design tokens |
| **Inter** (`@fontsource/inter`) | Tipografía self-hosted |
| **Material Symbols** | Iconografía |

Sin JavaScript en cliente: cero islands, máximo rendimiento y SEO.

---

## Cómo se hizo

1. **Diseño base** en [Google Stitch](https://stitch.withgoogle.com) — *Silent SOS: Premium Emergency Accessibility*.
2. **Implementación** en Astro respetando el design system (colores, tipografía, espaciado).
3. **Componentización** por secciones reutilizables y datos separados del markup.
4. **Optimización** de favicon, meta tags, JSON-LD, sitemap y accesibilidad WCAG.

---

## Arquitectura

```
src/
├── config/          # URL, título, SEO global
├── constants/       # Links de navegación
├── data/            # Contenido (features, pasos, accesibilidad)
├── types/           # Interfaces TypeScript
├── layouts/         # BaseLayout (head, skip-link, slots)
├── components/
│   ├── layout/      # Navbar, Footer
│   ├── seo/         # MetaTags, JsonLd
│   └── ui/          # Button, Badge, Icon, Container
├── sections/        # Hero, Features, HowItWorks, Accessibility, CTA
├── pages/           # index.astro
└── styles/          # global.css + tokens Stitch
public/                # favicon, robots.txt, sitemap.xml
```

**Flujo de la página:** `index.astro` → `BaseLayout` → secciones en orden (Hero → Features → Cómo funciona → Accesibilidad → CTA) + Navbar/Footer.

**Principio clave:** contenido en `data/`, presentación en `sections/` y `components/`. Un solo HTML estático por ruta.

---

## Secciones

| Sección | Descripción |
|---|---|
| **Hero** | Propuesta de valor + mockup de la app móvil |
| **Features** | SOS instantáneo, IA de contexto, salud conectada |
| **Cómo funciona** | Activación → IA → respuesta al 911 |
| **Accesibilidad** | Contraste, touch targets, iconografía semántica |
| **CTA** | Descarga gratuita de la app |

---

## SEO y accesibilidad

- Meta title, description, Open Graph y Twitter Cards
- JSON-LD (`Organization`, `WebSite`, `SoftwareApplication`)
- `robots.txt` y `sitemap.xml`
- HTML semántico, skip link, foco visible y `prefers-reduced-motion`

---

## Comandos

```bash
# Instalar dependencias
npm install

# Desarrollo local → http://localhost:4321
npm run dev

# Build de producción (salida en dist/)
npm run build

# Preview del build
npm run preview

# Verificación de tipos
npm run check
```

---

## Despliegue

Generar el build y servir la carpeta `dist/` en cualquier hosting estático (Vercel, Netlify, Nginx, etc.). Configurar el dominio apuntando a ese directorio.

---

## Licencia

Proyecto privado — Silent SOS Hackathon.
