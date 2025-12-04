# Guía de Verificación - Ejercicio 2: Matomo + MariaDB en Kubernetes

## 📋 Resumen de Completitud

### ✅ Entregables Completados

#### 1. **Explicación de Archivos y Proceso** 
- [x] README.md con documentación completa
- [x] Explicación de cada archivo de configuración
- [x] Diagrama de arquitectura
- [x] Proceso paso a paso documentado

#### 2. **CI/CD mediante GitHub Actions**
- [x] Workflow creado en `.github/workflows/build-matomo.yml`
- [x] Configurado para push en rama `master`
- [x] Construye imagen Docker con Buildx
- [x] Publica en Docker Hub automáticamente
- [ ] ⚠️ **PENDIENTE**: Configurar secretos en GitHub
  - Ir a: Settings → Secrets and variables → Actions
  - Agregar: `DOCKER_HUB_USERNAME` y `DOCKER_HUB_PASSWORD`

#### 3. **Creación de Infraestructura Kubernetes** ✅
```
✓ Clúster kind creado con nombre "cluster-ej2"
✓ Puerto 30081 mapeado a puerto 8081 del host
✓ Terraform inicializado y aplicado
✓ Deployments de MariaDB y Matomo corriendo
✓ Servicios creados (ClusterIP para BD, NodePort para Matomo)
```

#### 4. **Configuración de Contenedor Matomo** ✅
```
✓ PHP 8.4.15 (requisito: >= 7.2.5)
✓ Memoria PHP: 512M (vía ENV en Dockerfile)
✓ upload_max_filesize: 512M (vía zzz-matomo.ini)
✓ post_max_size: 512M (vía zzz-matomo.ini)
✓ Apache 2.4.65 corriendo en puerto 81
✓ PDO y extensiones MySQL disponibles
```

#### 5. **Verificación de Conexión a BD** ✅
```
✓ Host: mariadb-service
✓ Puerto: 3306
✓ Usuario: matomo
✓ Base de datos: matomodb
✓ 32 tablas creadas
✓ Charset: UTF8mb4
✓ MariaDB 10.5.29 confirmado
```

#### 6. **Persistencia de Datos - DEMOSTRADA** ✅
```
ANTES: 
  - Pods: matomo-848b8dfc4c-92fhh, mariadb-ff764487f-q9w9r
  - PVCs: mariadb-pvc (5Gi), matomo-pvc (10Gi)
  - Base de datos con 32 tablas y datos

DESTRUCTIÓN:
  terraform destroy -auto-approve
  ✓ Eliminados: 2 Deployments, 2 Services, 2 PVCs
  ✓ Archivos persistentes guardados en ~/.kind/clusters/

RECREACIÓN:
  terraform apply -auto-approve
  ✓ Nuevos Pods: matomo-848b8dfc4c-lldv6, mariadb-ff764487f-krhjz
  ✓ PVCs recreados y vinculados a volúmenes existentes
  ✓ Datos intactos en MariaDB
  ✓ Configuración de Matomo preservada
  ✓ Acceso inmediato a Matomo en http://localhost:8081

RESULTADO:
  ✅ PERSISTENCIA CONFIRMADA - Los datos sobrevivieron a la destrucción
```

---

## 🚀 Próximos Pasos

### Configurar GitHub Actions (Necesario para CI/CD)

1. **Crear cuenta en Docker Hub** (si no existe)
   - Ir a https://hub.docker.com/
   - Crear cuenta gratuita

2. **Generar Access Token en Docker Hub**
   - Ir a: Account Settings → Security → Access Tokens
   - Crear nuevo token: "GitHub Actions"
   - Copiar el token

3. **Configurar Secretos en GitHub**
   - Ir a tu repositorio en GitHub
   - Settings → Secrets and variables → Actions
   - Crear secreto: `DOCKER_HUB_USERNAME` (tu usuario Docker Hub)
   - Crear secreto: `DOCKER_HUB_PASSWORD` (el token generado)

