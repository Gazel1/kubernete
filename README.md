# Ejercicio 2: Matomo + MariaDB en Kubernetes con Terraform

## Descripción General

Este ejercicio despliega una solución completa de **Matomo** (servidor de análisis web) + **MariaDB** en un clúster Kubernetes creado con **kind** y gestionado por **Terraform**. La imagen de Matomo se personaliza mediante un Dockerfile y se automatiza su construcción y publicación mediante GitHub Actions.

## Arquitectura

```
┌─────────────────────────────────────────────┐
│         Host (Puerto 8081)                   │
├─────────────────────────────────────────────┤
│  kind Cluster (Kubernetes)                   │
│  ┌───────────────────────────────────────┐  │
│  │  Matomo Pod (81)                      │  │
│  │  - PHP Memory: 512M                   │  │
│  │  - Upload Max: 512M                   │  │
│  │  - PVC: 10Gi                          │  │
│  └───────────────────────────────────────┘  │
│  ┌───────────────────────────────────────┐  │
│  │  MariaDB Pod (3306)                   │  │
│  │  - DB: matomodb                       │  │
│  │  - Usuario: matomo                    │  │
│  │  - PVC: 5Gi                           │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

## Archivos Explicados

### 1. **cluster-config.yaml**
Configuración de kind para crear un clúster Kubernetes local con mapeo de puertos.
- Puerto del contenedor: 30081 → Puerto del host: 8081
- Permite acceder a Matomo desde `http://localhost:8081`

### 2. **Dockerfile**
Personalización de la imagen oficial de Matomo:
- `PHP_MEMORY_LIMIT=512M` - Aumenta memoria disponible para PHP
- `upload_max_filesize = 512M` - Permite subidas de archivos grandes
- `post_max_size = 512M` - Permite posts grandes
- Configura Apache en puerto 81
- Copia configuración PHP personalizada

### 3. **zzz-matomo.ini**
Archivo de configuración PHP personalizado copiado al contenedor:
```ini
upload_max_filesize = 512M
post_max_size = 512M
```

### 4. **terraform/variables.tf**
Define las variables que se usan en la infraestructura:
- `db_password` - Contraseña de MariaDB
- `db_user` - Usuario de MariaDB
- `db_name` - Nombre de la base de datos
- `matomo_image` - Imagen de Docker a usar

### 5. **terraform/terraform.tfvars**
Valores concretos para las variables:
```hcl
db_password = "securepassword"
db_user     = "matomo"
db_name     = "matomodb"
matomo_image = "alexjg7/matomo-custom:latest"
```

### 6. **terraform/main.tf**
Configuración principal de Terraform:
- Provider de Kubernetes
- Recursos de PersistentVolumeClaim para ambos servicios

### 7. **terraform/mariadb.tf**
Despliegue de MariaDB:
- Imagen oficial: `mariadb:10.5`
- Variables de entorno para configuración
- Volumen persistente montado en `/var/lib/mysql`
- Servicio ClusterIP para conectividad interna

### 8. **terraform/matomo.tf**
Despliegue de Matomo:
- Imagen personalizada de Docker Hub
- Variables de entorno para conexión con BD
- Volumen persistente montado en `/var/www/html`
- Servicio NodePort para acceso externo (puerto 30081)

### 9. **mariadb-pvc.yaml y matomo-pvc.yaml**
Manifiestos YAML para PersistentVolumeClaims:
- MariaDB: 5Gi de almacenamiento
- Matomo: 10Gi de almacenamiento
- Modo de acceso: ReadWriteOnce

### 10. **.github/workflows/build-matomo.yml**
Flujo de CI/CD automático:
- Se ejecuta al hacer push a la rama `master`
- Construye la imagen Docker con Buildx
- Pushea a Docker Hub con tags `latest` y fecha/hora
- Requiere secretos: `DOCKER_HUB_USERNAME`, `DOCKER_HUB_PASSWORD`

