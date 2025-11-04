import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Tipos de base de datos
export interface Producto {
  id: string
  nombre: string
  marca: string
  descripcion?: string
  unidad_medida: string
  categoria?: string
  activo: boolean
  created_at: string
  updated_at: string
}

export interface Presentacion {
  id: string
  producto_id: string
  nombre: string
  cantidad: number
  unidad: string
  costo_envase: number
  precio_venta_colones: number
  activo: boolean
  created_at: string
  updated_at: string
}

export interface Compra {
  id: string
  fecha: string
  total_usd: number
  notas?: string
  usuario_id: string
  created_at: string
  updated_at: string
}

export interface CompraDetalle {
  id: string
  compra_id: string
  producto_id: string
  cantidad: number
  precio_unitario_usd: number
  subtotal_usd: number
  created_at: string
}

export interface Venta {
  id: string
  fecha: string
  total_colones: number
  total_usd: number
  tasa_cambio: number
  notas?: string
  usuario_id: string
  created_at: string
  updated_at: string
}

export interface VentaDetalle {
  id: string
  venta_id: string
  presentacion_id: string
  cantidad: number
  precio_unitario_colones: number
  subtotal_colones: number
  costo_unitario_usd: number
  margen_porcentaje: number
  created_at: string
}

export interface Gasto {
  id: string
  tipo: 'unico' | 'utilitario'
  categoria: string
  descripcion: string
  monto_usd: number
  fecha: string
  periodicidad?: string
  activo: boolean
  usuario_id: string
  created_at: string
  updated_at: string
}

export interface Inventario {
  id: string
  producto_id: string
  cantidad_disponible: number
  costo_promedio_usd: number
  updated_at: string
}

export interface PrecioCompetencia {
  id: string
  usuario_id: string
  marca: string
  producto: string
  precio_crc: number
  precio_usd: number
  cantidad: number
  unidad_medida: string
  distribuidor: string
  categoria?: string
  notas?: string
  activo: boolean
  fecha_registro: string
  created_at: string
  updated_at: string
}

export interface MovimientoInventario {
  id: string
  producto_id: string
  tipo: 'entrada' | 'salida' | 'ajuste'
  cantidad: number
  referencia_tipo?: string
  referencia_id?: string
  notas?: string
  usuario_id: string
  created_at: string
}

export interface PerfilUsuario {
  id: string
  nombre_completo?: string
  rol: string
  puede_editar: boolean
  puede_eliminar: boolean
  activo: boolean
  created_at: string
  updated_at: string
}

export interface Configuracion {
  id: string
  clave: string
  valor: string
  descripcion?: string
  updated_at: string
}