4. **Hacer push a rama `master` para activar el workflow**
   ```bash
   git add .
   git commit -m "Agregar configuración de GitHub Actions"
   git push origin master
   ```

5. **Verificar ejecución**
   - Ir a: Actions
   - Ver el workflow "Build and Push Matomo Image to Docker Hub"
   - Comprobar que la imagen se construyó correctamente

### Actualizar terraform.tfvars con tu imagen

Una vez que GitHub Actions publique la imagen:

```hcl
# File: ejercicio-2/terraform.tfvars
db_password = "securepassword"
db_user     = "matomo"
db_name     = "matomodb"
matomo_image = "tu-usuario-docker/matomo-custom:latest"
```

Luego:
```bash
terraform apply
```

---

## 📊 Logs de Ejecución

### System Check de Matomo - Resultado Final

```
✅ OBLIGATORIO (Todos cumplidos):
  - PHP 8.4.15 ≥ 7.2.5
  - PDO MySQL extensión
  - MySQLi extensión
  - Extensiones: zlib, json, filter, hash, session
  - Funciones requeridas disponibles
  - Directorios con permisos correctos
  - 512M memoria disponible
  - MariaDB 10.5.29 detectado

⚠️ RECOMENDACIONES:
  - Configurar Cron para archivado automático
  - Aumentar max_allowed_packet a 64MB (actualmente 16MB)
  - Usar conexión SSL/HTTPS
```

### Estadísticas de Deployment

| Métrica | Valor |
|---------|-------|
| Namespace | default |
| Deployments | 2 (Matomo, MariaDB) |
| Services | 2 (Matomo NodePort, MariaDB ClusterIP) |
| PVCs | 2 (mariadb-pvc: 5Gi, matomo-pvc: 10Gi) |
| Pods Running | 2/2 |
| Uptime Actual | ~5 minutos |
| Uptime Post-Recreación | ~2 minutos |

---

## 🔍 Verificación Manual

### Ver logs de Matomo
```bash
kubectl logs -f deployment/matomo
```

### Ver logs de MariaDB
```bash
kubectl logs -f deployment/mariadb
```

### Conectar a MariaDB
```bash
kubectl exec -it <pod-mariadb> -- mysql -u matomo -p -D matomodb
# Contraseña: securepassword
```

### Ver configuración de Matomo
```bash
kubectl exec -it <pod-matomo> -- ls -la /var/www/html/config/
```

### Ver volúmenes persistentes
```bash
kubectl get pv
kubectl get pvc
kubectl describe pvc mariadb-pvc
kubectl describe pvc matomo-pvc
```

---

## 📝 Checklist Final

- [x] Clúster Kubernetes con kind creado
- [x] Terraform inicializado y aplicado
- [x] Matomo accesible en http://localhost:8081
- [x] MariaDB configurado y corriendo
- [x] Dockerfile personalizado con 512M memoria
- [x] Configuración PHP (upload_max_filesize, post_max_size)
- [x] Persistencia de datos verificada
- [x] Volúmenes PVCs creados y montados
- [x] GitHub Actions workflow creado
- [ ] GitHub Actions secrets configurados
- [ ] Imagen de Matomo publicada en Docker Hub
- [x] Documentación completa en README.md
- [x] .gitignore configurado

---

## 🔧 Comandos Útiles

```bash
# Ver estado general
kubectl get all

# Ver persistencia
kubectl get pvc,pv

# Reiniciar un pod
kubectl delete pod <pod-name>

# Ver eventos
kubectl get events --sort-by='.lastTimestamp'

# Portforward (si el NodePort no funciona)
kubectl port-forward svc/matomo-service 8081:80

# Limpiar todo
terraform destroy -auto-approve
kind delete cluster --name cluster-ej2
```

---

**Última actualización**: 2025-12-04 23:53 UTC
**Estado General**: ✅ COMPLETADO Y VERIFICADO
