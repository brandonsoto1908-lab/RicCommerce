'use client'

import { useEffect, useState } from 'react'
import { supabase, Gasto } from '@/lib/supabase'
import { Plus, Trash2, Edit, X } from 'lucide-react'
import { formatCurrency, formatDateShort } from '@/lib/utils'

export default function GastosPage() {
  const [gastos, setGastos] = useState<Gasto[]>([])
  const [loading, setLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [nuevoGasto, setNuevoGasto] = useState({
    tipo: 'unico' as 'unico' | 'utilitario',
    categoria: '',
    descripcion: '',
    monto_usd: 0,
    fecha: new Date().toISOString().split('T')[0],
    periodicidad: ''
  })

  useEffect(() => {
    loadGastos()
  }, [])

  const loadGastos = async () => {
    try {
      const { data, error } = await supabase
        .from('gastos')
        .select('*')
        .eq('activo', true)
        .order('fecha', { ascending: false })

      if (error) throw error
      if (data) setGastos(data)
    } catch (error) {
      console.error('Error cargando gastos:', error)
    } finally {
      setLoading(false)
    }
  }

  const guardarGasto = async () => {
    if (!nuevoGasto.categoria || !nuevoGasto.descripcion || nuevoGasto.monto_usd <= 0) {
      alert('Complete todos los campos requeridos')
      return
    }

    setLoading(true)
    try {
      const { data: { user } } = await supabase.auth.getUser()

      const { error } = await supabase
        .from('gastos')
        .insert([{ ...nuevoGasto, usuario_id: user?.id }])

      if (error) throw error

      alert('Gasto registrado exitosamente')
      setShowModal(false)
      setNuevoGasto({
        tipo: 'unico',
        categoria: '',
        descripcion: '',
        monto_usd: 0,
        fecha: new Date().toISOString().split('T')[0],
        periodicidad: ''
      })
      loadGastos()
    } catch (error: any) {
      alert('Error al guardar: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const eliminarGasto = async (id: string) => {
    if (!confirm('¿Eliminar este gasto?')) return

    try {
      const { error } = await supabase
        .from('gastos')
        .update({ activo: false })
        .eq('id', id)

      if (error) throw error
      loadGastos()
    } catch (error: any) {
      alert('Error al eliminar: ' + error.message)
    }
  }

  const calcularTotales = () => {
    const unicos = gastos.filter(g => g.tipo === 'unico').reduce((sum, g) => sum + g.monto_usd, 0)
    const utilitarios = gastos.filter(g => g.tipo === 'utilitario').reduce((sum, g) => sum + g.monto_usd, 0)
    return { unicos, utilitarios, total: unicos + utilitarios }
  }

  const totales = calcularTotales()

  if (loading && gastos.length === 0) {
    return <div className="flex items-center justify-center h-64">
      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
    </div>
  }

  return (
    <div>
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Gastos</h1>
          <p className="text-gray-600 mt-2">Gestión de gastos únicos y utilitarios</p>
        </div>
        <button onClick={() => setShowModal(true)} className="btn btn-primary flex items-center gap-2">
          <Plus size={20} />
          Nuevo Gasto
        </button>
      </div>

      {/* Resumen de totales */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div className="card bg-gradient-to-br from-blue-500 to-blue-600 text-white">
          <p className="text-blue-100 text-sm">Gastos Únicos</p>
          <p className="text-3xl font-bold mt-2">{formatCurrency(totales.unicos, 'USD')}</p>
        </div>
        <div className="card bg-gradient-to-br from-purple-500 to-purple-600 text-white">
          <p className="text-purple-100 text-sm">Gastos Utilitarios</p>
          <p className="text-3xl font-bold mt-2">{formatCurrency(totales.utilitarios, 'USD')}</p>
        </div>
        <div className="card bg-gradient-to-br from-green-500 to-green-600 text-white">
          <p className="text-green-100 text-sm">Total</p>
          <p className="text-3xl font-bold mt-2">{formatCurrency(totales.total, 'USD')}</p>
        </div>
      </div>

      {/* Tabla de gastos */}
      <div className="card">
        <h2 className="text-xl font-semibold mb-4">Historial de Gastos</h2>
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>Fecha</th>
                <th>Tipo</th>
                <th>Categoría</th>
                <th>Descripción</th>
                <th>Monto (USD)</th>
                <th>Periodicidad</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {gastos.map((gasto) => (
                <tr key={gasto.id}>
                  <td>{formatDateShort(gasto.fecha)}</td>
                  <td>
                    <span className={`px-2 py-1 rounded text-xs font-medium ${
                      gasto.tipo === 'unico' ? 'bg-blue-100 text-blue-800' : 'bg-purple-100 text-purple-800'
                    }`}>
                      {gasto.tipo === 'unico' ? 'Único' : 'Utilitario'}
                    </span>
                  </td>
                  <td>{gasto.categoria}</td>
                  <td className="max-w-xs truncate">{gasto.descripcion}</td>
                  <td className="font-semibold">{formatCurrency(gasto.monto_usd, 'USD')}</td>
                  <td>{gasto.periodicidad || '-'}</td>
                  <td>
                    <button onClick={() => eliminarGasto(gasto.id)} className="text-red-600 hover:text-red-800">
                      <Trash2 size={18} />
                    </button>
                  </td>
                </tr>
              ))}
              {gastos.length === 0 && (
                <tr>
                  <td colSpan={7} className="text-center text-gray-500 py-8">
                    No hay gastos registrados
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal Nuevo Gasto */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-2xl w-full p-6">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold">Nuevo Gasto</h2>
              <button onClick={() => setShowModal(false)} className="text-gray-500 hover:text-gray-700">
                <X size={24} />
              </button>
            </div>

            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Tipo de Gasto</label>
                  <select
                    value={nuevoGasto.tipo}
                    onChange={(e) => setNuevoGasto({ ...nuevoGasto, tipo: e.target.value as 'unico' | 'utilitario' })}
                    className="input"
                  >
                    <option value="unico">Único</option>
                    <option value="utilitario">Utilitario</option>
                  </select>
                </div>
                <div>
                  <label className="label">Categoría</label>
                  <input
                    type="text"
                    value={nuevoGasto.categoria}
                    onChange={(e) => setNuevoGasto({ ...nuevoGasto, categoria: e.target.value })}
                    className="input"
                    placeholder="Ej: Luz, Agua, Otros"
                  />
                </div>
              </div>

              <div>
                <label className="label">Descripción</label>
                <textarea
                  value={nuevoGasto.descripcion}
                  onChange={(e) => setNuevoGasto({ ...nuevoGasto, descripcion: e.target.value })}
                  className="input"
                  rows={3}
                  placeholder="Descripción del gasto"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div>
                  <label className="label">Monto (USD)</label>
                  <input
                    type="number"
                    value={nuevoGasto.monto_usd || ''}
                    onChange={(e) => setNuevoGasto({ ...nuevoGasto, monto_usd: parseFloat(e.target.value) || 0 })}
                    className="input"
                    min="0"
                    step="0.01"
                  />
                </div>
                <div>
                  <label className="label">Fecha</label>
                  <input
                    type="date"
                    value={nuevoGasto.fecha}
                    onChange={(e) => setNuevoGasto({ ...nuevoGasto, fecha: e.target.value })}
                    className="input"
                  />
                </div>
              </div>

              {nuevoGasto.tipo === 'utilitario' && (
                <div>
                  <label className="label">Periodicidad</label>
                  <select
                    value={nuevoGasto.periodicidad}
                    onChange={(e) => setNuevoGasto({ ...nuevoGasto, periodicidad: e.target.value })}
                    className="input"
                  >
                    <option value="">Seleccione...</option>
                    <option value="semanal">Semanal</option>
                    <option value="quincenal">Quincenal</option>
                    <option value="mensual">Mensual</option>
                    <option value="anual">Anual</option>
                  </select>
                </div>
              )}
            </div>

            <div className="flex gap-3 mt-6">
              <button onClick={() => setShowModal(false)} className="btn btn-secondary flex-1">
                Cancelar
              </button>
              <button onClick={guardarGasto} disabled={loading} className="btn btn-primary flex-1">
                Guardar Gasto
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
