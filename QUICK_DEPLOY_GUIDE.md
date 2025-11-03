# 🚀 Guía Rápida de Despliegue en Vercel

## Paso 1: Preparar Base de Datos Supabase (5 minutos)

1. Ve a [supabase.com](https://supabase.com) y crea un proyecto
2. Copia tu **URL** y **anon key** (los necesitarás después)
3. Ve a **SQL Editor** en Supabase
4. Abre el archivo `supabase-schema.sql` de este proyecto
5. Copia todo el contenido y pégalo en el SQL Editor
6. Clic en **Run** para crear todas las tablas

## Paso 2: Subir Código a GitHub (2 minutos)

```bash
# Si aún no has hecho commit
git add .
git commit -m "Listo para despliegue en Vercel"
git push origin main
```

## Paso 3: Desplegar en Vercel (3 minutos)

1. Ve a [vercel.com](https://vercel.com)
2. Clic en **"Add New Project"**
3. Importa tu repositorio de GitHub (**RicCommerce**)
4. En **Environment Variables**, agrega estas 3 variables:

```
NEXT_PUBLIC_SUPABASE_URL
[pega aquí la URL que copiaste de Supabase]

NEXT_PUBLIC_SUPABASE_ANON_KEY
[pega aquí la anon key que copiaste de Supabase]

NEXT_PUBLIC_EXCHANGE_API_URL
https://api.exchangerate-api.com/v4/latest/USD
```

5. Marca las 3 casillas: **Production**, **Preview**, **Development**
6. Clic en **Deploy**
7. Espera 2-3 minutos mientras Vercel hace el build

## Paso 4: Configurar URLs en Supabase (1 minuto)

1. Copia la URL que Vercel te dio (ej: `https://riccommerce-xxx.vercel.app`)
2. Ve a tu proyecto en Supabase
3. **Authentication** > **URL Configuration**
4. **Site URL**: Pega tu URL de Vercel
5. **Redirect URLs**: Pega tu URL de Vercel seguida de `/**`
   - Ejemplo: `https://riccommerce-xxx.vercel.app/**`
6. Clic en **Save**

## Paso 5: ¡Prueba tu Aplicación! ✅

1. Abre la URL de Vercel en tu navegador
2. Regístrate con un usuario nuevo
3. Prueba cada módulo:
   - ✅ Crear un producto
   - ✅ Registrar una compra
   - ✅ Crear una presentación
   - ✅ Registrar una venta
   - ✅ Ver reportes

---

## 🎉 ¡Listo!

Tu aplicación está en producción en: `https://______.vercel.app`

### Actualizaciones Futuras

Cada vez que hagas cambios:

```bash
git add .
git commit -m "Descripción de cambios"
git push origin main
```

Vercel automáticamente detectará los cambios y desplegará la nueva versión.

---

## ⚠️ Problemas Comunes

**No puedo hacer login**
- Verifica que agregaste la URL de Vercel en Supabase (Paso 4)
- Verifica que las 3 variables de entorno estén en Vercel

**Error: "Module not found"**
- Ejecuta `npm install` localmente
- Haz commit y push nuevamente

**Símbolos raros en PDF**
- Ya está solucionado en el código (usa "CRC" en lugar de "₡")

**Margen de ganancia incorrecto**
- Verifica que registraste la compra del producto primero
- Verifica que la unidad de medida sea la correcta (litros/mililitros)

---

## 📞 Soporte

- Documentación completa: Ver `README.md`
- Checklist detallado: Ver `DEPLOYMENT_CHECKLIST.md`
- Problemas con Vercel: [vercel.com/docs](https://vercel.com/docs)
- Problemas con Supabase: [supabase.com/docs](https://supabase.com/docs)
