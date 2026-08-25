# Módulo Mi ciclo

## Objetivo

**Mi ciclo** es un módulo compartido de seguimiento menstrual integrado en Rumbo. Las dos cuentas autorizadas pueden registrar el flujo, el estado de ánimo y los síntomas de cada día, además de ver las predicciones orientativas del siguiente periodo, la ovulación y la ventana fértil.

Los datos menstruales están separados de los planes y actividades compartidos. Las políticas RLS de Supabase permiten consultar y modificar estos datos únicamente a las dos cuentas de Rumbo configuradas en el esquema.

## Modelos de datos

### `user_preferences`

Guarda las preferencias de predicción de cada cuenta:

- `user_id`: usuario propietario y clave primaria.
- `default_cycle_length`: duración inicial del ciclo; por defecto `28` días.
- `default_period_length`: duración estimada del periodo; por defecto `5` días.

### `cycles`

Representa cada ciclo menstrual:

- `id`: identificador UUID.
- `user_id`: usuario propietario.
- `start_date`: fecha exacta de inicio del sangrado.
- `end_date`: fecha de inicio del siguiente ciclo; es `null` para el ciclo actual.
- `cycle_length`: diferencia en días entre `start_date` y `end_date`.

### `daily_logs`

Representa el registro de un día:

- `id`: identificador UUID.
- `user_id`: usuario propietario.
- `date`: fecha del registro.
- `flow_intensity`: `none`, `light`, `medium` o `heavy`.
- `symptoms`: arreglo de síntomas, por ejemplo `cramps` o `headache`.
- `mood`: arreglo de estados, por ejemplo `happy` o `sensitive`.

Existe una restricción única para `user_id` y `date`, por lo que guardar dos veces el mismo día actualiza el registro en lugar de duplicarlo.

## Motor `MenstrualEngineService`

El motor vive en el frontend como un conjunto de funciones puras y recibe ciclos, preferencias y la fecha actual.

### Promedio móvil

1. Ordena los ciclos históricos del más reciente al más antiguo.
2. Toma únicamente ciclos completados, es decir, aquellos con `end_date`.
3. Descarta valores atípicos menores de 21 días o mayores de 45 días.
4. Conserva como máximo los últimos 6 ciclos válidos.
5. Calcula el promedio redondeado de sus duraciones.
6. Si no hay ciclos válidos, usa `default_cycle_length`; el valor inicial es 28 días.

Los valores extremos se filtran para que un ciclo inusualmente corto o largo no distorsione las predicciones.

### Próximo periodo

```text
próximo periodo = inicio del ciclo actual + promedio del ciclo
```

Si el ciclo actual inició el 1 de agosto y el promedio es de 28 días, el próximo periodo se estima para el 29 de agosto.

### Ovulación y ventana fértil

```text
ovulación = próximo periodo - 14 días
ventana fértil = desde ovulación - 5 días hasta ovulación + 1 día
```

El periodo estimado usa `default_period_length` y se dibuja durante esos días a partir de la fecha predicha.

### Cierre automático

Cuando se guarda un `daily_log` con flujo distinto de `none`:

- Si no existe un ciclo actual, se crea uno con esa fecha.
- Si existe un ciclo y han transcurrido al menos 10 días desde su inicio, se actualiza su `end_date` y `cycle_length`.
- Después se crea un nuevo ciclo actual con `start_date` igual a la fecha del registro.

La regla de 10 días evita cerrar accidentalmente un ciclo por registros consecutivos del mismo periodo.

## Componentes de UI

### Calendario menstrual

La vista mensual muestra:

- Punto rojo en días con flujo registrado.
- Borde rojo en días del periodo estimado.
- Fondo azul claro en la ventana fértil.
- Fondo azul más marcado y etiqueta para el día de ovulación.
- Día actual resaltado.

Cada día es un botón táctil que abre el formulario diario. En móvil las celdas tienen altura fija, las etiquetas se compactan y la información detallada se mantiene en el modal.

### Registro diario

El formulario está diseñado para pocos clics:

1. Se elige el flujo con un control de cuatro opciones.
2. Se seleccionan síntomas y estados de ánimo con chips.
3. Se pulsa **Guardar registro**.

El registro se guarda mediante `upsert`, por lo que puede corregirse cualquier día sin crear duplicados.

### Tarjeta de predicción

La tarjeta muestra:

- `Día X de tu ciclo`.
- Cuántos días faltan aproximadamente para el siguiente periodo.
- Fecha del próximo periodo.
- Promedio calculado.
- Fecha de ovulación.
- Rango de ventana fértil.

Cuando todavía no existe un ciclo actual, muestra una invitación para registrar el primer día de sangrado.

## Privacidad y sincronización

Las tablas menstruales tienen RLS limitado a los dos UUID autorizados de Rumbo. Los cambios se publican en Realtime, por lo que ambas sesiones ven los nuevos registros y correcciones sin recargar. Ninguna otra cuenta autenticada puede consultar estos datos.

Para activar el módulo en Supabase, ejecuta [`supabase/schema.sql`](supabase/schema.sql). El script es idempotente y añade las tablas, políticas y publicaciones Realtime necesarias.

> Las fechas son estimaciones basadas en los datos registrados. No sustituyen asesoría médica ni deben utilizarse como método anticonceptivo.
