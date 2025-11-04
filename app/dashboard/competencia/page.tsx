'use client'

import { useEffect, useState } from 'react'
import { supabase, PrecioCompetencia } from '@/lib/supabase'
import { Plus, Trash2, Edit2, Save, X, TrendingUp, TrendingDown, BarChart3 } from 'lucide-react'
import { formatCurrency } from '@/lib/utils'
import Link from 'next/link'

export default function CompetenciaPage() {
  const [precios, setPrecios] = useState<PrecioCompetencia[]>([])
  const [loading, setLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [editingId, setEditingId] = useState<string | null>(null)
  const [filtroDistribuidor, setFiltroDistribuidor] = useState<string>('TODOS')
  const [filtroCategoria, setFiltroCategoria] = useState<string>('TODOS')
  
  const [nuevoPrecio, setNuevoPrecio] = useState({
    marca: '',
    producto: '',
    precio_crc: 0,
    precio_usd: 0,
    cantidad: 0,
    unidad_medida: 'mililitros',
    distribuidor: 'WALMART',
    categoria: '',
    notas: ''
  })

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      const { data, error } = await supabase
        .from('precios_competencia')
        .select('*')
        .eq('activo', true)
        .order('distribuidor', { ascending: true })
        .order('precio_usd', { ascending: false })

      if (error) throw error
      setPrecios(data || [])
    } catch (error) {
      console.error('Error cargando precios:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    try {
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error('No autenticado')

      if (editingId) {
        // Actualizar
        const { error } = await supabase
          .from('precios_competencia')
          .update(nuevoPrecio)
          .eq('id', editingId)

        if (error) throw error
      } else {
        // Crear nuevo
        const { error } = await supabase
          .from('precios_competencia')
          .insert([{ ...nuevoPrecio, usuario_id: user.id }])

        if (error) throw error
      }

      setShowModal(false)
      setEditingId(null)
      resetForm()
      loadData()
    } catch (error: any) {
      alert('Error: ' + error.message)
    }
  }

  const handleEdit = (precio: PrecioCompetencia) => {
    setNuevoPrecio({
      marca: precio.marca,
      producto: precio.producto,
      precio_crc: precio.precio_crc,
      precio_usd: precio.precio_usd,
      cantidad: precio.cantidad,
      unidad_medida: precio.unidad_medida,
      distribuidor: precio.distribuidor,
      categoria: precio.categoria || '',
      notas: precio.notas || ''
    })
    setEditingId(precio.id)
    setShowModal(true)
  }

  const handleDelete = async (id: string) => {
    if (!confirm('¿Eliminar este precio de competencia?')) return

    try {
      const { error } = await supabase
        .from('precios_competencia')
        .update({ activo: false })
        .eq('id', id)

      if (error) throw error
      loadData()
    } catch (error: any) {
      alert('Error: ' + error.message)
    }
  }

  const resetForm = () => {
    setNuevoPrecio({
      marca: '',
      producto: '',
      precio_crc: 0,
      precio_usd: 0,
      cantidad: 0,
      unidad_medida: 'mililitros',
      distribuidor: 'WALMART',
      categoria: '',
      notas: ''
    })
  }

  // Filtrar precios
  const preciosFiltrados = precios.filter(p => {
    const matchDistribuidor = filtroDistribuidor === 'TODOS' || p.distribuidor === filtroDistribuidor
    const matchCategoria = filtroCategoria === 'TODOS' || p.categoria === filtroCategoria
    return matchDistribuidor && matchCategoria
  })

  // Obtener lista única de distribuidores y categorías
  const distribuidores = Array.from(new Set(precios.map(p => p.distribuidor)))
  const categorias = Array.from(new Set(precios.map(p => p.categoria).filter(Boolean)))

  // Calcular estadísticas
  const stats = {
    total: preciosFiltrados.length,
    promedioUSD: preciosFiltrados.length > 0 
      ? preciosFiltrados.reduce((sum, p) => sum + p.precio_usd, 0) / preciosFiltrados.length 
      : 0,
    promedioCRC: preciosFiltrados.length > 0 
      ? preciosFiltrados.reduce((sum, p) => sum + p.precio_crc, 0) / preciosFiltrados.length 
      : 0,
    walmart: precios.filter(p => p.distribuidor === 'WALMART').length,
    pricesmart: precios.filter(p => p.distribuidor === 'PRICESMART').length
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-lg">Cargando precios de competencia...</div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold">Precios de Competencia</h1>
          <p className="text-gray-600 mt-1">Monitoreo de precios de Walmart y PriceSmart</p>
        </div>
        <div className="flex gap-3">
          <Link
            href="/dashboard/competencia/comparacion"
            className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700"
          >
            <BarChart3 size={20} />
            Ver Comparación
          </Link>
          <button
            onClick={() => {
              resetForm()
              setShowModal(true)
            }}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            <Plus size={20} />
            Agregar Precio
          </button>
        </div>
      </div>

      {/* Estadísticas */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="text-sm text-gray-600">Total Productos</div>
          <div className="text-2xl font-bold">{stats.total}</div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="text-sm text-gray-600">Walmart</div>
          <div className="text-2xl font-bold text-red-600">{stats.walmart}</div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="text-sm text-gray-600">PriceSmart</div>
          <div className="text-2xl font-bold text-green-600">{stats.pricesmart}</div>
        </div>
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="text-sm text-gray-600">Precio Promedio</div>
          <div className="text-2xl font-bold">{formatCurrency(stats.promedioUSD, 'USD')}</div>
        </div>
      </div>

      {/* Filtros */}
      <div className="bg-white p-4 rounded-lg shadow">
        <div className="flex gap-4">
          <div className="flex-1">
            <label className="block text-sm font-medium mb-1">Distribuidor</label>
            <select
              value={filtroDistribuidor}
              onChange={(e) => setFiltroDistribuidor(e.target.value)}
              className="w-full px-3 py-2 border rounded-lg"
            >
              <option value="TODOS">Todos</option>
              {distribuidores.map(d => (
                <option key={d} value={d}>{d}</option>
              ))}
            </select>
          </div>
          <div className="flex-1">
            <label className="block text-sm font-medium mb-1">Categoría</label>
            <select
              value={filtroCategoria}
              onChange={(e) => setFiltroCategoria(e.target.value)}
              className="w-full px-3 py-2 border rounded-lg"
            >
              <option value="TODOS">Todas</option>
              {categorias.map(c => (
                <option key={c} value={c}>{c}</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Tabla de precios */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Distribuidor</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Marca</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Producto</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Cantidad</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Precio USD</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Precio ₡</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">$/Litro</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Categoría</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">Acciones</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {preciosFiltrados.map((precio) => {
                // Calcular precio por litro/kg
                const cantidadEnLitros = precio.unidad_medida === 'mililitros' ? precio.cantidad / 1000 :
                                        precio.unidad_medida === 'gramos' ? precio.cantidad / 1000 :
                                        precio.cantidad
                const precioPorUnidad = precio.precio_usd / cantidadEnLitros

                return (
                  <tr key={precio.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4">
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        precio.distribuidor === 'WALMART' ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800'
                      }`}>
                        {precio.distribuidor}
                      </span>
                    </td>
                    <td className="px-6 py-4 font-medium">{precio.marca}</td>
                    <td className="px-6 py-4 text-sm">{precio.producto}</td>
                    <td className="px-6 py-4 text-sm">
                      {precio.cantidad} {precio.unidad_medida}
                    </td>
                    <td className="px-6 py-4 font-bold">{formatCurrency(precio.precio_usd, 'USD')}</td>
                    <td className="px-6 py-4">{formatCurrency(precio.precio_crc, 'CRC')}</td>
                    <td className="px-6 py-4 text-sm">${precioPorUnidad.toFixed(2)}</td>
                    <td className="px-6 py-4">
                      <span className="px-2 py-1 bg-gray-100 rounded text-xs">
                        {precio.categoria || 'N/A'}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-right">
                      <div className="flex justify-end gap-2">
                        <button
                          onClick={() => handleEdit(precio)}
                          className="p-1 text-blue-600 hover:bg-blue-50 rounded"
                        >
                          <Edit2 size={16} />
                        </button>
                        <button
                          onClick={() => handleDelete(precio.id)}
                          className="p-1 text-red-600 hover:bg-red-50 rounded"
                        >
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6">
              <div className="flex justify-between items-center mb-6">
                <h2 className="text-2xl font-bold">
                  {editingId ? 'Editar Precio' : 'Agregar Precio de Competencia'}
                </h2>
                <button
                  onClick={() => {
                    setShowModal(false)
                    setEditingId(null)
                    resetForm()
                  }}
                  className="text-gray-500 hover:text-gray-700"
                >
                  <X size={24} />
                </button>
              </div>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-1">Distribuidor</label>
                    <select
                      value={nuevoPrecio.distribuidor}
                      onChange={(e) => setNuevoPrecio({ ...nuevoPrecio, distribuidor: e.target.value })}
                      className="w-full px-3 py-2 border rounded-lg"
                      required
                    >
                      <option value="WALMART">Walmart</option>
                      <option value="PRICESMART">PriceSmart</option>
                      <option value="OTROS">Otros</option>
                    </select>
                  </div>

                  <div>
                    <label className="block text-sm font-medium mb-1">Categoría</label>
                    <select
                      value={nuevoPrecio.categoria}
                      onChange={(e) => setNuevoPrecio({ ...nuevoPrecio, categoria: e.target.value })}
                      className="w-full px-3 py-2 border rounded-lg"
                    >
                      <option value="">Seleccionar...</option>
                      <option value="detergente">Detergente</option>
                      <option value="cloro">Cloro</option>
                      <option value="jabon">Jabón</option>
                      <option value="suavizante">Suavizante</option>
                      <option value="desinfectante">Desinfectante</option>
                      <option value="perlas">Perlas</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-1">Marca</label>
                  <input
                    type="text"
                    value={nuevoPrecio.marca}
                    onChange={(e) => setNuevoPrecio({ ...nuevoPrecio, marca: e.target.value })}
                    className="w-full px-3 py-2 border rounded-lg"
                    required
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium mb-1">Producto</label>
                  <input
                    type="text"
                    value={nuevoPrecio.producto}
                    onChange={(e) => setNuevoPrecio({ ...nuevoPrecio, producto: e.target.value })}
                    className="w-full px-3 py-2 border rounded-lg"
                    required
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-1">Precio USD</label>
                    <input
                      type="number"
                      step="0.01"
                      value={nuevoPrecio.precio_usd}
                      onChange={(e) => setNuevoPrecio({ ...nuevoPrecio, precio_usd: parseFloat(e.target.value) })}
                      className="w-full px-3 py-2 border rounded-lg"
                      required
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium mb-1">Precio ₡</label>
                    <input
                      type="number"
                      step="0.01"
                      value={nuevoPrecio.precio_crc}
                      onChange={(e) => setNuevoPrecio({ ...nuevoPrecio, precio_crc: parseFloat(e.target.value) })}
                      className="w-full px-3 py-2 border rounded-lg"
                      required
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium mb-1">Cantidad</label>
                    <input
                      type="number"
                      step="0.01"
                      value={nuevoPrecio.cantidad}
                      onChange={(e) => setNuevoPrecio({ ...nuevoPrecio, cantidad: parseFloat(e.target.value) })}
                      className="w-full px-3 py-2 border rounded-lg"
                      required
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium mb-1">Unidad</label>
                    <select
                      value={nuevoPrecio.unidad_medida}
                      onChange={(e) => setNuevoPrecio({ ...nuevoPrecio, unidad_medida: e.target.value })}
                      className="w-full px-3 py-2 border rounded-lg"
                      required
                    >
                      <option value="mililitros">Mililitros</option>
                      <option value="litros">Litros</option>
                      <option value="gramos">Gramos</option>
                      <option value="kilogramos">Kilogramos</option>
                      <option value="unidades">Unidades</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-1">Notas (opcional)</label>
                  <textarea
                    value={nuevoPrecio.notas}
                    onChange={(e) => setNuevoPrecio({ ...nuevoPrecio, notas: e.target.value })}
                    className="w-full px-3 py-2 border rounded-lg"
                    rows={3}
                  />
                </div>

                <div className="flex justify-end gap-3 mt-6">
                  <button
                    type="button"
                    onClick={() => {
                      setShowModal(false)
                      setEditingId(null)
                      resetForm()
                    }}
                    className="px-4 py-2 border rounded-lg hover:bg-gray-50"
                  >
                    Cancelar
                  </button>
                  <button
                    type="submit"
                    className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
                  >
                    {editingId ? 'Actualizar' : 'Agregar'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
