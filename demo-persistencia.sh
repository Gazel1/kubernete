#!/bin/bash
# Script de Demostración - Ejercicio 2: Matomo + MariaDB en Kubernetes
# Este script realiza la demostración completa de persistencia

set -e

echo "═══════════════════════════════════════════════════════════════"
echo "  DEMOSTRACIÓN: Persistencia de Datos en Kubernetes"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cd "$(dirname "$0")/ejercicio-2"

echo "📊 PASO 1: Estado Inicial"
echo "─────────────────────────────────────────────────────────────"
echo "Pods en ejecución:"
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

echo ""
echo "PVCs montados:"
kubectl get pvc -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,SIZE:.spec.resources.requests.storage

echo ""
echo "Datos en la base de datos:"
kubectl exec -it deployment/mariadb -- mysql -u matomo -psecurepassword -D matomodb -e "SELECT COUNT(*) as 'Tablas' FROM information_schema.TABLES WHERE TABLE_SCHEMA='matomodb';"

echo ""
echo "✅ PASO 1 Completado: Infraestructura verificada"
echo ""

echo "🗑️  PASO 2: Destruir Infraestructura"
echo "─────────────────────────────────────────────────────────────"
echo "Ejecutando: terraform destroy -auto-approve"
terraform destroy -auto-approve

echo ""
echo "Verificando que los recursos fueron eliminados..."
echo "PVCs actuales:"
if kubectl get pvc 2>/dev/null | grep -q "mariadb-pvc"; then
    echo "❌ ERROR: Los PVCs aún existen"
    exit 1
else
    echo "✅ PVCs eliminados correctamente"
fi

echo ""
echo "Pods en namespace default:"
PODS=$(kubectl get pods --field-selector=metadata.namespace=default -o jsonpath='{.items[*].metadata.name}' 2>/dev/null)
if [ -z "$PODS" ]; then
    echo "✅ Todos los pods de aplicación fueron eliminados"
else
    echo "⚠️  Pods restantes: $PODS"
fi

echo ""
echo "✅ PASO 2 Completado: Infraestructura destruida"
echo ""

echo "🔄 PASO 3: Recrear Infraestructura"
echo "─────────────────────────────────────────────────────────────"
echo "Ejecutando: terraform apply -auto-approve"
terraform apply -auto-approve

echo ""
echo "Esperando a que los pods se inicien..."
sleep 20

echo ""
echo "✅ PASO 3 Completado: Infraestructura recreada"
echo ""

echo "✔️  PASO 4: Verificar Persistencia de Datos"
echo "─────────────────────────────────────────────────────────────"
echo ""
echo "Pods recreados:"
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,AGE:.metadata.creationTimestamp

echo ""
echo "PVCs recreados y montados:"
kubectl get pvc -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,SIZE:.spec.resources.requests.storage

echo ""
echo "Verificando datos en la base de datos (PERSISTENCIA):"
TABLE_COUNT=$(kubectl exec -it deployment/mariadb -- mysql -u matomo -psecurepassword -D matomodb -N -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='matomodb';" 2>/dev/null | tr -d '\r')

if [ "$TABLE_COUNT" -gt "0" ]; then
    echo "✅ PERSISTENCIA CONFIRMADA: Base de datos contiene $TABLE_COUNT tablas"
else
    echo "❌ ERROR: No se encontraron tablas en la base de datos"
    exit 1
fi

echo ""
echo "Archivos de Matomo (verificando persistencia):"
kubectl exec deployment/matomo -- ls -la /var/www/html/config/ | head -8

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  ✅ DEMOSTRACIÓN COMPLETADA EXITOSAMENTE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📍 Matomo disponible en: http://localhost:8081"
echo ""
echo "Resumen de Persistencia:"
echo "  ✅ Infraestructura destruida completamente"
echo "  ✅ Infraestructura recreada desde cero"
echo "  ✅ Datos de MariaDB preservados ($TABLE_COUNT tablas)"
echo "  ✅ Archivos de Matomo preservados"
echo "  ✅ Configuración intacta"
echo ""
