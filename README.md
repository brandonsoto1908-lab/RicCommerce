# RicCommerce - Sistema de Gestión de Productos de Limpieza

Sistema web completo para la gestión integral de productos de limpieza, desarrollado con Next.js, Supabase y desplegado en Vercel.

## 🚀 Características Principales

### 1. **Módulo de Compras**
- Registro de productos adquiridos con múltiples marcas
- Captura de nombre, marca, cantidad (gramos/litros) y precio en USD
- Compras con múltiples productos
- Registro automático de entradas al inventario
- Editar, agregar y eliminar productos
- Crear nuevos productos desde el módulo de compras

### 2. **Módulo de Ventas**
- Gestión de presentaciones y envases (1 litro, medio litro, etc.)
- Precio de venta en colones por presentación
- **Cálculo automático en tiempo real** del margen de ganancia:
  - Porcentaje de margen
  - Monto en colones
  - Monto en dólares
- **Gráfico interactivo** mostrando margen mientras se edita el precio
- Registro de salidas automáticas del inventario
- Conversión de moneda USD ↔ CRC con API gratuita

### 3. **Módulo de Gastos**
- Registro de gastos únicos y utilitarios (agua, luz, internet, etc.)
- Periodicidad para gastos utilitarios (semanal, quincenal, mensual, anual)
- Distribución proporcional de gastos utilitarios en el costo de productos
- Cálculo de margen real considerando:
  - Costo del producto
  - Costo del envase
  - Gastos utilitarios distribuidos

### 4. **Módulo de Inventario**
- Seguimiento en tiempo real del stock
- Registro de entradas (compras, ajustes) y salidas (ventas, bajas)
- Editar/agregar/remover productos
- Alertas de stock bajo
- Visualización de valor total del inventario
- Estados de stock: Bajo, Medio, Óptimo

### 5. **Módulo de Reportes**
- Informes descargables en PDF de:
  - Compras
  - Ventas
  - Gastos
  - Márgenes de ganancia
  - Inventario actual
- Gráficos en vivo por producto
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

### Opción 1: Desde GitHub (Recomendado)

1. Sube tu código a GitHub
2. Ve a [Vercel](https://vercel.com)
3. Clic en "New Project"
4. Importa tu repositorio
5. Agrega las variables de entorno:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `NEXT_PUBLIC_EXCHANGE_API_URL`
6. Clic en "Deploy"

### Opción 2: Desde CLI

```bash
npm install -g vercel
vercel login
vercel
```

## 📘 Guía de Uso

### Primer Inicio

1. **Registrar Usuario**:
   - Accede a la página de login
   - Clic en "Registrarse"
   - Completa nombre, email y contraseña
   - Verifica tu email (si está habilitada la verificación)

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
