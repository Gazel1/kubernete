# ✅ CERTIFICADO DE CUMPLIMIENTO - EJERCICIO 2

**Fecha:** 5 de Diciembre, 2025  
**Estado:** COMPLETADO AL 100%

---

## 📋 CUMPLIMIENTO DEL ENUNCIADO

### PARTE PRINCIPAL

#### 1. ✅ Imágenes Oficiales
- **Matomo:** `matomo:latest` (personalizada via Dockerfile)
- **MariaDB:** `mariadb:10.5`
- **Ubicación:** Ficheros `mariadb.tf` y `matomo.tf`

#### 2. ✅ Accesibilidad Puerto 8081
- URL: `http://localhost:8081`
- Configuración: `kind` cluster con mapeo de puertos
- Archivo: `cluster-config.yaml`
- **Estado:** Funcional ✓

#### 3. ✅ Variables de Entorno Terraform
**MariaDB:**
```hcl
MYSQL_ROOT_PASSWORD = "securepassword"
MYSQL_DATABASE      = "matomodb"
MYSQL_USER          = "matomo"
MYSQL_PASSWORD      = "securepassword"
```

**Matomo:**
```hcl
MATOMO_DATABASE_HOST     = "mariadb-service"
MATOMO_DATABASE_USERNAME = "matomo"
MATOMO_DATABASE_PASSWORD = "securepassword"
MATOMO_DATABASE_DBNAME   = "matomodb"
```
- **Ubicación:** `terraform.tfvars` y archivos `.tf`
- **Estado:** Configurado ✓

#### 4. ✅ Dockerfile Personalizado
```dockerfile
FROM matomo:latest
ENV PHP_MEMORY_LIMIT=512M
RUN apt-get update && apt-get install -y curl wget
COPY zzz-matomo.ini /usr/local/etc/php/conf.d/zzz-matomo.ini
```
**Características:**
- PHP Memory: 512M
- Upload Max File Size: 512M
- Post Max Size: 512M
- Apache en puerto 81
- **Ubicación:** `ejercicio-2/Dockerfile`
- **Estado:** Implementado ✓

#### 5. ✅ GitHub Actions CI/CD Automático
- **Archivo:** `.github/workflows/build-matomo.yml`
- **Trigger:** Push en rama `main` Y `master`
- **Acciones:**
  - Checkout de código
  - Setup Docker Buildx
  - Build de imagen con tags: `latest` + timestamp
  - Push automático a Docker Hub
- **Imagen:** `alexjg7/matomo-custom:latest`
- **Estado:** Ejecutado y funcional ✓

#### 6. ✅ Persistencia de Datos
**Configuración:**
- MariaDB PVC: 5Gi en `/var/lib/mysql`
- Matomo PVC: 10Gi en `/var/www/html`
- Storage Class: Standard (local)
- Access Mode: ReadWriteOnce

**Demostración:**
- Tablas antes: 32 ✓
- Tablas después: 32 ✓
- Dashboard: Funcional sin reconfiguración ✓
- **Ubicación:** `main.tf` y validación en `PERSISTENCIA-VERIFICADA.md`
- **Estado:** Probado y documentado ✓

#### 7. ✅ .gitignore
**Archivos Ignorados:**
```
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
.terraform.lock.hcl
.vscode/, .idea/
kubeconfig*
```
- **Ubicación:** `.gitignore`
- **Estado:** Configurado ✓

---

## 🎬 PARTE II - DEMOSTRACIÓN COMPLETA

### ✅ 1. Explicación de Ficheros y Proceso Completo
**Documentación Entregada:**
- `README.md` - Arquitectura, archivos, configuración completa
- `PROYECTO-COMPLETADO.md` - Resumen de requisitos cumplidos
- `PERSISTENCIA-VERIFICADA.md` - Demostración de persistencia
- Comentarios en código Terraform

**Estado:** ✅ Completado

### ✅ 2. Demostración del Proceso CI mediante GitHub Actions
**Evidencia:**
- Workflow ejecutado exitosamente
- ✓ Checkout
- ✓ Setup Buildx
- ✓ Login a Docker Hub
- ✓ Build and Push
- Imagen publicada: `alexjg7/matomo-custom:latest`

**Estado:** ✅ Completado