### 11. **.gitignore**
Archivos ignorados por Git:
- Archivos de estado de Terraform (`*.tfstate`)
- Caché de Terraform (`.terraform/`)
- Variables sensibles (`*.tfvars`)
- Archivos del IDE y OS

## Proceso Completo

### Prerequisitos
```bash
# Instalar kind
choco install kind  # Windows
brew install kind   # macOS
sudo apt install kind  # Linux

# Instalar Terraform
choco install terraform  # Windows

# Instalar kubectl
choco install kubernetes-cli  # Windows

# Docker debe estar en ejecución
```

### Paso 1: Crear el Clúster Kubernetes
```bash
cd ejercicio-2
kind create cluster --name cluster-ej2 --config cluster-config.yaml
kubectl cluster-info --context kind-cluster-ej2
```

### Paso 2: Inicializar y Aplicar Terraform
```bash
terraform init
terraform plan
terraform apply
```

### Paso 3: Verificar Despliegues
```bash
kubectl get pods
kubectl get svc
kubectl get pvc
```

### Paso 4: Acceder a Matomo
```
Navegador: http://localhost:8081
```

### Paso 5: Configurar Matomo
1. Sistema → Verificar que la información coincide con el Dockerfile
2. Base de datos → Verificar credenciales (mariadb-service:3306)
3. Crear cuenta de administrador
4. Finalizar configuración

### Paso 6: Destruir Infraestructura (con datos persistentes)
```bash
terraform destroy
kind delete cluster --name cluster-ej2

# Los datos persisten porque están en volúmenes locales de kind
# Ubicación: ~/.kind/clusters/cluster-ej2/
```

## CI/CD con GitHub Actions

### Configuración Requerida

1. **Agregar Secretos en GitHub** (Settings → Secrets → New repository secret):
   - `DOCKER_HUB_USERNAME` - Tu usuario de Docker Hub
   - `DOCKER_HUB_PASSWORD` - Token de Docker Hub

2. **El flujo se activa cuando**:
   - Haces push a la rama `master`
   - Se modifica `ejercicio-2/Dockerfile`
   - Se modifica `ejercicio-2/zzz-matomo.ini`
   - Se modifica el workflow mismo

3. **Resultado**:
   - Imagen construida con Buildx (cache eficiente)
   - Publicada en Docker Hub con tags:
     - `tu-usuario/matomo-custom:latest`
     - `tu-usuario/matomo-custom:20240105-150230`

### Actualizar terraform.tfvars

Cambiar la línea:
```hcl
matomo_image = "tu-usuario/matomo-custom:latest"
```

## Persistencia de Datos

### Cómo Funciona

1. **PersistentVolumeClaim** solicita almacenamiento
2. kind crea automáticamente volúmenes en la máquina host
3. Los pods montan estos volúmenes en sus directorios de trabajo
4. Cuando se destruye terraform, los volúmenes persisten

### Ubicación de Datos

```
~/.kind/clusters/cluster-ej2/
├── mariadb/ → Datos de MySQL
└── matomo/  → Archivos de Matomo
```

### Recuperar Datos

```bash
# Los datos persisten incluso después de:
terraform destroy
kind delete cluster --name cluster-ej2

# Para recrear la infraestructura con los datos existentes:
kind create cluster --name cluster-ej2 --config cluster-config.yaml
terraform apply
```

## Variables de Entorno

### MariaDB
```yaml
MYSQL_ROOT_PASSWORD: securepassword
MYSQL_DATABASE: matomodb
MYSQL_USER: matomo
MYSQL_PASSWORD: securepassword
```

### Matomo
```yaml
MATOMO_DATABASE_HOST: mariadb-service
MATOMO_DATABASE_USERNAME: matomo
MATOMO_DATABASE_PASSWORD: securepassword
MATOMO_DATABASE_DBNAME: matomodb
```

## Demostración Completada - Ejercicio 2

### ✅ Pasos Verificados

