# RicCommerce - Sistema de Gestión de Productos de Limpieza

Sistema web completo para la gestión integral de productos de limpieza, desarrollado con Next.js 14, TypeScript, Supabase y Tailwind CSS.

## ⚠️ MIGRACIÓN MULTI-TENANT REQUERIDA

**IMPORTANTE:** Si estás actualizando desde una versión anterior, **DEBES ejecutar la migración** para convertir el sistema en multi-tenant.

📖 **Lee las instrucciones completas:** `INSTRUCCIONES-MIGRACION.md`

**Pasos rápidos:**
1. Abre Supabase SQL Editor
2. Ejecuta: `MASTER-migration-multitenant.sql`
3. Verifica con: `verify-migration.sql`

**¿Por qué migrar?** La versión anterior compartía datos entre usuarios. Esta migración asegura que cada usuario tenga sus propios productos, inventario y presentaciones completamente aislados.

---

## 🚀 Características Principales

### 1. **Módulo de Compras**
- Registro de productos con cálculo automático de precio unitario
- Ingresa total y cantidad → el sistema calcula precio por unidad automáticamente
- Soporte para múltiples unidades de medida (litros, mililitros, gramos, kilogramos)
- Compras con múltiples productos
- Registro automático de entradas al inventario con costo promedio ponderado
- Historial completo de compras
- **✅ Multi-tenant:** Cada usuario ve solo sus productos

### 2. **Módulo de Ventas y Presentaciones**
- Gestión de presentaciones y envases (1 litro, 500ml, 250ml, etc.)
- **Conversión automática de unidades** (mililitros ↔ litros, gramos ↔ kilogramos)
- **Calculadora de precio con margen objetivo**:
  - Define tu margen deseado (ej: 30%)
  - Sistema calcula precio automáticamente
  - Incluye costo de producto + envase + gastos utilitarios (opcional)
- **Cálculo de gastos utilitarios prorrateados**:
  - Distribuye luz, agua, alquiler entre litros de inventario
  - Checkbox para incluir/excluir en el precio
- **Cálculo en tiempo real del margen de ganancia**:
  - Porcentaje de margen
  - Monto en colones y dólares
- **Columna de Margen % en tabla de presentaciones**
- Registro de salidas automáticas del inventario
- Conversión de moneda USD ↔ CRC con API en tiempo real
- **✅ Multi-tenant:** Cada usuario ve solo sus presentaciones

### 3. **Módulo de Gastos**
- Registro de gastos únicos y utilitarios (agua, luz, internet, alquiler, etc.)
- Periodicidad para gastos utilitarios (semanal, quincenal, mensual, anual)
- **Distribución inteligente de gastos utilitarios**:
  - Calcula costo por litro de overhead
  - Se prorratea automáticamente en presentaciones
- Seguimiento de gastos por categoría y tipo
- **✅ Multi-tenant:** Gastos aislados por usuario

### 4. **Módulo de Inventario**
- Seguimiento en tiempo real del stock con costo promedio ponderado
- Registro automático de movimientos (entradas y salidas)
- Soporte para múltiples unidades de medida
- Visualización de valor total del inventario
- Estados de stock: Bajo, Medio, Óptimo
- Alertas de productos sin costo registrado
- **✅ Multi-tenant:** Inventario independiente por usuario

### 5. **Módulo de Reportes**
- Informes descargables en **PDF** de:
  - Ventas por período
  - Compras históricas
  - Gastos por categoría
  - Inventario actual con valoración
- Filtros por fecha y tipo de reporte
- Formato profesional con tablas y totales
- Filtros por producto, fechas y presentaciones
- Exportación a PDF con diseño profesional

### 6. **Características Adicionales**
- ✅ Sistema multiusuario con autenticación (Supabase Auth)
- ✅ Permisos para editar, agregar y remover
- ✅ Interfaz responsive (móvil y escritorio)
- ✅ Conversión automática de moneda con API
- ✅ Historial de precios y márgenes
- ✅ Dashboard con estadísticas en tiempo real

## 🛠️ Tecnologías Utilizadas

