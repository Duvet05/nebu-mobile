# Publicar Nebu en Google Play

## Preparación inicial en Play Console

1. En **Production → Countries/regions**, guardar los países de lanzamiento. La API permite consultar esta selección, no configurarla.
2. Completar **App content**: audiencia real, Data safety, acceso para revisión y clasificación. No marcar «solo adultos» únicamente porque el teléfono lo configura un padre: revisar también el uso infantil del producto.
3. Comprobar login, consentimiento, Bluetooth/Wi-Fi, audio y eliminación en un teléfono. Analytics y diagnósticos están apagados por defecto; una elección explícita previa se conserva.
4. Ejecutar `node scripts/check-public-links.mjs`. Comprueba HTTP, contenido básico, App Links y MX; no envía formularios ni demuestra entrega de correo.

## Crear y probar el paquete

En GitHub Actions → **Build & Publish Android**, usar `main`, `play_track=internal` y `release_status=COMPLETED` para distribuir a testers; `DRAFT` solo prepara un borrador. El número de versión crece automáticamente y aparece en el resumen. Para descargar únicamente el AAB, usar `publish_to_play=false`.

## Pasar el mismo paquete a producción

En GitHub Actions → **Promote Android to Production**, introducir el `version_code` probado, el track de origen y:

- `draft` (predeterminado): preparar el borrador de producción.
- `completed`: solicitar el lanzamiento; revisar después el estado real en Publishing overview. No implica aprobación instantánea de Google.

No recompila: usa exactamente ese artefacto, conserva sus notas y comprueba que no sea una versión anterior ni reemplace otro borrador/lanzamiento progresivo. El flujo prueba sus salvaguardas y los enlaces públicos antes de tocar Play, y no cancela revisiones en curso.

Si Google devuelve `Precondition check failed`, no repetir builds: revisar **Production**, países, acceso a producción y **Publishing overview**. No hay una espera adicional que un script pueda eliminar ni debe repetirse el periodo de pruebas por cambiar la ficha.

El workflow antiguo fijado a 1062 fue sustituido por este flujo parametrizado.

Referencias: [lanzamientos](https://support.google.com/googleplay/android-developer/answer/9859348), [países](https://support.google.com/googleplay/android-developer/answer/7550024), [API y revisiones](https://developers.google.com/android-publisher/api-ref/rest/v3/edits/commit).