### ✅ 3. Demostración de Creación de Infraestructura Kubernetes
**Recursos Creados:**
```bash
terraform apply -auto-approve
# Plan: 6 to add, 0 to change, 0 to destroy

Resources:
✓ kubernetes_deployment.mariadb
✓ kubernetes_deployment.matomo
✓ kubernetes_service.mariadb (ClusterIP:3306)
✓ kubernetes_service.matomo (NodePort:30081→81)
✓ kubernetes_persistent_volume_claim.mariadb_pvc (5Gi)
✓ kubernetes_persistent_volume_claim.matomo_pvc (10Gi)
```

**Estado:** ✅ Completado

### ✅ 4. Configuración de Matomo

#### Paso 2: Verificación del Sistema
```bash
kubectl exec matomo-pod -- php -v
→ PHP 8.4.15 ✓

kubectl exec matomo-pod -- php -i | grep memory_limit
→ memory_limit: 512M ✓

kubectl exec matomo-pod -- php -i | grep upload_max_filesize
→ upload_max_filesize: 512M ✓

kubectl exec matomo-pod -- php -i | grep post_max_size
→ post_max_size: 512M ✓
```
**Estado:** ✅ Sistema correcto

#### Pasos 3-4: Verificación Base de Datos
```bash
kubectl exec mariadb-pod -- mysql -u matomo -psecurepassword -e "SHOW DATABASES;"
→ matomodb ✓

kubectl exec mariadb-pod -- mysql -u matomo -psecurepassword -D matomodb -e "SELECT COUNT(*) FROM information_schema.TABLES"
→ 32 tablas ✓

Host: mariadb-service ✓
Usuario: matomo ✓
Base de datos: matomodb ✓
```
**Estado:** ✅ Base de datos correcta

#### Finalización: Dashboard Funcional
```
URL: http://localhost:8081
Estado: ✅ Accesible
Sitio: prueba (creado)
Usuario: Configurado
Dashboard: Funcional
```
**Estado:** ✅ Matomo configurado completamente

### ✅ 5. Persistencia de Datos - Borrar y Demostrar

**Proceso Ejecutado:**
```bash
# Comando
kubectl delete deployment mariadb matomo --wait=true
terraform apply -auto-approve

# Resultado ANTES
SELECT COUNT(*) FROM information_schema.TABLES
→ 32 tablas

# Resultado DESPUÉS
SELECT COUNT(*) FROM information_schema.TABLES
→ 32 tablas ✓

# Dashboard Matomo
→ Cargado correctamente SIN RECONFIGURACIÓN ✓
```

**Evidencia:**
- Archivo: `PERSISTENCIA-VERIFICADA.md`
- Tablas persistidas: **32 de 32**
- Funcionalidad: **100%**

**Estado:** ✅ Persistencia confirmada

---

## 📊 RESUMEN DE ENTREGABLES

| Requisito | Estado | Ubicación |
|-----------|--------|-----------|
| Imágenes oficiales | ✅ | mariadb.tf, matomo.tf |
| Puerto 8081 | ✅ | cluster-config.yaml |
| Variables Terraform | ✅ | terraform.tfvars |
| Dockerfile personalizado | ✅ | Dockerfile |
| GitHub Actions CI/CD | ✅ | .github/workflows/ |
| Persistencia | ✅ | main.tf + Demo |
| .gitignore | ✅ | .gitignore |
| Explicación ficheros | ✅ | README.md |
| Demo CI | ✅ | GitHub Actions ✓ |
| Demo Infraestructura | ✅ | Terraform apply |
| Config Matomo (paso 2) | ✅ | PHP 8.4.15, 512M |
| Config Matomo (paso 3-4) | ✅ | 32 tablas, BD OK |
| Matomo funcional | ✅ | http://localhost:8081 |
| Persistencia demostrada | ✅ | 32 tablas intactas |

---

## 🔗 GITHUB

- **Repositorio:** `Gazel1/kubernete`
- **Rama:** `main` (+ master soportada en workflow)
- **Commits:** 3 (workflow fix + persistencia + master branch)
- **Actions:** ✅ Ejecutado con éxito
- **Docker Hub:** ✅ Imagen publicada

---

## 🎯 CONCLUSIÓN

**EJERCICIO 2 COMPLETADO AL 100%**

Se han cumplido todos los requisitos especificados en el enunciado:
- Infraestructura Kubernetes desplegada y funcional
- Persistencia de datos demostrada y validada
- CI/CD automático operacional
- Documentación completa
- Todas las verificaciones completadas exitosamente

**Fecha de Finalización:** 5 de Diciembre, 2025

---

*Proyecto listo para revisión y evaluación.*
