# 📖 Manual de Usuario - RicCommerce

**Sistema de Gestión Comercial**  
Versión 1.0.0 | Noviembre 2025

---

## 📑 Tabla de Contenidos

1. [Introducción](#introducción)
2. [Registro e Inicio de Sesión](#registro-e-inicio-de-sesión)
3. [Panel Principal (Dashboard)](#panel-principal-dashboard)
4. [Módulo de Compras](#módulo-de-compras)
5. [Módulo de Inventario](#módulo-de-inventario)
6. [Módulo de Ventas](#módulo-de-ventas)
7. [Módulo de Gastos](#módulo-de-gastos)
8. [Módulo de Reportes](#módulo-de-reportes)
9. [Configuración](#configuración)
10. [Preguntas Frecuentes](#preguntas-frecuentes)

---

## 🎯 Introducción

**RicCommerce** es un sistema completo de gestión comercial diseñado para pequeñas y medianas empresas. Permite:

- ✅ Gestionar compras con conversión de moneda automática (USD a CRC)
- ✅ Controlar inventario en tiempo real
- ✅ Registrar ventas y calcular márgenes de ganancia
- ✅ Administrar gastos operativos y utilitarios
- ✅ Generar reportes detallados en PDF
- ✅ Calcular precios recomendados basados en costos reales

### 💡 Características Principales

1. **Conversión de Unidades**: Compra en litros y vende en mililitros automáticamente
2. **Prorrateo de Gastos**: Distribuye gastos utilitarios entre productos
3. **Calculadora de Precios**: Ingresa el margen deseado y obtén el precio óptimo
4. **Reportes Profesionales**: PDFs con gráficos y análisis detallados
5. **Tipo de Cambio Automático**: Actualización diaria de USD a CRC

---

## 🔐 Registro e Inicio de Sesión

### Paso 1: Acceder al Sistema

1. Abre tu navegador web (Chrome, Firefox, Edge, Safari)
2. Ingresa a la URL: `https://tu-dominio.vercel.app`
3. Verás la pantalla de inicio de sesión

### Paso 2: Crear una Cuenta Nueva

Si es tu **primera vez** usando el sistema:

1. **Completa el formulario de registro:**
   - **Email**: Tu correo electrónico (ejemplo: `usuario@empresa.com`)
   - **Contraseña**: Mínimo 6 caracteres (usa letras, números y símbolos)
   - **Confirmar Contraseña**: Repite la contraseña anterior

2. **Click en "Registrarse"**
   - El sistema enviará un email de confirmación a tu correo
   - Revisa tu bandeja de entrada (y spam/correo no deseado)

3. **Confirmar tu correo:**
   - Abre el email de Supabase
   - Click en "Confirm your email"
   - Serás redirigido al sistema automáticamente

4. **¡Listo!** Ya puedes iniciar sesión

### Paso 3: Iniciar Sesión

Si **ya tienes una cuenta**:

1. En la pantalla de login, ingresa:
   - Tu **email**
   - Tu **contraseña**

2. Click en **"Iniciar Sesión"**

3. Serás redirigido al **Dashboard** principal

### 🔒 Seguridad

- ✅ Todas las contraseñas están encriptadas
- ✅ Sesiones seguras con tokens JWT
- ✅ Cierre de sesión automático después de inactividad
- ✅ Cada usuario solo ve sus propios datos

### ❌ ¿Olvidaste tu Contraseña?

1. Click en "¿Olvidaste tu contraseña?"
2. Ingresa tu email
3. Recibirás un enlace para resetear
4. Crea una nueva contraseña
5. Inicia sesión con la nueva contraseña

---

## 🏠 Panel Principal (Dashboard)

Al iniciar sesión, verás el **Dashboard** con 6 módulos principales:

### 📊 Tarjetas de Resumen

En la parte superior verás 4 tarjetas con:

1. **Total Ventas**
   - Suma de todas tus ventas del mes
   - En colones (₡) y dólares (USD)

2. **Total Compras**
   - Total invertido en inventario
   - Conversión automática USD → CRC

3. **Total Gastos**
   - Gastos operativos del mes
   - Incluye gastos utilitarios

4. **Inventario Actual**
   - Valor total del inventario
   - Basado en costos promedio

### 🧭 Menú de Navegación

En el panel lateral izquierdo encontrarás:

- 🛒 **Compras** - Registrar nuevas compras
- 📦 **Inventario** - Ver productos disponibles
- 💰 **Ventas** - Registrar ventas y crear presentaciones
- 💳 **Gastos** - Administrar gastos operativos
- 📈 **Reportes** - Generar PDFs con análisis
- ⚙️ **Configuración** - Ajustes del sistema

### 🚪 Cerrar Sesión

En la esquina superior derecha:
- Click en tu **email**
- Selecciona **"Cerrar Sesión"**

---

## 🛒 Módulo de Compras

Este módulo te permite registrar tus compras a proveedores y actualizar el inventario automáticamente.

### ✨ Funcionalidades Principales

1. **Cálculo automático de precio unitario**
2. **Conversión de moneda USD → CRC**
3. **Actualización instantánea de inventario**
4. **Historial completo de compras**

### 📝 Cómo Registrar una Compra

#### Paso 1: Acceder al Módulo

1. En el menú lateral, click en **"Compras"**
2. Verás dos pestañas:
   - **Registrar Compra** (aquí ingresarás nuevas compras)
   - **Historial** (verás compras anteriores)

#### Paso 2: Seleccionar Producto

1. En el formulario, busca **"Producto"**
2. Click en el desplegable
3. Opciones:
   - Si el producto **YA EXISTE**: Selecciónalo de la lista
   - Si es **NUEVO**: Verás un mensaje "No hay productos disponibles"

#### Paso 3: Crear Producto Nuevo (si es necesario)

Si el producto no existe:

1. Click en **"+ Agregar Nuevo Producto"**
2. Aparecerá un formulario modal con:

   **Información Básica:**
   - **Nombre del Producto**: Ejemplo: "Liquid Tide Softener"
   - **Descripción**: Ejemplo: "Suavizante de telas aroma floral"
   - **Unidad de Medida**: Selecciona una opción:
     - `litros` - Para líquidos
     - `mililitros` - Para líquidos en presentaciones pequeñas
     - `kilogramos` - Para sólidos
     - `gramos` - Para sólidos en presentaciones pequeñas
     - `unidades` - Para productos contables

3. Click en **"Guardar Producto"**
4. El producto aparecerá automáticamente seleccionado en el formulario

#### Paso 4: Completar Información de Compra

Ahora completa estos campos:

1. **Proveedor**
   - Nombre de tu proveedor
   - Ejemplo: "Distribuidora Nacional S.A."

2. **Cantidad**
   - Cantidad que compraste
   - Ejemplo: Si compraste 1000 litros, ingresa: `1000`
   - Usa la unidad de medida del producto

3. **Total de la Compra (USD)**
   - Monto total que pagaste en **dólares**
   - Ejemplo: Si pagaste $570, ingresa: `570`
   - **⚠️ IMPORTANTE**: Solo dólares, el sistema convierte automáticamente a colones

4. **Costo del Envase (CRC) - OPCIONAL**
   - Si compras envases por separado
   - Ejemplo: Si el envase cuesta ₡500, ingresa: `500`
   - En **colones costarricenses**

#### Paso 5: Verificar Cálculos Automáticos

El sistema calcula automáticamente:

- **Precio Unitario USD**: Total ÷ Cantidad
  - Ejemplo: $570 ÷ 1000L = **$0.57 por litro**

- **Total en CRC**: Usa el tipo de cambio del día
  - Ejemplo: $570 × ₡525 = **₡299,250**

- **Costo Promedio**: Se actualiza en el inventario
  - Combina costo anterior con costo nuevo

#### Paso 6: Guardar la Compra

1. Revisa que todos los datos sean correctos
2. Click en **"Registrar Compra"**
3. Verás un mensaje: ✅ **"Compra registrada exitosamente"**
4. El inventario se actualiza automáticamente

### 📊 Ver Historial de Compras

1. Click en la pestaña **"Historial"**
2. Verás una tabla con todas tus compras:
   - Fecha de compra
   - Producto
   - Proveedor
   - Cantidad
   - Total USD y CRC
   - Costo del envase

3. **Filtros disponibles:**
   - Por fecha
   - Por producto
   - Por proveedor

### 💡 Consejos Prácticos

✅ **Registra compras inmediatamente** para mantener el inventario actualizado  
✅ **Guarda las facturas** físicas para comparar con el sistema  
✅ **Verifica el tipo de cambio** antes de registrar (se muestra en el dashboard)  
✅ **Revisa el precio unitario** calculado para detectar errores de digitación

### ⚠️ Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| "Producto no encontrado" | No has creado el producto | Click en "+ Agregar Nuevo Producto" |
| "Total debe ser mayor a 0" | Ingresaste 0 o negativo | Revisa el monto total |
| "Cantidad inválida" | Ingresaste texto en lugar de número | Usa solo números |

---

## 📦 Módulo de Inventario

Visualiza y controla todos tus productos en tiempo real.

### 🎯 ¿Qué Puedes Ver?

1. **Lista completa de productos**
2. **Cantidad disponible** de cada uno
3. **Costo promedio** en USD
4. **Valor total** del inventario
5. **Unidad de medida** (litros, gramos, unidades, etc.)

### 📊 Cómo Ver el Inventario

#### Paso 1: Acceder al Módulo

1. En el menú lateral, click en **"Inventario"**
2. Verás una tabla con todos tus productos

#### Paso 2: Entender la Tabla

La tabla muestra las siguientes columnas:

| Columna | Descripción | Ejemplo |
|---------|-------------|---------|
| **Producto** | Nombre y descripción | "Liquid Tide Softener - Tide" |
| **Cantidad Disponible** | Stock actual | "1000 litros" |
| **Costo Promedio** | Costo por unidad en USD | "$0.57" |
| **Valor Total** | Cantidad × Costo promedio | "$570.00" |

#### Paso 3: Interpretación de Datos

**Costo Promedio:**
- Se calcula automáticamente con cada compra
- Fórmula: `(Stock anterior × Costo anterior + Nueva compra × Costo nuevo) ÷ Total`
- Ejemplo:
  ```
  Stock anterior: 500L × $0.55 = $275
  Nueva compra: 1000L × $0.57 = $570
  ────────────────────────────────────
  Total: 1500L × $0.567 promedio
  ```

**Cantidad Disponible:**
- Se actualiza automáticamente con:
  - ✅ **Compras** (suma al inventario)
  - ✅ **Ventas** (resta del inventario)

**Valor Total del Inventario:**
- En la parte superior verás el **valor total** de tu inventario
- Es la suma de todos los productos: Σ(Cantidad × Costo)

### 🔍 Filtros y Búsqueda

1. **Buscar por nombre:**
   - Usa el campo de búsqueda en la parte superior
   - Escribe el nombre del producto
   - Ejemplo: "Tide" mostrará todos los productos Tide

2. **Filtrar por disponibilidad:**
   - **Stock bajo**: Productos con menos del 20% de stock
   - **Sin stock**: Productos con 0 unidades

### 📈 Estadísticas del Inventario

En la parte superior verás:

- **Total de Productos**: Número de SKUs diferentes
- **Valor Total USD**: Inversión total en inventario
- **Valor Total CRC**: Conversión a colones

### ⚠️ Alertas de Stock

El sistema te avisará cuando:

- 🟡 **Stock bajo**: Menos de 100 unidades
- 🔴 **Sin stock**: 0 unidades disponibles

### 💡 Consejos Prácticos

✅ **Revisa el inventario diariamente** para detectar discrepancias  
✅ **Compara con tu inventario físico** cada semana  
✅ **Atención a productos sin stock** para evitar perder ventas  
✅ **Analiza el costo promedio** para decisiones de precio

---

## 💰 Módulo de Ventas

Este es el módulo más completo. Aquí creas presentaciones de productos y registras ventas.

### 🎯 Conceptos Importantes

**Producto vs Presentación:**

- **Producto**: Lo que compras a granel
  - Ejemplo: 1000 litros de suavizante

- **Presentación**: Lo que vendes al cliente
  - Ejemplo: Botella de 100 mililitros

**¿Por qué dos conceptos?**
- Compras por mayoreo (litros, kilogramos)
- Vendes al detalle (mililitros, gramos)
- El sistema convierte automáticamente

### ✨ Funcionalidades Principales

1. **Crear presentaciones** con conversión automática de unidades
2. **Calculadora de precios** basada en margen deseado
3. **Prorrateo de gastos utilitarios** para precios reales
4. **Registro de ventas** con actualización de inventario
5. **Vista previa de márgenes** antes de confirmar

### 📝 Parte 1: Crear Presentaciones

#### Paso 1: Acceder a Presentaciones

1. En el menú lateral, click en **"Ventas"**
2. Verás tres pestañas:
   - **Presentaciones** (aquí creas las presentaciones)
   - **Registro de Ventas** (aquí registras ventas)
   - **Historial** (verás el historial de ventas)

3. Asegúrate de estar en **"Presentaciones"**

#### Paso 2: Crear Nueva Presentación

1. Click en **"+ Nueva Presentación"**
2. Aparecerá un formulario completo

#### Paso 3: Completar Formulario

**3.1 Información Básica:**

- **Nombre de Presentación**
  - Ejemplo: "Botella 100 ML"
  - Ejemplo: "Sachet 50 gramos"
  - Ejemplo: "Galón 1 litro"

- **Descripción** (opcional)
  - Ejemplo: "Presentación retail para consumidor final"

**3.2 Seleccionar Producto Base:**

- Click en **"Producto"**
- Selecciona el producto que compraste a granel
- Ejemplo: "Liquid Tide Softener - Tide (1000 litros @ $0.57/L)"

**3.3 Cantidad de Presentación:**

- **Cantidad**: Cuánto contendrá cada unidad
- **Unidad de Medida**: Selecciona la unidad de venta

**Ejemplo de Conversión:**
```
Producto base: 1000 LITROS a $0.57/litro
Presentación: 100 MILILITROS

El sistema convierte automáticamente:
100 ML = 0.1 L
Costo del producto: 0.1L × $0.57 = $0.057
```

**Unidades Soportadas:**
- Líquidos: `litros` ↔ `mililitros`
- Sólidos: `kilogramos` ↔ `gramos`
- Contables: `unidades`

**3.4 Costos Adicionales:**

- **Costo del Envase (CRC)**
  - Costo de la botella, sachet, empaque
  - Ejemplo: Botella plástica = ₡500
  - En **colones costarricenses**

**3.5 Incluir Gastos Utilitarios (IMPORTANTE):**

Esta es una función avanzada que distribuye tus gastos operativos.

1. **Checkbox "Incluir gastos utilitarios"**
   - Marca esta casilla si quieres precios más reales

2. **¿Qué hace?**
   - El sistema busca tus gastos marcados como "utilitarios"
   - Ejemplos: luz, agua, alquiler, internet
   - Calcula el costo por litro de overhead

3. **Ejemplo de cálculo:**
   ```
   Gastos utilitarios del mes: ₡135,000
   Inventario total: 1500 litros
   ────────────────────────────────────
   Overhead: ₡135,000 ÷ 1500L = ₡90 por litro
   
   Para presentación de 100 ML (0.1L):
   Overhead = ₡90 × 0.1L = ₡9 adicionales
   ```

4. **Información mostrada:**
   - Total gastos utilitarios: ₡135,000
   - Total inventario: 1500 litros
   - Costo por litro: ₡90.00

#### Paso 4: Usar la Calculadora de Precios

Esta es la función **más poderosa** del sistema.

**4.1 ¿Cómo funciona?**

En lugar de calcular el precio manualmente, tú decides cuánto quieres ganar:

1. **Ingresa el margen deseado**
   - Ejemplo: Quieres ganar 30%
   - Ingresa: `30` en el campo "Margen de Ganancia (%)"

2. **El sistema calcula automáticamente:**
   - Costo del producto (con conversión de unidades)
   - + Costo del envase
   - + Overhead de gastos utilitarios (si está marcado)
   - × (1 + margen%)
   - = **Precio recomendado**

3. **Redondeo automático:**
   - El precio se redondea al múltiplo de ₡5 más cercano
   - Ejemplo: ₡1,347 → ₡1,345
   - Ejemplo: ₡1,348 → ₡1,350

**4.2 Ejemplo Completo:**

```
Producto: Suavizante 1000L @ $0.57/L
Presentación: 100 ML
Tipo de cambio: ₡525 por dólar
Margen deseado: 30%

CÁLCULO PASO A PASO:

1. Costo del producto:
   100 ML = 0.1L
   0.1L × $0.57 = $0.057
   $0.057 × ₡525 = ₡29.93

2. Costo del envase:
   ₡500

3. Overhead (si incluiste gastos):
   ₡90/L × 0.1L = ₡9

4. Costo total:
   ₡29.93 + ₡500 + ₡9 = ₡538.93

5. Aplicar margen del 30%:
   ₡538.93 × 1.30 = ₡700.61

6. Redondear a múltiplo de ₡5:
   ₡700.61 → ₡700

PRECIO FINAL: ₡700
```

**4.3 Vista Previa del Margen:**

Abajo del formulario verás una **tarjeta de vista previa**:

```
┌──────────────────────────────────┐
│  VISTA PREVIA                    │
├──────────────────────────────────┤
│  Costo Total: ₡538.93            │
│  Precio Venta: ₡700.00           │
│  Ganancia: ₡161.07               │
│  Margen: 29.9%                   │
└──────────────────────────────────┘
```

- **Costo Total**: Todo lo que te cuesta producir
- **Precio Venta**: Lo que cobrarás al cliente
- **Ganancia**: Dinero que te queda
- **Margen**: Porcentaje de ganancia real

#### Paso 5: Guardar la Presentación

1. Revisa todos los datos
2. Verifica el margen calculado
3. Click en **"Crear Presentación"**
4. ✅ **"Presentación creada exitosamente"**

#### Paso 6: Ver Lista de Presentaciones

Después de guardar, verás una tabla con todas tus presentaciones:

| Columna | Descripción |
|---------|-------------|
| Nombre | Nombre de la presentación |
| Producto Base | Producto del que deriva |
| Cantidad | Cantidad y unidad (ej: 100 ML) |
| Precio Venta | Precio en CRC |
| Margen | Porcentaje de ganancia |
| Acciones | Editar o eliminar |

### 📝 Parte 2: Registrar Ventas

Ahora que tienes presentaciones creadas, puedes registrar ventas.

#### Paso 1: Ir a Registro de Ventas

1. Click en la pestaña **"Registro de Ventas"**
2. Verás un formulario para nueva venta

#### Paso 2: Completar Formulario de Venta

**2.1 Seleccionar Presentación:**

- Click en **"Presentación"**
- Aparecerán todas las presentaciones que creaste
- Ejemplo: "Botella 100 ML - Liquid Tide Softener"

**2.2 Información del Cliente:**

- **Nombre del Cliente**
  - Ejemplo: "Juan Pérez"
  - Ejemplo: "Pulpería La Esquina"

- **Método de Pago**
  - Opciones:
    - `efectivo` - Pago en efectivo
    - `tarjeta` - Tarjeta débito/crédito
    - `transferencia` - Transferencia bancaria
    - `sinpe` - SINPE Móvil

**2.3 Cantidad y Precio:**

- **Cantidad Vendida**
  - Cuántas unidades vendiste
  - Ejemplo: Si vendiste 5 botellas, ingresa: `5`

- **Precio de Venta Unitario (CRC)**
  - Por defecto aparece el precio de la presentación
  - Puedes modificarlo si hiciste descuento
  - Ejemplo: Precio normal ₡700, descuento a ₡650

**2.4 Vista Previa de Totales:**

El sistema calcula automáticamente:

```
┌──────────────────────────────────┐
│  Cantidad: 5 unidades            │
│  Precio unitario: ₡700           │
│  ──────────────────────────────  │
│  Subtotal: ₡3,500                │
│  ──────────────────────────────  │
│  Costo Total: ₡2,694.65          │
│  Ganancia: ₡805.35               │
│  Margen: 29.9%                   │
└──────────────────────────────────┘
```

#### Paso 3: Guardar la Venta

1. Revisa los totales calculados
2. Click en **"Registrar Venta"**
3. El sistema automáticamente:
   - ✅ Guarda la venta en la base de datos
   - ✅ Descuenta del inventario
   - ✅ Actualiza estadísticas

4. Verás: ✅ **"Venta registrada exitosamente"**

#### Paso 4: Verificar Inventario

Después de una venta:

1. Ve a **"Inventario"**
2. Busca el producto base
3. Verás que la cantidad disminuyó

**Ejemplo:**
```
Antes de venta:
  Suavizante: 1000 litros

Venta realizada:
  5 botellas × 100 ML = 500 ML = 0.5 litros

Después de venta:
  Suavizante: 999.5 litros
```

### 📊 Parte 3: Ver Historial de Ventas

#### Paso 1: Acceder al Historial

1. Click en la pestaña **"Historial"**
2. Verás todas las ventas registradas

#### Paso 2: Interpretar la Tabla

| Columna | Descripción |
|---------|-------------|
| Fecha | Cuándo se realizó la venta |
| Cliente | Nombre del cliente |
| Presentación | Qué se vendió |
| Cantidad | Cuántas unidades |
| Total (CRC) | Monto total de la venta |
| Método de Pago | Cómo pagó |
| Margen | Ganancia porcentual |

#### Paso 3: Filtros Disponibles

- **Por fecha**: Selecciona rango de fechas
- **Por cliente**: Busca ventas de un cliente específico
- **Por método de pago**: Filtra por efectivo, tarjeta, etc.

### 💡 Consejos Avanzados

**Estrategia de Precios:**

1. **Margen recomendado por tipo de producto:**
   - Productos de alta rotación: 20-30%
   - Productos de baja rotación: 40-60%
   - Productos premium: 50-100%

2. **Incluye gastos utilitarios:**
   - Esencial para productos de bajo precio
   - Te aseguras de cubrir costos operativos

3. **Usa la calculadora:**
   - No adivines precios
   - Deja que el sistema calcule por ti

**Control de Inventario:**

1. **Revisa stock antes de vender**
2. **Registra ventas inmediatamente**
3. **Verifica descuentos automáticos**

### ⚠️ Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| "Stock insuficiente" | No hay inventario | Registra una compra primero |
| "Margen negativo" | Precio menor al costo | Aumenta el precio o margen |
| "Presentación no encontrada" | No has creado presentaciones | Ve a "Presentaciones" y crea una |

---

## 💳 Módulo de Gastos

Administra todos tus gastos operativos y utilitarios.

### 🎯 Tipos de Gastos

El sistema maneja dos categorías:

1. **Gastos Operativos**
   - Gastos directos del negocio
   - Ejemplos: Salarios, publicidad, mantenimiento
   - No se prorratean en productos

2. **Gastos Utilitarios**
   - Gastos indirectos compartidos
   - Ejemplos: Luz, agua, alquiler, internet, teléfono
   - **SE PRORRATEAN** en el costo de presentaciones

### ✨ Funcionalidades

1. **Registrar gastos** con categorización
2. **Marcar gastos como utilitarios** para prorrateo
3. **Activar/desactivar gastos** sin eliminarlos
4. **Historial completo** con filtros
5. **Cálculo automático** de overhead

### 📝 Cómo Registrar un Gasto

#### Paso 1: Acceder al Módulo

1. En el menú lateral, click en **"Gastos"**
2. Verás dos pestañas:
   - **Registrar Gasto**
   - **Historial**

#### Paso 2: Completar Formulario

**2.1 Información Básica:**

- **Descripción del Gasto**
  - Sé específico
  - Ejemplo: "Factura de electricidad - Octubre 2025"
  - Ejemplo: "Salario mensual - Juan Rodríguez"

- **Categoría**
  - `operativo` - Gastos directos
  - `administrativo` - Gastos de oficina
  - `marketing` - Publicidad y promoción
  - `otro` - Otros gastos

**2.2 Monto:**

- **Monto (CRC)**
  - Ingresa en colones costarricenses
  - Ejemplo: ₡45,000

**2.3 Tipo de Gasto (IMPORTANTE):**

- **Checkbox "Es gasto utilitario"**
  - ✅ Marca si es: luz, agua, alquiler, internet, teléfono
  - ⬜ Desmarca si es: salario, publicidad, mantenimiento puntual

**¿Por qué es importante?**

Si marcas como "utilitario":
- El gasto se suma al cálculo de overhead
- Se distribuye entre todos los productos
- Afecta el precio recomendado de presentaciones

**2.4 Estado:**

- **Checkbox "Activo"**
  - ✅ Gasto está activo (se incluye en cálculos)
  - ⬜ Gasto inactivo (no se incluye, pero se guarda)

#### Paso 3: Guardar el Gasto

1. Revisa todos los campos
2. Click en **"Registrar Gasto"**
3. ✅ **"Gasto registrado exitosamente"**

### 📊 Ver Historial de Gastos

#### Paso 1: Acceder al Historial

1. Click en la pestaña **"Historial"**
2. Verás una tabla con todos los gastos

#### Paso 2: Entender la Tabla

| Columna | Descripción |
|---------|-------------|
| Fecha | Cuándo se registró |
| Descripción | Detalle del gasto |
| Categoría | Tipo de gasto |
| Monto | Cantidad en CRC |
| Tipo | Utilitario o Normal |
| Estado | Activo o Inactivo |
| Acciones | Editar o eliminar |

#### Paso 3: Filtros Disponibles

- **Por categoría**: Filtra por operativo, administrativo, etc.
- **Por tipo**: Solo utilitarios o solo normales
- **Por estado**: Solo activos o solo inactivos
- **Por fecha**: Rango de fechas

### 💡 Ejemplos Prácticos

**Ejemplo 1: Registrar Gasto de Luz**

```
Descripción: "CNFL - Factura Octubre 2025"
Categoría: operativo
Monto: ₡35,000
✅ Es gasto utilitario
✅ Activo
```

**Resultado:**
- Se suma a los ₡135,000 de gastos utilitarios totales
- Se calcula nuevo overhead por litro
- Afecta precios recomendados de presentaciones

**Ejemplo 2: Registrar Salario**

```
Descripción: "Salario - María González - Octubre"
Categoría: operativo
Monto: ₡450,000
⬜ Es gasto utilitario (NO marcado)
✅ Activo
```

**Resultado:**
- Se registra como gasto normal
- NO afecta el overhead por litro
- Solo aparece en reportes de gastos

**Ejemplo 3: Gasto Inactivo (Temporal)**

```
Descripción: "Reparación de local - Emergencia"
Categoría: operativo
Monto: ₡80,000
⬜ Es gasto utilitario
⬜ Activo (NO marcado)
```

**Resultado:**
- Se guarda en el sistema
- NO afecta cálculos actuales
- Puedes reactivarlo después

### 📈 Impacto en Presentaciones

Cuando creas una presentación y marcas **"Incluir gastos utilitarios"**:

```
Total gastos utilitarios activos:
  ₡35,000 (luz) + ₡45,000 (agua) + ₡55,000 (alquiler) = ₡135,000

Total inventario: 1500 litros

Overhead: ₡135,000 ÷ 1500L = ₡90 por litro

Para presentación de 500 ML (0.5L):
  Overhead = ₡90 × 0.5L = ₡45 adicionales al costo
```

### ⚠️ Consejos Importantes

✅ **Registra gastos mensualmente** para mantener overhead actualizado  
✅ **Marca como utilitarios solo** los gastos compartidos (luz, agua, alquiler)  
✅ **No marques como utilitarios** gastos variables o puntuales  
✅ **Desactiva temporalmente** en lugar de eliminar  
✅ **Revisa el overhead** cada mes en el módulo de Ventas

---

## 📈 Módulo de Reportes

Genera reportes profesionales en PDF con análisis detallados.

### 🎯 Tipos de Reportes Disponibles

1. **Reporte de Ventas** - Análisis completo de ventas
2. **Reporte de Compras** - Resumen de compras por proveedor
3. **Reporte de Gastos** - Desglose de gastos por categoría
4. **Reporte de Inventario** - Estado actual del inventario

### ✨ Características de los Reportes

- 📄 Formato PDF profesional
- 📊 Gráficos y visualizaciones
- 💰 Montos en CRC y USD
- 📅 Filtros por fecha
- 📋 Tablas detalladas
- 📈 Análisis de márgenes y tendencias

### 📝 Cómo Generar un Reporte

#### Paso 1: Acceder al Módulo

1. En el menú lateral, click en **"Reportes"**
2. Verás cuatro pestañas:
   - **Ventas**
   - **Compras**
   - **Gastos**
   - **Inventario**

#### Paso 2: Seleccionar Tipo de Reporte

Click en la pestaña del reporte que necesitas.

### 📊 Reporte de Ventas

**¿Qué incluye?**

- Resumen ejecutivo
- Total de ventas en CRC y USD
- Número de transacciones
- Ticket promedio
- Tabla detallada de ventas
- Distribución por método de pago
- Top 5 productos más vendidos
- Análisis de márgenes

**Paso a Paso:**

1. **Selecciona el rango de fechas:**
   - Fecha Inicio: Ejemplo "2025-10-01"
   - Fecha Fin: Ejemplo "2025-10-31"

2. **Click en "Generar Reporte de Ventas"**

3. **El PDF se descarga automáticamente** con nombre:
   - `reporte-ventas-YYYY-MM-DD.pdf`

**Contenido del PDF:**

```
┌─────────────────────────────────────────┐
│  REPORTE DE VENTAS                      │
│  Octubre 2025                           │
├─────────────────────────────────────────┤
│                                         │
│  RESUMEN EJECUTIVO                      │
│  ────────────────────────────────────   │
│  Total Ventas: ₡1,245,000               │
│  Total Ventas USD: $2,371.43            │
│  Número de Transacciones: 157           │
│  Ticket Promedio: ₡7,929                │
│                                         │
│  DETALLE DE VENTAS                      │
│  ────────────────────────────────────   │
│  Fecha      Cliente    Monto   Método   │
│  2025-10-15 Juan P.    ₡3,500  Efectivo │
│  2025-10-16 María G.   ₡2,100  SINPE    │
│  ...                                    │
│                                         │
│  DISTRIBUCIÓN POR MÉTODO DE PAGO        │
│  ────────────────────────────────────   │
│  Efectivo: 45% (₡560,250)               │
│  SINPE: 30% (₡373,500)                  │
│  Tarjeta: 25% (₡311,250)                │
│                                         │
│  TOP 5 PRODUCTOS                        │
│  ────────────────────────────────────   │
│  1. Botella 100 ML - ₡245,000           │
│  2. Sachet 50 G - ₡198,000              │
│  ...                                    │
└─────────────────────────────────────────┘
```

### 🛒 Reporte de Compras

**¿Qué incluye?**

- Total de compras en USD y CRC
- Número de compras realizadas
- Compra promedio
- Tabla detallada por proveedor
- Top proveedores
- Distribución por producto

**Paso a Paso:**

1. Selecciona rango de fechas
2. Click en "Generar Reporte de Compras"
3. Descarga automática: `reporte-compras-YYYY-MM-DD.pdf`

**Ejemplo de Contenido:**

```
RESUMEN DE COMPRAS
──────────────────
Total Compras USD: $12,450.00
Total Compras CRC: ₡6,536,250
Número de Compras: 23
Compra Promedio: $541.30

DETALLE POR PROVEEDOR
─────────────────────
Proveedor A: $7,200 (58%)
Proveedor B: $3,100 (25%)
Proveedor C: $2,150 (17%)
```

### 💳 Reporte de Gastos

**¿Qué incluye?**

- Total de gastos por categoría
- Gastos utilitarios vs operativos
- Gráfico de distribución
- Tabla detallada
- Comparación mes a mes

**Paso a Paso:**

1. Selecciona rango de fechas
2. Click en "Generar Reporte de Gastos"
3. Descarga: `reporte-gastos-YYYY-MM-DD.pdf`

**Ejemplo de Contenido:**

```
RESUMEN DE GASTOS
─────────────────
Total Gastos: ₡875,000

POR CATEGORÍA
─────────────
Operativo: ₡450,000 (51%)
Administrativo: ₡285,000 (33%)
Marketing: ₡140,000 (16%)

POR TIPO
────────
Utilitarios: ₡135,000
Normales: ₡740,000
```

### 📦 Reporte de Inventario

**¿Qué incluye?**

- Valor total del inventario
- Cantidad de productos
- Lista detallada con costos
- Productos con stock bajo
- Análisis de rotación

**Paso a Paso:**

1. **NO requiere fechas** (es un snapshot actual)
2. Click en "Generar Reporte de Inventario"
3. Descarga: `reporte-inventario-YYYY-MM-DD.pdf`

**Ejemplo de Contenido:**

```
INVENTARIO ACTUAL
─────────────────
Valor Total USD: $15,890
Valor Total CRC: ₡8,342,250
Total Productos: 12

DETALLE
───────
Producto              Cantidad  Costo   Valor
─────────────────────────────────────────────
Suavizante Tide       999.5 L   $0.57   $569.72
Detergente Ariel      500 KG    $1.20   $600.00
...

ALERTAS
───────
⚠️ Stock bajo: Producto X (50 unidades)
🔴 Sin stock: Producto Y (0 unidades)
```

### 💡 Consejos para Reportes

**Periodicidad Recomendada:**

- **Ventas**: Generar semanalmente y mensualmente
- **Compras**: Mensualmente
- **Gastos**: Mensualmente
- **Inventario**: Quincenalmente

**Usos Prácticos:**

✅ Presentar a inversionistas  
✅ Declaración de impuestos  
✅ Análisis de rentabilidad  
✅ Toma de decisiones de compra  
✅ Negociación con proveedores  
✅ Control de costos

**Mejores Prácticas:**

1. **Archiva los PDFs** por mes y año
2. **Compara mes a mes** para detectar tendencias
3. **Analiza márgenes** para ajustar precios
4. **Revisa gastos** para optimizar costos
5. **Monitorea inventario** para evitar stock-outs

---

## ⚙️ Configuración

Ajusta parámetros del sistema y preferencias.

### 🎯 Opciones Disponibles

1. **Tipo de Cambio**
   - Ver tipo de cambio actual USD → CRC
   - Actualización automática diaria

2. **Perfil de Usuario**
   - Cambiar contraseña
   - Actualizar email
   - Gestionar sesiones

3. **Preferencias del Sistema**
   - Redondeo de precios (múltiplo de ₡5)
   - Formato de fechas
   - Idioma (Español)

### 📝 Cómo Acceder

1. En el menú lateral, click en **"Configuración"**
2. Verás varias secciones

### 💱 Gestión de Tipo de Cambio

**Ver tipo de cambio actual:**

```
┌────────────────────────────────┐
│  TIPO DE CAMBIO                │
│  ────────────────────────────  │
│  1 USD = ₡525.00               │
│  Última actualización:         │
│  2025-11-03 08:00 AM           │
└────────────────────────────────┘
```

**¿Cómo se actualiza?**
- Automáticamente cada día a las 6:00 AM
- Fuente: Exchange Rate API
- Se usa en todas las conversiones del sistema

### 🔐 Seguridad y Cuenta

**Cambiar Contraseña:**

1. Click en "Cambiar Contraseña"
2. Ingresa contraseña actual
3. Ingresa nueva contraseña (mínimo 6 caracteres)
4. Confirma nueva contraseña
5. Click en "Actualizar"

**Cerrar Sesión:**

1. Click en tu email (esquina superior derecha)
2. Selecciona "Cerrar Sesión"
3. Serás redirigido al login

### 💡 Consejos de Configuración

✅ **Revisa el tipo de cambio** al inicio del día  
✅ **Cambia tu contraseña** cada 3 meses  
✅ **Cierra sesión** en computadoras compartidas  
✅ **Guarda tus credenciales** en un lugar seguro

---

## ❓ Preguntas Frecuentes

### 🔧 Preguntas Generales

**P: ¿Necesito internet para usar el sistema?**  
R: Sí, RicCommerce es una aplicación web que requiere conexión a internet.

**P: ¿Puedo usar el sistema en mi celular?**  
R: Sí, el sistema es responsive y funciona en celulares, tablets y computadoras.

**P: ¿Mis datos están seguros?**  
R: Sí, todos los datos están encriptados y protegidos con Supabase. Cada usuario solo ve sus propios datos.

**P: ¿Cuántos usuarios puede tener mi cuenta?**  
R: Actualmente, cada cuenta es individual. Para múltiples usuarios, necesitas crear cuentas separadas.

### 💰 Preguntas sobre Ventas

**P: ¿Por qué el margen que ingreso no es exactamente el que veo?**  
R: Por el redondeo automático a múltiplos de ₡5. El margen real puede variar ligeramente.

**P: ¿Qué pasa si vendo a un precio menor que el costo?**  
R: El sistema te mostrará un margen negativo como advertencia, pero te permite continuar.

**P: ¿Cómo vendo un producto que compro en litros pero vendo en mililitros?**  
R: Crea una presentación con la cantidad en mililitros. El sistema convierte automáticamente.

**P: ¿Qué son los gastos utilitarios y debo incluirlos?**  
R: Son gastos compartidos como luz, agua, alquiler. Sí debes incluirlos para precios reales.

### 🛒 Preguntas sobre Compras

**P: ¿Puedo registrar compras en colones?**  
R: No, actualmente solo en dólares. El sistema convierte automáticamente a colones.

**P: ¿Qué pasa si me equivoco al registrar una compra?**  
R: Puedes ir al historial, editar o eliminar la compra. El inventario se ajustará automáticamente.

**P: ¿Cómo registro compras de diferentes proveedores del mismo producto?**  
R: Registra cada compra por separado. El sistema calculará el costo promedio automáticamente.

### 📦 Preguntas sobre Inventario

**P: ¿Por qué mi inventario no coincide con el físico?**  
R: Puede ser por ventas no registradas, compras no ingresadas o mermas. Revisa el historial.

**P: ¿Cómo ajusto el inventario por pérdidas o mermas?**  
R: Actualmente no hay función de ajuste. Registra una venta ficticia o espera actualizaciones futuras.

**P: ¿El sistema me avisa cuando tengo poco stock?**  
R: Sí, verás alertas en el módulo de inventario cuando un producto tenga menos de 100 unidades.

### 💳 Preguntas sobre Gastos

**P: ¿Cuándo debo marcar un gasto como "utilitario"?**  
R: Marca como utilitario solo gastos compartidos y recurrentes: luz, agua, alquiler, internet.

**P: ¿Puedo desactivar un gasto sin eliminarlo?**  
R: Sí, desmarca el checkbox "Activo". El gasto se guarda pero no afecta cálculos.

**P: ¿Los gastos afectan el precio de venta?**  
R: Solo si son utilitarios Y marcas "Incluir gastos utilitarios" al crear presentaciones.

### 📈 Preguntas sobre Reportes

**P: ¿Puedo editar los reportes PDF?**  
R: No, son documentos finales. Pero puedes generar nuevos reportes con diferentes fechas.

**P: ¿Los reportes incluyen impuestos?**  
R: No, el sistema no maneja impuestos actualmente. Debes calcularlos por separado.

**P: ¿Puedo compartir los reportes con mi contador?**  
R: Sí, los PDFs se pueden enviar por email o compartir directamente.

### 🔧 Problemas Técnicos

**P: No puedo iniciar sesión**  
R: Verifica tu email y contraseña. Si olvidaste la contraseña, usa "Recuperar contraseña".

**P: El sistema está lento**  
R: Puede ser tu conexión a internet. Cierra pestañas innecesarias y recarga la página.

**P: No veo mis datos**  
R: Asegúrate de haber iniciado sesión con la cuenta correcta. Los datos son por usuario.

**P: Error "Sesión expirada"**  
R: Tu sesión caducó por inactividad. Inicia sesión nuevamente.

---

## 📞 Soporte y Contacto

### 🆘 ¿Necesitas Ayuda?

Si tienes problemas que no se resuelven con este manual:

1. **Revisa la sección de Preguntas Frecuentes** (arriba)
2. **Verifica tu conexión a internet**
3. **Recarga la página** (F5 o Ctrl+R)
4. **Cierra sesión e inicia de nuevo**

### 📧 Contacto

- **Email de Soporte**: [tu-email-soporte@empresa.com]
- **Teléfono**: [tu-número-de-teléfono]
- **Horario de Atención**: Lunes a Viernes, 8:00 AM - 5:00 PM

### 🐛 Reportar Problemas

Si encuentras un error en el sistema:

1. **Describe el problema claramente**
2. **Indica qué estabas haciendo cuando ocurrió**
3. **Toma un screenshot si es posible**
4. **Envía la información al email de soporte**

---

## 📝 Glosario de Términos

| Término | Definición |
|---------|------------|
| **Presentación** | Formato en que vendes el producto al cliente (ej: botella 100ML) |
| **Producto Base** | Producto que compras a granel (ej: 1000 litros) |
| **Margen** | Porcentaje de ganancia sobre el costo |
| **Overhead** | Costos indirectos distribuidos (gastos utilitarios) |
| **Costo Promedio** | Precio promedio ponderado de todas las compras |
| **Stock** | Cantidad disponible en inventario |
| **Utilitario** | Gasto compartido que se prorratea (luz, agua, alquiler) |
| **Ticket Promedio** | Valor promedio de cada venta |
| **Tipo de Cambio** | Conversión de dólares a colones (USD → CRC) |
| **SKU** | Unidad de mantenimiento de stock (cada producto único) |

---

## 📚 Apéndice: Fórmulas Utilizadas

### 💰 Cálculo de Precio Unitario (Compras)

```
Precio Unitario USD = Total Compra USD ÷ Cantidad
```

Ejemplo:
```
$570 ÷ 1000 litros = $0.57 por litro
```

### 📦 Cálculo de Costo Promedio

```
Costo Promedio = (Stock Anterior × Costo Anterior + Nueva Compra × Costo Nuevo) ÷ Stock Total
```

Ejemplo:
```
(500L × $0.55 + 1000L × $0.57) ÷ 1500L = $0.567 por litro
```

### 🔄 Conversión de Unidades

**Litros ↔ Mililitros:**
```
Litros = Mililitros ÷ 1000
Mililitros = Litros × 1000
```

**Kilogramos ↔ Gramos:**
```
Kilogramos = Gramos ÷ 1000
Gramos = Kilogramos × 1000
```

### 💵 Cálculo de Overhead por Litro

```
Overhead por Litro = Total Gastos Utilitarios ÷ Total Inventario en Litros
```

Ejemplo:
```
₡135,000 ÷ 1500 litros = ₡90 por litro
```

### 💰 Cálculo de Precio Recomendado

```
Costo Total = Costo Producto + Costo Envase + (Overhead × Cantidad)
Precio Recomendado = Costo Total × (1 + Margen%)
Precio Final = Redondear(Precio Recomendado, ₡5)
```

Ejemplo:
```
Costo Producto: ₡29.93
Costo Envase: ₡500
Overhead: ₡90/L × 0.1L = ₡9
─────────────────────
Costo Total: ₡538.93

Margen 30%: ₡538.93 × 1.30 = ₡700.61
Redondeo: ₡700
```

### 📊 Cálculo de Margen de Ganancia

```
Margen % = ((Precio Venta - Costo Total) ÷ Costo Total) × 100
```

Ejemplo:
```
(₡700 - ₡538.93) ÷ ₡538.93 × 100 = 29.9%
```

### 💱 Conversión USD → CRC

```
Monto CRC = Monto USD × Tipo de Cambio
```

Ejemplo:
```
$570 × ₡525 = ₡299,250
```

---

## ✅ Checklist de Inicio Rápido

Usa esta lista para configurar tu sistema por primera vez:

### Día 1: Configuración Inicial

- [ ] Crear cuenta y confirmar email
- [ ] Iniciar sesión por primera vez
- [ ] Revisar tipo de cambio actual
- [ ] Familiarizarse con el dashboard

### Día 2: Cargar Datos

- [ ] Crear tus primeros 3 productos
- [ ] Registrar compras iniciales de inventario
- [ ] Verificar que el inventario se actualizó
- [ ] Registrar gastos utilitarios del mes (luz, agua, alquiler)

### Día 3: Configurar Ventas

- [ ] Crear presentaciones para cada producto
- [ ] Usar calculadora de precios con margen del 30%
- [ ] Incluir gastos utilitarios en presentaciones
- [ ] Verificar precios recomendados

### Día 4: Primera Venta

- [ ] Registrar tu primera venta
- [ ] Verificar que el inventario disminuyó
- [ ] Revisar margen real de la venta
- [ ] Generar reporte de ventas

### Día 5: Reportes y Análisis

- [ ] Generar reporte de inventario
- [ ] Generar reporte de gastos
- [ ] Revisar márgenes y ajustar precios si es necesario
- [ ] Archivar los PDFs

---

## 🎓 Certificación de Lectura

**Has completado el Manual de Usuario de RicCommerce**

Ahora sabes cómo:

✅ Registrarte e iniciar sesión  
✅ Crear productos y registrar compras  
✅ Gestionar inventario en tiempo real  
✅ Crear presentaciones con conversión de unidades  
✅ Calcular precios con márgenes objetivo  
✅ Prorratear gastos utilitarios  
✅ Registrar ventas y actualizar inventario  
✅ Administrar gastos operativos  
✅ Generar reportes profesionales en PDF  
✅ Interpretar métricas y análisis  

**¡Estás listo para gestionar tu negocio con RicCommerce!**

---

**Versión del Manual**: 1.0.0  
**Fecha de Publicación**: Noviembre 2025  
**Última Actualización**: 3 de Noviembre, 2025

---

© 2025 RicCommerce. Todos los derechos reservados.
