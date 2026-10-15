#!/usr/bin/env bash
# Prueba el flujo contra un n8n que ya lo tenga importado y activo.
#
#   ./probar.sh                              # contra http://localhost:5678
#   ./probar.sh https://mi-n8n.com/webhook/lead
#
# Son los ocho casos que importan: los tres caminos de calificación, el rechazo, el duplicado,
# el dominio que no recibe correo, el cuerpo vacío y una entrada que no viene de la landing.

set -u
URL="${1:-http://localhost:5678/webhook/lead}"
fallidos=0

# Cada corrida usa correos propios (nombre+1760000000@...). Sin esto, la segunda vez que se
# corre el script el flujo reconoce los correos de la vez anterior y marca todo como repetido,
# que es justo lo que debe hacer: la ventana anti-duplicados dura 24 horas.
SELLO=$(date +%s)

probar() {
  local titulo="$1" esperado="$2" cuerpo="$3"
  local respuesta codigo
  cuerpo="${cuerpo//@/+$SELLO@}"
  respuesta=$(curl -s -m 30 -w $'\n%{http_code}' -X POST "$URL" \
    -H 'Content-Type: application/json' -d "$cuerpo")
  codigo="${respuesta##*$'\n'}"
  respuesta="${respuesta%$'\n'*}"

  if [ "$codigo" = "$esperado" ]; then
    printf '  ok   %-52s HTTP %s\n' "$titulo" "$codigo"
  else
    printf '  MAL  %-52s HTTP %s (se esperaba %s)\n' "$titulo" "$codigo" "$esperado"
    fallidos=$((fallidos + 1))
  fi
  printf '       %s\n' "$respuesta"
}

echo "Probando $URL"
echo

probar "Caliente: empresa, presupuesto alto, lo necesita ya" 200 \
  '{"nombre":"Laura Restrepo","email":"laura@clinicasanrafael.com","telefono":"300 123 4567",
    "presupuesto":"mas_1500","urgencia":"ya","origen":"landing-demo"}'

probar "Tibio: correo gratuito, presupuesto medio, este mes" 200 \
  '{"nombre":"Carlos Mesa","email":"carlos.mesa@gmail.com","telefono":"3019876543",
    "presupuesto":"500_1500","urgencia":"mes","origen":"landing-demo"}'

probar "Frío: poco presupuesto, solo explorando" 200 \
  '{"nombre":"Ana Gil","email":"anagil@hotmail.com","telefono":"+57 320 555 1122",
    "presupuesto":"menos_500","urgencia":"explorando","origen":"landing-demo"}'

probar "Rechazo: correo mal escrito y teléfono corto" 400 \
  '{"nombre":"X","email":"no-es-correo","telefono":"123","presupuesto":"mas_1500","urgencia":"ya"}'

probar "Rechazo: cuerpo vacío" 400 '{}'

probar "Duplicado: el mismo correo sube de prioridad" 200 \
  '{"nombre":"Laura Restrepo","email":"laura@clinicasanrafael.com","telefono":"3001234567",
    "presupuesto":"mas_1500","urgencia":"ya"}'

probar "Dominio sin correo: no puede pasar de tibio" 200 \
  '{"nombre":"Pedro Nel","email":"pedro@estedominionoexiste-abc123.xyz","telefono":"3001112233",
    "presupuesto":"mas_1500","urgencia":"ya"}'

probar "Otro origen: presupuesto como número suelto" 200 \
  '{"nombre":"Marta Ortiz","email":"marta@ortizlegal.com","telefono":"3007778899",
    "presupuesto":"USD 1.800","urgencia":"inmediata","origen":"meta-ads"}'

echo
if [ "$fallidos" -eq 0 ]; then
  echo "8 casos · 0 fallidos"
else
  echo "8 casos · $fallidos fallidos"
fi
exit "$fallidos"
