'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { Package, DollarSign, TrendingUp, AlertCircle } from 'lucide-react'
import Link from 'next/link'

interface DashboardStats {
  totalProductos: number
  totalInventario: number
  ventasMes: number
  margenPromedio: number
  productosStockBajo: number
}

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats>({
    totalProductos: 0,
    totalInventario: 0,
    ventasMes: 0,
    margenPromedio: 0,
    productosStockBajo: 0,
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadStats()
  }, [])

  const loadStats = async () => {
    try {
      // Total de productos
      const { count: totalProductos } = await supabase
        .from('productos')
        .select('*', { count: 'exact', head: true })
        .eq('activo', true)

      // Valor total del inventario
      const { data: inventarioData } = await supabase
        .from('inventario')
        .select('cantidad_disponible, costo_promedio_usd')

      const totalInventario = inventarioData?.reduce(
        (sum, item) => sum + (item.cantidad_disponible * item.costo_promedio_usd),
        0
      ) || 0

      // Ventas del mes actual
      const primerDiaMes = new Date()
      primerDiaMes.setDate(1)
      
      const { data: ventasData } = await supabase
        .from('ventas')
        .select('total_colones')
        .gte('fecha', primerDiaMes.toISOString().split('T')[0])

      const ventasMes = ventasData?.reduce((sum, v) => sum + v.total_colones, 0) || 0

      // Margen promedio
      const { data: margenData } = await supabase
        .from('ventas_detalle')
        .select('margen_porcentaje')
        .gte('created_at', primerDiaMes.toISOString())

      const margenPromedio = margenData?.length
        ? margenData.reduce((sum, m) => sum + (m.margen_porcentaje || 0), 0) / margenData.length
        : 0

      // Productos con stock bajo (menos de 10 unidades)
      const { data: stockBajo } = await supabase
        .from('inventario')
        .select('*')
        .lt('cantidad_disponible', 10)

      setStats({
        totalProductos: totalProductos || 0,
        totalInventario,
        ventasMes,
        margenPromedio,
        productosStockBajo: stockBajo?.length || 0,
      })
    } catch (error) {
      console.error('Error cargando estadísticas:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-600 mt-2">Resumen general del sistema</p>
      </div>

      {/* Tarjetas de estadísticas */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div className="card bg-gradient-to-br from-blue-500 to-blue-600 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-blue-100 text-sm">Total Productos</p>
              <p className="text-3xl font-bold mt-2">{stats.totalProductos}</p>
            </div>
            <Package size={48} className="opacity-80" />
          </div>
        </div>

        <div className="card bg-gradient-to-br from-green-500 to-green-600 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-green-100 text-sm">Inventario (USD)</p>
              <p className="text-3xl font-bold mt-2">
                ${stats.totalInventario.toFixed(2)}
              </p>
            </div>
            <DollarSign size={48} className="opacity-80" />
          </div>
        </div>

        <div className="card bg-gradient-to-br from-purple-500 to-purple-600 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-purple-100 text-sm">Ventas del Mes (₡)</p>
              <p className="text-3xl font-bold mt-2">
                ₡{stats.ventasMes.toLocaleString('es-CR')}
              </p>
            </div>
            <TrendingUp size={48} className="opacity-80" />
          </div>
        </div>

        <div className="card bg-gradient-to-br from-orange-500 to-orange-600 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-orange-100 text-sm">Margen Promedio</p>
              <p className="text-3xl font-bold mt-2">
                {stats.margenPromedio.toFixed(1)}%
              </p>
            </div>
            <TrendingUp size={48} className="opacity-80" />
          </div>
        </div>
      </div>

      {/* Alertas */}
      {stats.productosStockBajo > 0 && (
        <div className="bg-yellow-50 border-l-4 border-yellow-400 p-4 mb-8">
          <div className="flex items-center">
            <AlertCircle className="text-yellow-400 mr-3" size={24} />
            <div>
              <p className="text-yellow-800 font-medium">
                Alerta de Stock Bajo
              </p>
              <p className="text-yellow-700 text-sm mt-1">
                Hay {stats.productosStockBajo} producto(s) con menos de 10 unidades en stock.{' '}
                <Link href="/dashboard/inventario" className="underline font-medium">
                  Ver detalles
                </Link>
              </p>
            </div>
          </div>
        </div>
      )}

      {/* Accesos rápidos */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <Link href="/dashboard/compras" className="card hover:shadow-lg transition-shadow cursor-pointer">
          <h3 className="text-lg font-semibold text-gray-900 mb-2">Registrar Compra</h3>
          <p className="text-gray-600 text-sm">
            Agregar nuevas compras y actualizar inventario
          </p>
        </Link>

        <Link href="/dashboard/ventas" className="card hover:shadow-lg transition-shadow cursor-pointer">
          <h3 className="text-lg font-semibold text-gray-900 mb-2">Registrar Venta</h3>
          <p className="text-gray-600 text-sm">
            Procesar ventas y calcular márgenes
          </p>
        </Link>

        <Link href="/dashboard/inventario" className="card hover:shadow-lg transition-shadow cursor-pointer">
          <h3 className="text-lg font-semibold text-gray-900 mb-2">Ver Inventario</h3>
          <p className="text-gray-600 text-sm">
            Consultar stock disponible de productos
          </p>
        </Link>

        <Link href="/dashboard/gastos" className="card hover:shadow-lg transition-shadow cursor-pointer">
          <h3 className="text-lg font-semibold text-gray-900 mb-2">Gestionar Gastos</h3>
          <p className="text-gray-600 text-sm">
            Registrar gastos únicos y utilitarios
          </p>
        </Link>

        <Link href="/dashboard/reportes" className="card hover:shadow-lg transition-shadow cursor-pointer">
          <h3 className="text-lg font-semibold text-gray-900 mb-2">Generar Reportes</h3>
          <p className="text-gray-600 text-sm">
            Crear informes y analizar datos
          </p>
        </Link>

        <Link href="/dashboard/configuracion" className="card hover:shadow-lg transition-shadow cursor-pointer">
          <h3 className="text-lg font-semibold text-gray-900 mb-2">Configuración</h3>
          <p className="text-gray-600 text-sm">
            Ajustar preferencias del sistema
          </p>
        </Link>
      </div>
    </div>
  )
}