- **Frontend**: Next.js 14, React, TypeScript
- **Estilos**: Tailwind CSS
- **Base de Datos**: Supabase (PostgreSQL)
- **Autenticación**: Supabase Auth
- **Gráficos**: Recharts
- **PDF**: jsPDF + jsPDF-autotable
- **Iconos**: Lucide React
- **Despliegue**: Vercel
- **API de Cambio**: ExchangeRate-API

## 📦 Instalación

### Requisitos Previos
- Node.js 18+ 
- npm o yarn
- Cuenta de Supabase
- Cuenta de Vercel (para despliegue)

### Paso 1: Clonar el Repositorio
```bash
git clone https://github.com/brandonsoto1908-lab/RicCommerce.git
cd RicCommerce
```

### Paso 2: Instalar Dependencias
```bash
npm install
```

### Paso 3: Configurar Variables de Entorno
Crea un archivo `.env.local` en la raíz del proyecto:

```env
NEXT_PUBLIC_SUPABASE_URL=https://pbbqkjlfnewplmdpommo.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBiYnFramxmbmV3cGxtZHBvbW1vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE5NDEwODgsImV4cCI6MjA3NzUxNzA4OH0.dqqivDu33-EhoLEJM071JhIsLzYSOPogQ2k5bsrpCy0
NEXT_PUBLIC_EXCHANGE_API_URL=https://api.exchangerate-api.com/v4/latest/USD
```

### Paso 4: Configurar Base de Datos en Supabase

