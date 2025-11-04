'use client'

import { useEffect, useState } from 'react'
import { supabase, Producto, PrecioCompetencia } from '@/lib/supabase'
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'
import { TrendingUp, TrendingDown, Target, AlertCircle } from 'lucide-react'
import { calcularPrecioPorUnidad, compararConCompetencia, agruparPorCategoria, ComparacionPrecio } from '@/lib/comparacion'
import { formatCurrency } from '@/lib/utils'

interface ProductoConPresentacion {
  producto: Producto
  presentaciones: Array<{
    id: string
    nombre: string
    cantidad: number
    unidad: string
    precio_venta_colones: number
    costo_envase: number
  }>
  inventario?: {
    costo_promedio_usd: number
  }
}

export default function ComparacionPage() {
  const [productos, setProductos] = useState<ProductoConPresentacion[]>([])
  const [preciosCompetencia, setPreciosCompetencia] = useState<PrecioCompetencia[]>([])
  const [loading, setLoading] = useState(true)
  const [tasaCambio, setTasaCambio] = useState(540)
  const [categoriaSeleccionada, setCategoriaSeleccionada] = useState<string>('TODAS')

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) return

      // Cargar productos con presentaciones e inventario
      const { data: productosData } = await supabase
        .from('productos')
        .select('*')
        .eq('activo', true)
        .not('categoria', 'is', null)

      if (!productosData) return

      // Cargar presentaciones para cada producto
      const productosConDatos = await Promise.all(
        productosData.map(async (prod) => {
          const { data: presentaciones } = await supabase
            .from('presentaciones')
            .select('id, nombre, cantidad, unidad, precio_venta_colones, costo_envase')
            .eq('producto_id', prod.id)
            .eq('activo', true)

          const { data: inventario } = await supabase
            .from('inventario')
            .select('costo_promedio_usd')
            .eq('producto_id', prod.id)
            .single()

          return {
            producto: prod,
            presentaciones: presentaciones || [],
            inventario: inventario || undefined
          }
        })
      )

      setProductos(productosConDatos)

      // Cargar precios de competencia
      const { data: competenciaData } = await supabase
        .from('precios_competencia')
        .select('*')
        .eq('activo', true)

      setPreciosCompetencia(competenciaData || [])
    } catch (error) {
      console.error('Error cargando datos:', error)
    } finally {
      setLoading(false)
    }
  }

  // Agrupar datos por categoría
  const categorias = Array.from(new Set([
    ...productos.map(p => p.producto.categoria).filter(Boolean),
    ...preciosCompetencia.map(p => p.categoria).filter(Boolean)
  ])) as string[]

  // Filtrar productos por categoría
  const productosFiltrados = categoriaSeleccionada === 'TODAS'
    ? productos
    : productos.filter(p => p.producto.categoria === categoriaSeleccionada)

  // Preparar datos para el gráfico
  const datosGrafico = productosFiltrados.flatMap(({ producto, presentaciones, inventario }) => {
    if (!presentaciones.length) return []

    return presentaciones.map(pres => {
      // Usar el precio de venta (convertido de colones a USD)
      const TASA_CAMBIO = 540
      const precioVentaUSD = (pres.precio_venta_colones || 0) / TASA_CAMBIO
      const tuPrecioPorUnidad = calcularPrecioPorUnidad(precioVentaUSD, pres.cantidad, pres.unidad)

      // Obtener precios de competencia de la misma categoría
      const competenciaSimilar = preciosCompetencia.filter(
        c => c.categoria === producto.categoria
      )

      const comparacion = compararConCompetencia(
        precioVentaUSD,
        pres.cantidad,
        pres.unidad,
        competenciaSimilar
      )

      return {
        nombre: `${producto.nombre} ${pres.nombre}`,
        categoria: producto.categoria,
        tuPrecio: tuPrecioPorUnidad,
        walmart: comparacion?.walmart || null,
        pricesmart: comparacion?.pricesmart || null,
        promedio: comparacion?.promedioCompetencia || null,
        esCompetitivo: comparacion?.esCompetitivo,
        diferencia: comparacion?.diferenciaPorcentaje
      }
    })
  })

  if (loading) {
    return <div className="flex items-center justify-center h-64">Cargando análisis...</div>
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold">Análisis Comparativo de Precios</h1>
        <p className="text-gray-600 mt-1">Compara tus precios con Walmart y PriceSmart</p>
      </div>

      {/* Filtro por categoría */}
      <div className="bg-white p-4 rounded-lg shadow">
        <label className="block text-sm font-medium mb-2">Categoría</label>
        <select
          value={categoriaSeleccionada}
          onChange={(e) => setCategoriaSeleccionada(e.target.value)}
          className="w-full md:w-64 px-3 py-2 border rounded-lg"
        >
          <option value="TODAS">Todas las categorías</option>
          {categorias.map(cat => (
            <option key={cat} value={cat}>{cat.charAt(0).toUpperCase() + cat.slice(1)}</option>
          ))}
        </select>
      </div>

      {/* Gráfico de líneas comparativo */}
      <div className="bg-white p-6 rounded-lg shadow">
        <h2 className="text-xl font-bold mb-4">Precio por Litro/Kg - Comparación</h2>
        <div className="h-96">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={datosGrafico}>
              <CartesianGrid strokeDasharray="3 3" />
              <XAxis 
                dataKey="nombre" 
                angle={-45}
                textAnchor="end"
                height={100}
                interval={0}
              />
              <YAxis 
                label={{ value: 'Precio USD/Unidad', angle: -90, position: 'insideLeft' }}
              />
              <Tooltip 
                formatter={(value: number) => `$${value.toFixed(2)}`}
                labelStyle={{ color: '#000' }}
              />
              <Legend />
              <Line 
                type="monotone" 
                dataKey="tuPrecio" 
                stroke="#3b82f6" 
                strokeWidth={3}
                name="Tu Precio"
                dot={{ r: 6 }}
              />
              <Line 
                type="monotone" 
                dataKey="walmart" 
                stroke="#ef4444" 
                strokeWidth={2}
                name="Walmart"
                connectNulls
                dot={{ r: 4 }}
              />
              <Line 
                type="monotone" 
                dataKey="pricesmart" 
                stroke="#22c55e" 
                strokeWidth={2}
                name="PriceSmart"
                connectNulls
                dot={{ r: 4 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>
        <div className="mt-4 flex gap-6 justify-center text-sm">
          <div className="flex items-center gap-2">
            <div className="w-4 h-4 bg-blue-500 rounded"></div>
            <span>Tu Precio</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-4 h-4 bg-red-500 rounded"></div>
            <span>Walmart</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-4 h-4 bg-green-500 rounded"></div>
            <span>PriceSmart</span>
          </div>
        </div>
      </div>

      {/* Tabla de análisis detallado */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="px-6 py-4 border-b">
          <h2 className="text-xl font-bold">Análisis Detallado</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Producto</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tu Precio</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Walmart</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">PriceSmart</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Diferencia</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {datosGrafico.map((dato, idx) => (
                <tr key={idx} className="hover:bg-gray-50">
                  <td className="px-6 py-4">
                    <div>
                      <div className="font-medium">{dato.nombre}</div>
                      <div className="text-xs text-gray-500">{dato.categoria}</div>
                    </div>
                  </td>
                  <td className="px-6 py-4 font-bold text-blue-600">
                    ${dato.tuPrecio.toFixed(2)}
                  </td>
                  <td className="px-6 py-4 text-red-600">
                    {dato.walmart ? `$${dato.walmart.toFixed(2)}` : 'N/A'}
                  </td>
                  <td className="px-6 py-4 text-green-600">
                    {dato.pricesmart ? `$${dato.pricesmart.toFixed(2)}` : 'N/A'}
                  </td>
                  <td className="px-6 py-4">
                    {dato.diferencia !== undefined && (
                      <div className="flex items-center gap-1">
                        {dato.diferencia > 0 ? (
                          <>
                            <TrendingUp size={16} className="text-red-500" />
                            <span className="text-red-600">+{dato.diferencia.toFixed(1)}%</span>
                          </>
                        ) : (
                          <>
                            <TrendingDown size={16} className="text-green-500" />
                            <span className="text-green-600">{dato.diferencia.toFixed(1)}%</span>
                          </>
                        )}
                      </div>
                    )}
                  </td>
                  <td className="px-6 py-4">
                    {dato.esCompetitivo ? (
                      <span className="px-2 py-1 bg-green-100 text-green-800 rounded-full text-xs font-medium">
                        ✓ Competitivo
                      </span>
                    ) : (
                      <span className="px-2 py-1 bg-yellow-100 text-yellow-800 rounded-full text-xs font-medium">
                        ⚠ Por encima
                      </span>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
