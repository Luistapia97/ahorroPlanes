# 🔐 Setup Google Calendar + OAuth — Paso a Paso

Esta guía te lleva a través de la configuración de Google OAuth + Google Calendar para que las actividades con recordatorio se sincronicen con tu calendario de Google y te lleguen notificaciones al celular.

---

## Paso 1: Crear un Proyecto en Google Cloud Console

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Si no tienes un proyecto, haz clic en el selector de proyecto (arriba a la izquierda)
3. Haz clic en **"NUEVO PROYECTO"**
4. Nombre del proyecto: **"Ahorros Planes"** (o el que prefieras)
5. Haz clic en **"CREAR"**
6. Espera a que se cree el proyecto (toma ~1 minuto)

---

## Paso 2: Habilitar Google Calendar API

1. En Google Cloud Console, asegúrate de que tu proyecto **"Ahorros Planes"** esté seleccionado (selector arriba a la izquierda)
2. Ve a **"APIs y Servicios"** en el menú de la izquierda
3. Haz clic en **"Biblioteca"**
4. Busca: **"Google Calendar API"**
5. Haz clic en el resultado de Google Calendar API
6. Haz clic en **"HABILITAR"**

✅ Google Calendar API está activada.

---

## Paso 3: Crear una Credencial OAuth 2.0

1. En Google Cloud Console, ve a **"APIs y Servicios"** → **"Credenciales"**
2. Haz clic en **"+ CREAR CREDENCIALES"** (arriba a la izquierda)
3. Selecciona **"ID de cliente de OAuth"**
4. Te pedirá que configures la pantalla de consentimiento (si no lo hiciste):
   - Haz clic en **"CONFIGURAR PANTALLA DE CONSENTIMIENTO"**
   - Selecciona **"Externo"** (o "Interno" si tu cuenta es de G Suite)
   - Haz clic en **"CREAR"**

### Configurar la Pantalla de Consentimiento

5. En **"Información de la app"**:
   - **Nombre de la app**: "Ahorros Planes"
   - **Email de asistencia**: tu email
6. En **"Datos del desarrollador"**:
   - **Email de contacto**: tu email
7. Haz clic en **"GUARDAR Y CONTINUAR"** (abajo)
8. En **"Permisos"**: haz clic en **"GUARDAR Y CONTINUAR"**
9. En **"Usuarios de prueba"**: haz clic en **"GUARDAR Y CONTINUAR"**
10. Haz clic en **"VOLVER A CREDENCIALES"**

### Crear el Cliente OAuth

11. En **"Credenciales"**, haz clic en **"+ CREAR CREDENCIALES"** de nuevo
12. Selecciona **"ID de cliente de OAuth"**
13. **Tipo de aplicación**: selecciona **"Aplicación web"**
14. **Nombre**: "Ahorros Planes Web"
15. En **"URIs de redirección autorizados"**, haz clic en **"+ AGREGAR URI"** y copia/pega:

```
http://localhost:3000/
http://localhost:3002/
https://mi-dominio.vercel.app/
```

> **Reemplaza `mi-dominio` con el nombre real de tu Vercel** (ej: `ahorros-planes-xyz.vercel.app`).
> Si no tienes el dominio aún, déjalo solo con `localhost` por ahora y lo actualizas después del primer deploy.

16. Haz clic en **"CREAR"**

✅ Se abrirá una ventana modal con tu **Client ID** y **Client Secret**.

### Guardar el Client ID

17. **Copia el "Client ID"** (la cadena larga que comienza con números seguidos de `-apps.googleusercontent.com`)
18. Guarda este valor en un editor de texto temporalmente — lo vas a usar en el siguiente paso.
19. Haz clic en **"OK"** para cerrar la modal.

---

## Paso 4: Agregar la Credencial a Vercel

### Si ya deployaste en Vercel

