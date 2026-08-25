# Guía de uso: Mi ciclo

## ¿Qué es Mi ciclo?

**Mi ciclo** es una herramienta privada de Rumbo para llevar un registro sencillo del ciclo menstrual. Permite guardar cómo fue cada día y utiliza esos datos para mostrar estimaciones del próximo periodo, la ovulación y la ventana fértil.

El módulo está separado de los planes de ahorro y de las actividades compartidas del calendario. Las dos cuentas autorizadas pueden ver y actualizar los datos de Mi ciclo en tiempo real.

> Las predicciones son aproximadas y no sustituyen la valoración de un profesional de la salud. No utilices el módulo como método anticonceptivo.

## Cómo entrar

1. Abre la aplicación.
2. Inicia sesión con tu correo y contraseña de Supabase.
3. En el menú selecciona **Mi ciclo**.
4. Espera a que cargue el calendario.

Si no aparece la sección o se muestra un error, revisa la sección [Solución de problemas](#solución-de-problemas).

## Primer uso

Para que el módulo pueda calcular predicciones necesita conocer el inicio de un ciclo.

1. Abre **Mi ciclo**.
2. Busca el primer día en que comenzó el sangrado.
3. Pulsa ese día en el calendario.
4. En **Flujo**, selecciona **Ligero**, **Medio** o **Abundante**.
5. Selecciona los síntomas o estados de ánimo que quieras guardar.
6. Pulsa **Guardar registro**.

Al guardar el primer día con flujo se crea el ciclo actual. A partir de ese momento la tarjeta comenzará a mostrar el día del ciclo y las estimaciones disponibles.

## Registrar un día

Puedes registrar un día de dos maneras:

- Pulsando cualquier fecha del calendario.
- Pulsando **Registrar hoy** o **Registrar estado de hoy**.

El formulario tiene tres grupos:

### Flujo

Selecciona una opción:

- **Sin flujo:** no hubo sangrado.
- **Ligero:** flujo leve o manchado.
- **Medio:** flujo de intensidad intermedia.
- **Abundante:** flujo intenso.

### Estado de ánimo

Puedes elegir uno o varios estados, por ejemplo:

- Feliz.
- Triste.
- Sensible.
- Tranquila.
- Irritable.

### Síntomas

Puedes seleccionar uno o varios síntomas, por ejemplo:

- Cólicos.
- Dolor de cabeza.
- Pecho sensible.
- Dolor lumbar.
- Cansancio.

No es obligatorio seleccionar síntomas o estados de ánimo. Lo importante para detectar el inicio de un ciclo es indicar correctamente el flujo.

## Corregir un registro

Si registraste un día incorrectamente, vuelve a pulsar la misma fecha y guarda las opciones correctas. El sistema actualiza el registro existente de ese día; no crea una copia adicional.

Esto permite corregir:

- La intensidad del flujo.
- Los síntomas.
- El estado de ánimo.

## Cómo leer el calendario

Cada día aparece como una celda del calendario mensual.

- **Punto rojo:** existe un registro con flujo diferente de “Sin flujo”.
- **Borde rojo:** periodo estimado por el sistema.
- **Fondo azul claro:** ventana fértil estimada.
- **Fondo azul más marcado:** día de ovulación estimado.
- **Resaltado verde:** día actual.

En teléfonos, el calendario muestra una versión compacta para que las celdas mantengan un tamaño cómodo y no se deformen.

## Cambiar de mes

En la parte superior del calendario encontrarás tres controles:

- Flecha izquierda: mes anterior.
- Botón central: volver al mes actual.
- Flecha derecha: mes siguiente.

Puedes consultar meses anteriores para revisar tus registros o meses posteriores para ver las predicciones.

## Tarjeta “Tu ciclo”

La tarjeta de predicciones muestra:

### Día del ciclo

Indica cuántos días han transcurrido desde el inicio del ciclo actual.

Ejemplo:

```text
Día 8 de tu ciclo
```

El primer día de sangrado se considera el día 1.

### Próximo periodo

Muestra una fecha aproximada y cuántos días faltan para ella.

La aplicación calcula esa fecha sumando el promedio de duración del ciclo al inicio del ciclo actual.

### Promedio

El promedio se calcula usando hasta los últimos 6 ciclos completados.

El sistema descarta automáticamente ciclos:

- Menores de 21 días.
- Mayores de 45 días.

Esto evita que un ciclo excepcionalmente corto o largo distorsione la predicción.

Si todavía no existen ciclos históricos válidos, se utiliza un valor inicial de 28 días.

### Ovulación

La ovulación se estima 14 días antes del próximo periodo previsto.

### Ventana fértil

Se estima desde 5 días antes de la ovulación hasta 1 día después.

Estas fechas son cálculos aproximados basados en ciclos anteriores y no representan una certeza biológica.

## Qué ocurre al comenzar un nuevo periodo

Cuando registras flujo diferente de **Sin flujo**, el sistema revisa el ciclo actual.

Si han transcurrido al menos 10 días desde su inicio:

1. Cierra el ciclo anterior con la fecha del nuevo sangrado.
2. Calcula la duración del ciclo en días.
3. Crea un nuevo ciclo con la fecha del nuevo sangrado.
4. Usa el nuevo ciclo para las siguientes predicciones.

La regla de 10 días evita que el sistema cierre el ciclo por un registro normal de sangrado dentro del mismo periodo.

## Privacidad y sincronización

Los registros menstruales se guardan en Supabase asociados a la cuenta que inició sesión y forman un espacio compartido entre las dos cuentas autorizadas.

- Las dos cuentas autorizadas pueden leer los ciclos compartidos.
- Las dos cuentas autorizadas pueden leer los registros diarios compartidos.
- Las dos cuentas autorizadas pueden editar o eliminar registros compartidos.
- Los cambios se guardan en la nube.
- Al volver a abrir la aplicación, los registros se recuperan automáticamente.

Los datos menstruales no se mezclan con los planes o actividades compartidos y ninguna otra cuenta autenticada tiene acceso.

## Uso desde celular

La vista está adaptada para pantallas pequeñas:

- El calendario ocupa el ancho disponible.
- Las tarjetas se organizan verticalmente.
- Los botones tienen un área cómoda para tocar.
- Los textos de la tarjeta se ajustan sin salir de su contenedor.
- El formulario aparece en una ventana desplazable si la pantalla es corta.
- No es necesario hacer zoom ni desplazarse horizontalmente.

## Recomendación de registro

Para obtener predicciones más útiles:

1. Registra el primer día real de sangrado, no el día anterior.
2. Guarda el flujo de cada día cuando sea posible.
3. Mantén el registro durante varios ciclos.
4. Corrige los datos si te equivocaste.
5. No interpretes un único ciclo irregular como una tendencia.

La precisión mejora cuando existen varios ciclos completados y los datos son consistentes.

## Solución de problemas

### No aparece la tarjeta de predicciones

Registra el primer día con flujo. Sin un ciclo actual el sistema no puede calcular el día del ciclo ni las fechas estimadas.

### La pantalla dice que no se pudieron cargar los datos

Comprueba que:

1. Tienes conexión a internet.
2. Iniciaste sesión con la cuenta correcta.
3. Las tablas `user_preferences`, `cycles` y `daily_logs` fueron creadas en Supabase.
4. Las políticas RLS del archivo [`supabase/schema.sql`](supabase/schema.sql) fueron ejecutadas.

### Mis datos no aparecen en otro usuario

Es el comportamiento esperado. Los datos de **Mi ciclo** son privados por usuario. Los planes y actividades compartidos funcionan de manera independiente.

### Las fechas parecen incorrectas

Comprueba que:

- El inicio del ciclo esté registrado en la fecha correcta.
- No hayas registrado un nuevo periodo antes de que transcurrieran 10 días.
- Existan suficientes ciclos históricos.

Las predicciones no deben considerarse exactas, especialmente durante los primeros ciclos registrados.

## Para actualizar la base de datos

Si el proyecto todavía no tiene las tablas del módulo:

1. Abre el proyecto en Supabase.
2. Entra a **SQL Editor**.
3. Abre el archivo [`supabase/schema.sql`](supabase/schema.sql).
4. Copia y ejecuta todo su contenido.

El script puede ejecutarse nuevamente porque está preparado para no fallar cuando las tablas o publicaciones Realtime ya existen.

## Archivos relacionados

- Implementación: [`Index.html`](Index.html)
- Esquema de base de datos: [`supabase/schema.sql`](supabase/schema.sql)
- Documentación técnica: [`MODULO-MI-CICLO.md`](MODULO-MI-CICLO.md)