1. Accede a tu proyecto en [Supabase](https://supabase.com)
2. Ve a **SQL Editor**
3. Copia y ejecuta el contenido del archivo `supabase-schema.sql`
4. Esto creará todas las tablas, triggers, funciones y políticas de seguridad

### Paso 5: Ejecutar en Desarrollo
```bash
npm run dev
```

Abre [http://localhost:3000](http://localhost:3000) en tu navegador.

## 🚢 Despliegue en Vercel

### Preparación Previa

Antes de desplegar, asegúrate de:

1. **Tener tu base de datos Supabase configurada**:
   - Ejecuta el archivo `supabase-schema.sql` en tu proyecto Supabase
   - Verifica que todas las tablas, triggers y políticas RLS estén creadas

2. **Variables de entorno necesarias**:
   - `NEXT_PUBLIC_SUPABASE_URL` - URL de tu proyecto Supabase
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` - Clave anónima (anon/public key)
   - `NEXT_PUBLIC_EXCHANGE_API_URL` - API de conversión de moneda (opcional)

### Opción 1: Despliegue desde GitHub (Recomendado)

1. **Sube tu código a GitHub**:
   ```bash
   git add .
   git commit -m "Preparado para despliegue"
   git push origin main
   ```

2. **Conecta con Vercel**:
   - Ve a [vercel.com](https://vercel.com) y crea una cuenta (puedes usar GitHub)
   - Clic en **"Add New Project"**
   - Selecciona **"Import Git Repository"**
   - Conecta tu repositorio de GitHub
   - Selecciona el proyecto **RicCommerce**

3. **Configura las variables de entorno**:
   - En la página de configuración, ve a **"Environment Variables"**
   - Agrega las siguientes variables:
     ```
     NEXT_PUBLIC_SUPABASE_URL = tu_url_de_supabase
     NEXT_PUBLIC_SUPABASE_ANON_KEY = tu_clave_anonima
     NEXT_PUBLIC_EXCHANGE_API_URL = https://api.exchangerate-api.com/v4/latest/USD
     ```
   - **Importante**: Asegúrate de marcar las variables como disponibles en **Production**, **Preview** y **Development**

4. **Despliega**:
   - Clic en **"Deploy"**
   - Vercel automáticamente:
     - Instalará dependencias (`npm install`)
     - Ejecutará el build (`npm run build`)
     - Desplegará la aplicación
   - Proceso toma 2-3 minutos

5. **Verifica el despliegue**:
   - Una vez completado, obtendrás una URL tipo: `https://riccommerce.vercel.app`
   - Abre la URL y verifica que todo funcione correctamente

### Opción 2: Despliegue desde CLI de Vercel

1. **Instala Vercel CLI**:
   ```bash
   npm install -g vercel
   ```

2. **Login en Vercel**:
   ```bash
   vercel login
   ```

3. **Despliega el proyecto**:
   ```bash
   vercel
   ```

4. **Configura variables de entorno** (si no están en `.env.production`):
   ```bash
   vercel env add NEXT_PUBLIC_SUPABASE_URL
   vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY
   vercel env add NEXT_PUBLIC_EXCHANGE_API_URL
   ```

5. **Despliega a producción**:
   ```bash
   vercel --prod
   ```

### Post-Despliegue

1. **Configura dominio personalizado** (opcional):
   - En el dashboard de Vercel, ve a **Settings** > **Domains**
   - Agrega tu dominio personalizado
   - Sigue las instrucciones para configurar DNS

2. **Actualiza las URLs permitidas en Supabase**:
   - Ve a tu proyecto en Supabase
   - **Authentication** > **URL Configuration**
   - Agrega tu URL de Vercel a:
     - **Site URL**: `https://tu-proyecto.vercel.app`
     - **Redirect URLs**: `https://tu-proyecto.vercel.app/**`

3. **Prueba todas las funcionalidades**:
   - Registro e inicio de sesión
   - Crear productos y compras
   - Crear presentaciones
   - Registrar ventas
   - Verificar cálculos de márgenes
   - Generar reportes PDF

### Actualizaciones Futuras

Cada vez que hagas `git push` a tu rama principal, Vercel automáticamente:
- Detectará los cambios
- Ejecutará un nuevo build
- Desplegará la nueva versión
- Mantendrá la URL anterior activa hasta que el nuevo deploy esté listo

### Troubleshooting

**Error: "Module not found"**
- Verifica que todas las dependencias estén en `package.json`
- Ejecuta `npm install` localmente y vuelve a hacer push

**Error: "Environment variable not found"**
- Verifica que agregaste todas las variables en Vercel
- Recarga el proyecto en Vercel después de agregar variables

**Error de Supabase: "Invalid API key"**
- Verifica que copiaste correctamente la clave anónima
- Asegúrate de usar `NEXT_PUBLIC_` como prefijo

**Error: "Failed to compile"**
- Revisa los errores en el log de build de Vercel
- Ejecuta `npm run build` localmente para detectar errores

## 📘 Guía de Uso

### Primer Inicio

1. **Registrar Usuario**:
   - Accede a la página de login
   - Clic en "Registrarse"
   - Completa nombre, email y contraseña
   - Verifica tu email (si está habilitada la verificación en Supabase)

2. **Configurar Sistema**:
   - Ve a **Configuración**
   - Ajusta la tasa de cambio (automática o manual)
   - Define el margen mínimo de alerta

3. **Crear Productos**:
   - Ve a **Compras** → **Nuevo Producto**
   - Ingresa nombre, marca, unidad de medida
   - Guarda el producto

### Flujo de Trabajo Normal

#### Registrar una Compra
1. Ve a **Compras** → **Nueva Compra**
2. Selecciona la fecha
3. Agrega productos:
   - Selecciona producto
   - Ingresa cantidad
   - Ingresa precio unitario en USD
4. Agrega notas (opcional)
5. Guarda la compra
6. ✅ El inventario se actualiza automáticamente

#### Crear Presentación para Venta
1. Ve a **Ventas** → **Nueva Presentación**
2. Selecciona el producto base
3. Define la presentación (ej: "1 Litro", "500ml")
4. Ingresa cantidad y unidad
5. Agrega costo del envase (opcional)
6. Define el precio de venta en colones
7. **Observa el margen en tiempo real** con el gráfico
8. Ajusta el precio hasta obtener el margen deseado
9. Guarda la presentación

#### Registrar una Venta
1. Ve a **Ventas** → **Nueva Venta**
2. Selecciona la fecha
3. Agrega presentaciones:
   - Selecciona presentación
   - Ingresa cantidad
   - Verifica el margen mostrado
4. Agrega notas (opcional)
5. Guarda la venta
6. ✅ El inventario se descuenta automáticamente

#### Registrar Gastos
1. Ve a **Gastos** → **Nuevo Gasto**
2. Selecciona tipo:
   - **Único**: Gastos puntuales
   - **Utilitario**: Gastos recurrentes (luz, agua, etc.)
3. Ingresa categoría, descripción y monto
4. Si es utilitario, define periodicidad
5. Guarda el gasto

#### Consultar Inventario
1. Ve a **Inventario**
2. Visualiza stock disponible
3. Usa el buscador para filtrar
4. Observa alertas de stock bajo (rojas)

#### Generar Reportes
1. Ve a **Reportes**
2. Selecciona tipo de reporte
3. Define rango de fechas
4. Clic en "Filtrar" para visualizar
5. Clic en el ícono de descarga para exportar a PDF

### Gestión de Usuarios y Permisos

**Roles Disponibles**:
- **Admin**: Acceso total, puede editar y eliminar
- **Usuario**: Solo puede ver y agregar (configurado en tabla `perfiles_usuario`)

Para cambiar permisos, actualiza la tabla `perfiles_usuario` directamente en Supabase.

## 🔐 Seguridad

- ✅ Autenticación con Supabase Auth
- ✅ Row Level Security (RLS) en todas las tablas
- ✅ Políticas de acceso por usuario
- ✅ Variables de entorno para credenciales
- ✅ HTTPS en producción (Vercel)

## 🗃️ Estructura de la Base de Datos

### Tablas Principales
- `productos`: Catálogo de productos
- `presentaciones`: Presentaciones de venta
- `compras` y `compras_detalle`: Registro de compras
- `ventas` y `ventas_detalle`: Registro de ventas
- `gastos`: Gastos operativos
- `inventario`: Stock actual
- `movimientos_inventario`: Historial de movimientos
- `perfiles_usuario`: Información de usuarios
- `configuracion`: Ajustes del sistema
- `historial_precios`: Histórico de cambios de precio

### Triggers Automáticos
- Actualización de inventario en compras
- Descuento de inventario en ventas
- Actualización de `updated_at` en todas las tablas

## 📊 Cálculo de Márgenes

El sistema calcula el margen considerando:

```
Costo Total = Costo Producto + Costo Envase + Gastos Utilitarios Prorrateados

Margen $ = (Precio Venta CRC / Tasa Cambio) - Costo Total

Margen % = (Margen $ / Costo Total) × 100
```

### Niveles de Alerta
- 🔴 Rojo: Margen < 15% (configurable)
- 🟡 Amarillo: Margen < 30%
- 🟢 Verde: Margen ≥ 30%

## 🐛 Solución de Problemas

### Error de Conexión a Supabase
- Verifica que las variables de entorno estén correctas
- Confirma que el proyecto de Supabase esté activo
- Revisa las políticas de RLS en Supabase

### La tasa de cambio no se actualiza
- Verifica conexión a internet
- La API tiene un límite de requests
- Usa la tasa manual como respaldo en Configuración

### Los triggers no funcionan
- Ejecuta nuevamente el archivo `supabase-schema.sql`
- Verifica que las funciones estén creadas correctamente
- Revisa logs en Supabase Dashboard

## 🤝 Contribución

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver archivo `LICENSE` para más detalles.

## 👨‍💻 Autor

**Brandon Soto**
- GitHub: [@brandonsoto1908-lab](https://github.com/brandonsoto1908-lab)
- Universidad Fidélitas

## 📞 Soporte

Para preguntas o soporte, abre un issue en GitHub o contacta al administrador del sistema.

---

## 🎯 Roadmap Futuro

- [ ] Modo offline con sincronización
- [ ] Aplicación móvil nativa
- [ ] Integración con escáneres de código de barras
- [ ] Notificaciones push para stock bajo
- [ ] Dashboard de analítica avanzada
- [ ] Exportación a Excel
- [ ] Multi-idioma (i18n)
- [ ] Tema oscuro

---

**Versión**: 1.0.0  
**Última actualización**: Octubre 2025

¡Gracias por usar RicCommerce! 🧼✨
