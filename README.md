# Rumbo

Rumbo es una app compartida para dos personas que permite crear planes de ahorro y registrar aportes sincronizados en tiempo real.

## Arquitectura

- Frontend estático: `Index.html`, desplegable en Vercel.
- Backend: función serverless `api/config.js` y Supabase Auth, Postgres y Realtime.
- No se guardan datos en `localStorage` ni en APIs propietarias del prototipo.

## Configuración de Supabase

1. Crea un proyecto gratuito en [supabase.com](https://supabase.com).
2. En **SQL Editor**, ejecuta [`supabase/schema.sql`](supabase/schema.sql).
3. En **Authentication > Users**, crea las dos cuentas con correo y contraseña.
4. Copia la URL del proyecto y la clave `anon` desde **Project Settings > API**.

## Ejecutar localmente

Requiere Node.js 18+ y Vercel CLI. Instala dependencias con `npm install` y ejecuta:

```bash
vercel dev
```

Configura `SUPABASE_URL` y `SUPABASE_ANON_KEY` como variables de entorno del proyecto local o en Vercel. La app queda disponible en `http://localhost:3000`.

## Desplegar en Vercel

Importa el repositorio en Vercel y agrega las mismas dos variables en **Settings > Environment Variables** para Preview y Production. Cada usuario debe iniciar sesión con una de las dos cuentas creadas en Supabase.

El canal Realtime escucha cambios en `plans` y `contributions`, por lo que un aporte o un plan nuevo aparece en las dos sesiones abiertas sin recargar.
