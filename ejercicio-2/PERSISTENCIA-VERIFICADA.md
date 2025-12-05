# 🎯 Demostración de Persistencia - Ejercicio 2

**Fecha:** 5 de Diciembre, 2025  
**Estado:** ✅ PERSISTENCIA CONFIRMADA

## Resumen de la Prueba

Se realizó una demostración de persistencia de datos destruyendo y recreando los Deployments (pods) mientras se mantenían los **PersistentVolumeClaims (PVCs)** intactos.

## Proceso Ejecutado

### 1. Estado Inicial
```bash
kubectl exec -it deployment/mariadb -- mysql -u matomo -psecurepassword -D matomodb -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='matomodb';"
```
**Resultado:** 32 tablas ✅

### 2. Destrucción de Deployments
```bash
kubectl delete deployment mariadb matomo --wait=true
```
- MariaDB Deployment eliminado
- Matomo Deployment eliminado
- **PVCs mantenidas intactas**

### 3. Recreación de Deployments
```bash
terraform apply -auto-approve
```
- Nuevos pods creados
- Pods vinculadas a los mismos PVCs

### 4. Verificación de Persistencia
```bash
kubectl exec -it deployment/mariadb -- mysql -u matomo -psecurepassword -D matomodb -e "SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='matomodb';"
```
**Resultado:** 32 tablas ✅

## Resultado Final

| Métrica | Antes | Después | Estado |
|---------|-------|---------|--------|
| Tablas en MariaDB | 32 | 32 | ✅ Persistidas |
| Matomo Dashboard | Funcional | Funcional | ✅ Sin reconfiguración |
| Datos de Instalación | Presente | Presente | ✅ Intactos |

## Conclusión

**✅ LA PERSISTENCIA FUNCIONA CORRECTAMENTE**

Los datos de Matomo y MariaDB persisten incluso después de destruir y recrear los pods, gracias al uso de PersistentVolumeClaims que almacenan los datos en volúmenes que persisten independientemente del ciclo de vida de los pods.

## Requisito Cumplido

**Requisito 5:** Demostrar persistencia de datos en infraestructura - **COMPLETADO** ✅

---

*Demostración completada exitosamente en el cluster kind "cluster-ej2"*
