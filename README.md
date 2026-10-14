# Captación y calificación de prospectos — landing + n8n + CRM

Demo técnica de un embudo completo: una **landing page** captura el prospecto, un **workflow de n8n**
lo valida, lo enriquece, lo califica y lo enruta, y lo deja registrado en el **CRM**.

Es el recorrido que hace cualquier agencia cuando conecta un formulario con un CRM, montado de punta a
punta y con las decisiones explicadas. Todo lo que hay aquí se puede ejecutar sin pagar nada.

```
Landing  →  Webhook   →  Validar y    →  Enriquecer  →  Calificar   →  Enrutar      →  Responder
(form)      (n8n)        normalizar      (API)          caliente/       aviso o         al
                                                        tibio/frío      seguimiento     formulario
```

## Qué demuestra

| | |
|---|---|
| **Landing page** | Página de captación con formulario, validación en el navegador y estados de error visibles |
| **Funnel** | Calificación automática por presupuesto y urgencia, con tres rutas distintas |
| **Automatización** | Workflow de n8n con validación, bifurcación, llamada a API externa y respuesta |
| **Integración** | Webhook de entrada, API externa de enriquecimiento y escritura en el CRM |
| **Criterio** | Manejo de errores, anti-duplicados y validación también del lado del servidor |

## Cómo probarlo

1. **Levanta n8n** (Docker):
   ```bash
   docker run -it --rm -p 5678:5678 -v n8n_demo:/home/node/.n8n n8nio/n8n
   ```
2. **Importa el flujo**: en n8n, *Workflows → Import from File* → `n8n/flujo-captacion.json`.
3. **Copia la URL del webhook** (nodo Webhook → *Production URL*) y pégala en `index.html`, en la
   constante `WEBHOOK`.
4. **Abre `index.html`** en el navegador y envía el formulario.

## Decisiones que vale la pena mirar

**La validación está en los dos lados.** El formulario valida para que el usuario tenga respuesta
inmediata, y el flujo valida otra vez porque el webhook es una dirección pública: cualquiera puede
llamarlo sin pasar por la página. Confiar en la validación del navegador es confiar en el cliente.

**Un prospecto que llega dos veces no se duplica.** La gente envía el formulario dos veces cuando no ve
respuesta rápido. El flujo lo detecta por correo y actualiza en vez de crear otro registro.

**El error se maneja, no se ignora.** Si la API de enriquecimiento no responde, el prospecto se guarda
igual con lo que se tenga: perder un lead porque falló un servicio secundario es peor que guardarlo
incompleto.

**El tiempo de respuesta es parte del producto.** El flujo contesta al formulario de inmediato y sigue
trabajando después; el usuario no se queda mirando un botón girando.

## Estructura

```
index.html                  La landing con el formulario
n8n/flujo-captacion.json    El workflow exportado, listo para importar
capturas/                   Capturas del flujo y de las ejecuciones
```

## Lo que NO está aquí

Esto es una demostración construida para mostrar el método. Mi trabajo principal es una plataforma CRM
con asistentes conversacionales que mantengo en producción, de mi propiedad, y de la que no publico
código. Puedo recorrerla en vivo compartiendo pantalla.
