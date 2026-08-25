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

El canal Realtime escucha cambios en `plans`, `contributions` y `activities`, por lo que un plan, aporte o actividad nueva aparece en las dos sesiones abiertas sin recargar.

Para habilitar el calendario interactivo, vuelve a ejecutar [`supabase/schema.sql`](supabase/schema.sql) en el SQL Editor. El script crea la tabla `activities` y es seguro de ejecutar aunque las tablas anteriores ya existan.

## Módulo Mi ciclo

La sección **Mi ciclo** permite registrar flujo, síntomas y estado de ánimo por día. Sus tablas (`user_preferences`, `cycles` y `daily_logs`) usan políticas RLS para que cada cuenta solo pueda leer sus propios datos.

El motor calcula el promedio móvil de los últimos 6 ciclos completos, ignora ciclos menores de 21 o mayores de 45 días y usa 28 días como valor inicial. También muestra el siguiente periodo estimado, ovulación y ventana fértil. Al registrar flujo después de al menos 10 días del ciclo actual, cierra ese ciclo y crea el siguiente automáticamente.