1. Ve a [Vercel Dashboard](https://vercel.com/dashboard)
2. Selecciona tu proyecto **"ahorros-planes"** (o cómo lo llamaste)
3. Ve a **"Settings"** (arriba a la derecha)
4. En el menú de la izquierda, haz clic en **"Environment Variables"**
5. Haz clic en **"Add"**
6. **Name**: `GOOGLE_CLIENT_ID`
7. **Value**: pega el Client ID que copiaste en el Paso 3
8. **Production / Preview / Development**: marca todas las opciones
9. Haz clic en **"Save"**

### Si aún no deployaste

1. En tu proyecto local, abre o crea el archivo `.env.local` (si no existe)
2. Agrega esta línea:

```
GOOGLE_CLIENT_ID=tu_client_id_aqui
```

3. Reemplaza `tu_client_id_aqui` con el Client ID del Paso 3
4. Guarda el archivo
5. **Este archivo NUNCA se debe committear a Git** (ya está en `.gitignore`)

---

## Paso 5: Configurar el Dominio de Vercel en Google Cloud

Una vez que deployaste en Vercel, obtendrás una URL como:

```
https://ahorros-planes-xyz.vercel.app
```

1. Ve a [Google Cloud Console](https://console.cloud.google.com/)
2. Ve a **"APIs y Servicios"** → **"Credenciales"**
3. Busca tu credencial **"Ahorsos Planes Web"** (la que creaste)
4. Haz clic en ella para editarla
5. En **"URIs de redirección autorizados"**, agrega:

```
https://ahorros-planes-xyz.vercel.app/
```

(Reemplaza `ahorsos-planes-xyz` con tu dominio real de Vercel)

6. Haz clic en **"GUARDAR"**

---

## Paso 6: Probar Localmente

1. En tu terminal, en la carpeta del proyecto:

```bash
npm install
```

2. Asegúrate de que `.env.local` tiene el `GOOGLE_CLIENT_ID`

3. Inicia el servidor de desarrollo:

```bash
vercel dev
```

4. Abre http://localhost:3000 en tu navegador

5. Inicia sesión en la app

6. En la barra de sesión (arriba a la derecha), deberías ver el botón **"Sincronizar con Google Calendar"**

7. Haz clic en él

8. Se abrirá una ventana de Google pidiendo que autorices el acceso a tu calendario

9. Haz clic en **"Permitir"**

10. Se cerrará la ventana y volverás a la app

11. Ahora crea una actividad con:
    - ✅ **Recordatorio activado**
    - ✅ Hora y fecha
    - ✅ **Marcar la casilla "Sincronizar con Google Calendar"**

12. La actividad debería aparecer en tu calendario de Google en pocos segundos

13. En tu teléfono, abre la app de Google Calendar y verifica que la actividad y el recordatorio estén allí

---

## Paso 7: Deploy a Producción

1. Asegúrate de que `GOOGLE_CLIENT_ID` está en Vercel Environment Variables

2. Haz un push a Git:

```bash
git add .
git commit -m "feat: Google Calendar + OAuth integration ready"
git push origin main
```

3. Ve a [Vercel Dashboard](https://vercel.com/dashboard)

4. Vercel debería auto-deployar automáticamente

5. Una vez deployado, abre tu URL de Vercel (ej: `https://ahorros-planes-xyz.vercel.app`)

6. Repite los pasos de Prueba (Paso 6) pero en la URL de producción

---

## ¿Qué pasó?

### En el Backend (Vercel)
- El archivo `api/config.js` expone `GOOGLE_CLIENT_ID` a la app frontend
- La app carga la biblioteca OAuth de Google desde Google

### En el Frontend (Index.html)
- Cuando haces clic en "Sincronizar con Google Calendar", se abre un flujo OAuth
- Google te pide permiso para acceder a tu calendario
- Si autorizas, se guarda un token en `localStorage`
- Cuando creas una actividad con recordatorio y sincronización, se crea un evento en Google Calendar con un recordatorio 15 minutos antes

### En Google Calendar
- El evento aparece en tu calendario de Google
- El recordatorio se sincroniza con todos tus dispositivos
- En el teléfono, recibirás una notificación de Google Calendar (no del navegador)

---

## 🚨 Solución de Problemas

### "Sincronizar con Google Calendar" no aparece
- Recarga la página
- Asegúrate de que `GOOGLE_CLIENT_ID` está configurado en Vercel o `.env.local`
- Revisa la consola del navegador (F12 → Console) para errores

### El botón aparece pero al hacer clic no pasa nada
- Verifica que los redirect URIs en Google Cloud son correctos
- Asegúrate de que estás usando `http://localhost:3000` o `https://tu-dominio.vercel.app`
- Revisa la consola del navegador (F12 → Console) para errores

### "Error: Popup bloqueado"
- Haz clic en el icono de bloqueo de popup (generalmente a la derecha de la URL) y permite popups

### La actividad no aparece en Google Calendar
- Verifica que autorizaste acceso en el paso de OAuth
- Revisa la consola del navegador (F12 → Console) para errores
- Intenta crear de nuevo la actividad con sincronización habilitada

### "Acceso denegado" en Google Calendar API
- Asegúrate de que habilitaste Google Calendar API en Google Cloud Console
- Verifica que creaste una credencial OAuth 2.0 de tipo "Aplicación web"

---

## ✅ Checklist de Configuración

- [ ] Proyecto creado en Google Cloud Console
- [ ] Google Calendar API habilitada
- [ ] Credencial OAuth 2.0 creada
- [ ] `GOOGLE_CLIENT_ID` guardado localmente en `.env.local`
- [ ] `GOOGLE_CLIENT_ID` agregado a Vercel Environment Variables
- [ ] URIs de redirección autorizados configurados en Google Cloud
- [ ] Probado localmente en `http://localhost:3000`
- [ ] Deployado a Vercel
- [ ] Probado en producción con `https://tu-dominio.vercel.app`
- [ ] Autorización de Google Calendar completada
- [ ] Actividad con sincronización creada exitosamente
- [ ] Evento aparece en Google Calendar
- [ ] Recordatorio llega al teléfono

---

## 📞 Próximos Pasos

Una vez que todo esté funcionando:

1. **Prueba en móvil**: abre la app en el navegador del celular y crea actividades
2. **Comparte el calendario**: si quieres compartir actividades con otra persona, comparte el calendario en Google Calendar
3. **Personaliza recordatorios**: en la app puedes cambiar la hora del recordatorio antes de guardar

---

## 🎯 Resumen Rápido (Solo lo Esencial)

Si solo quieres lo mínimo:

1. Google Cloud Console → Crear proyecto "Ahorros Planes"
2. Habilitar Google Calendar API
3. Crear OAuth 2.0 Client ID (tipo Web) con redirect URIs:
   - `http://localhost:3000/`
   - `https://tu-dominio.vercel.app/`
4. Copiar Client ID
5. Agregar a `.env.local`: `GOOGLE_CLIENT_ID=tu_client_id`
6. Agregar a Vercel Environment Variables
7. `vercel dev` → probar localmente
8. `git push origin main` → deploy
9. Probar en `https://tu-dominio.vercel.app`

¡Listo! 🎉