#### 1. Configuración del Sistema (Paso 2)
- ✓ **PHP 8.4.15** - Cumple requisito >= 7.2.5
- ✓ **Memoria PHP: 512M** - Configurada en Dockerfile
- ✓ **upload_max_filesize: 512M** - Configurada en zzz-matomo.ini
- ✓ **post_max_size: 512M** - Configurada en zzz-matomo.ini
- ✓ **Apache 2.4.65** funcionando en puerto 81

#### 2. Verificación de Base de Datos (Pasos 3-4)
- ✓ **Host**: mariadb-service (correcto)
- ✓ **Usuario**: matomo (correcto)
- ✓ **Base de datos**: matomodb (creada)
- ✓ **MariaDB 10.5.29** corriendo y accesible
- ✓ **32 tablas de Matomo** creadas correctamente
- ✓ **UTF8mb4 charset** configurado

#### 3. Configuración Completada
- ✓ Sitio "prueba" creado en Matomo
- ✓ Usuario administrador configurado
- ✓ Dashboard accesible en http://localhost:8081
- ✓ Sistema funcionando correctamente

#### 4. Persistencia de Datos (Paso 5) - DEMOSTRACIÓN COMPLETADA
**Proceso:**
```
1. terraform destroy -auto-approve
   → Eliminados: 2 Deployments, 2 Services, 2 PVCs
   
2. Verificación:
   → kubectl get pvc -A  (No resources found) ✓
   → kubectl get pods    (Solo pods de sistema) ✓
   
3. terraform apply -auto-approve
   → Recreados: 2 Deployments, 2 Services, 2 PVCs
   
4. Resultados:
   → Pods corriendo nuevamente ✓
   → PVCs montados correctamente ✓
   → MariaDB accesible con datos previos ✓
   → Matomo cargado sin necesidad de reconfiguración ✓
```

**Evidencia de Persistencia:**
- Los archivos de Matomo permanecen en `/var/www/html/config/`
- La configuración de base de datos está intacta
- Las tablas de Matomo están disponibles inmediatamente
- Los sitios y configuraciones creadas persisten

### Pods Activos Post-Recreación
```
NAME                      READY   STATUS    RESTARTS   AGE
mariadb-ff764487f-krhjz   1/1     Running   0          ~1min
matomo-848b8dfc4c-lldv6   1/1     Running   0          ~1min
```

### Volúmenes Persistentes
```
NAME          STATUS   CAPACITY   ACCESS MODES
mariadb-pvc   Bound    5Gi        RWO
matomo-pvc    Bound    10Gi       RWO
```

## Troubleshooting

### Los pods no inician
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### No hay conectividad MariaDB-Matomo
```bash
# Verificar DNS del cluster
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup mariadb-service

# Probar conexión
kubectl exec -it <matomo-pod> -- mysql -h mariadb-service -u matomo -p
```

### Puertos en conflicto
```bash
# Cambiar puerto en cluster-config.yaml
hostPort: 8081 → 8082
```

### GitHub Actions falla
- Verificar secretos están configurados
- Comprobar que rama es `master`
- Ver logs del workflow en GitHub

## Resumen de Tecnologías

| Componente | Versión | Descripción |
|-----------|---------|------------|
| kind | Latest | Clúster Kubernetes local |
| Terraform | 1.x | IaC para Kubernetes |
| Matomo | Latest | Servidor de análisis |
| MariaDB | 10.5 | Base de datos relacional |
| Docker | Latest | Containerización |
| GitHub Actions | Latest | CI/CD |

## Notas Importantes

1. **Seguridad**: Las contraseñas en `terraform.tfvars` deben ser secretas en producción
2. **Backups**: Los datos en `/var/lib/mysql` son persistentes localmente
3. **Escalabilidad**: Para más de 1 réplica, se requiere almacenamiento compartido
4. **Permisos**: Se requieren permisos de escritura en `~/.kind/`
