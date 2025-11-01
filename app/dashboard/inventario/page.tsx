'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { Package, AlertCircle, TrendingUp, Edit2, Trash2, Plus, Save, X } from 'lucide-react'
import { formatCurrency } from '@/lib/utils'

export default function InventarioPage() {
  const [inventario, setInventario] = useState<any[]>([])
  const [presentaciones, setPresentaciones] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [filtro, setFiltro] = useState('')
  const [vistaActual, setVistaActual] = useState<'productos' | 'presentaciones'>('productos')
  
  // Modales
  const [showEditProductoModal, setShowEditProductoModal] = useState(false)
  const [showEditStockModal, setShowEditStockModal] = useState(false)
  const [showEditPresentacionModal, setShowEditPresentacionModal] = useState(false)
  
  // Estado de edición
  const [productoEdit, setProductoEdit] = useState<any>(null)
  const [presentacionEdit, setPresentacionEdit] = useState<any>(null)
  const [ajusteStock, setAjusteStock] = useState({ tipo: 'ajuste', cantidad: 0, notas: '' })

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      // Cargar inventario
      const { data: inventarioData, error: invError } = await supabase
        .from('inventario')
        .select(`
          *,
          productos (id, nombre, marca, unidad_medida, activo)
        `)
        .order('cantidad_disponible', { ascending: true })

      if (invError) throw invError
      if (inventarioData) setInventario(inventarioData)

      // Cargar presentaciones
      const { data: presData, error: presError } = await supabase
        .from('presentaciones')
        .select(`
          *,
          productos (nombre, marca, unidad_medida)
        `)
        .eq('activo', true)
        .order('nombre')

      if (presError) throw presError
      if (presData) setPresentaciones(presData)
    } catch (error) {
      console.error('Error cargando datos:', error)
    } finally {
      setLoading(false)
    }
  }

  const inventarioFiltrado = inventario.filter(item =>
    item.productos?.nombre.toLowerCase().includes(filtro.toLowerCase()) ||
    item.productos?.marca.toLowerCase().includes(filtro.toLowerCase())
  )

  const presentacionesFiltradas = presentaciones.filter(item =>
    item.nombre.toLowerCase().includes(filtro.toLowerCase()) ||
    item.productos?.nombre.toLowerCase().includes(filtro.toLowerCase())
  )

  const estadisticas = {
    totalProductos: inventario.length,
    stockBajo: inventario.filter(i => i.cantidad_disponible < 10).length,
    valorTotal: inventario.reduce((sum, i) => sum + (i.cantidad_disponible * i.costo_promedio_usd), 0)
  }

  const editarProducto = async () => {
    if (!productoEdit) return
    setLoading(true)
    try {
      const { error } = await supabase
        .from('productos')
        .update({
          nombre: productoEdit.nombre,
          marca: productoEdit.marca,
          unidad_medida: productoEdit.unidad_medida
        })
        .eq('id', productoEdit.id)

      if (error) throw error
      alert('Producto actualizado exitosamente')
      setShowEditProductoModal(false)
      loadData()
    } catch (error: any) {
      alert('Error al actualizar producto: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const ajustarStock = async () => {
    if (!productoEdit || ajusteStock.cantidad === 0) {
      alert('Ingrese una cantidad válida')
      return
    }

    setLoading(true)
    try {
      const { data: { user } } = await supabase.auth.getUser()
      const nuevaCantidad = productoEdit.cantidad_disponible + ajusteStock.cantidad

      if (nuevaCantidad < 0) {
        alert('El stock no puede ser negativo')
        return
      }

      // Actualizar inventario
      const { error: invError } = await supabase
        .from('inventario')
        .update({ cantidad_disponible: nuevaCantidad })
        .eq('producto_id', productoEdit.productos.id)

      if (invError) throw invError

      // Registrar movimiento
      const { error: movError } = await supabase
        .from('movimientos_inventario')
        .insert({
          producto_id: productoEdit.productos.id,
          tipo: 'ajuste',
          cantidad: Math.abs(ajusteStock.cantidad),
          referencia_tipo: 'ajuste_manual',
          notas: ajusteStock.notas || 'Ajuste manual de inventario',
          usuario_id: user?.id
        })

      if (movError) throw movError

      alert('Stock ajustado exitosamente')
      setShowEditStockModal(false)
      setAjusteStock({ tipo: 'ajuste', cantidad: 0, notas: '' })
      loadData()
    } catch (error: any) {
      alert('Error al ajustar stock: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const editarPresentacion = async () => {
    if (!presentacionEdit) return
    setLoading(true)
    try {
      const { error } = await supabase
        .from('presentaciones')
        .update({
          nombre: presentacionEdit.nombre,
          cantidad: presentacionEdit.cantidad,
          unidad: presentacionEdit.unidad,
          costo_envase: presentacionEdit.costo_envase,
          precio_venta_colones: presentacionEdit.precio_venta_colones
        })
        .eq('id', presentacionEdit.id)

      if (error) throw error
      alert('Presentación actualizada exitosamente')
      setShowEditPresentacionModal(false)
      loadData()
    } catch (error: any) {
      alert('Error al actualizar presentación: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const eliminarProducto = async (producto: any) => {
    // Verificar si el producto tiene ventas registradas
    const { data: ventas, error: ventasError } = await supabase
      .from('ventas_detalle')
      .select('id, presentaciones!inner(producto_id)')
      .eq('presentaciones.producto_id', producto.id)
      .limit(1)

    if (ventasError) {
      alert('Error al verificar ventas: ' + ventasError.message)
      return
    }

    if (ventas && ventas.length > 0) {
      if (!confirm(`Este producto tiene ventas registradas. No se puede eliminar, pero se puede desactivar. ¿Desea desactivarlo?`)) {
        return
      }
      
      // Desactivar en lugar de eliminar
      setLoading(true)
      try {
        const { error } = await supabase
          .from('productos')
          .update({ activo: false })
          .eq('id', producto.id)

        if (error) throw error
        alert('Producto desactivado exitosamente')
        loadData()
      } catch (error: any) {
        alert('Error al desactivar producto: ' + error.message)
      } finally {
        setLoading(false)
      }
    } else {
      // Si no tiene ventas, permitir eliminación completa
      if (!confirm(`¿Está seguro de eliminar el producto "${producto.nombre}"? Esto eliminará también todas sus presentaciones, inventario y movimientos relacionados.`)) {
        return
      }

      setLoading(true)
      try {
        // Primero eliminar movimientos de inventario (no tienen CASCADE)
        const { error: movError } = await supabase
          .from('movimientos_inventario')
          .delete()
          .eq('producto_id', producto.id)

        if (movError) throw movError

        // Ahora eliminar el producto (CASCADE eliminará inventario y presentaciones)
        const { error } = await supabase
          .from('productos')
          .delete()
          .eq('id', producto.id)

        if (error) throw error
        alert('Producto eliminado exitosamente')
        loadData()
      } catch (error: any) {
        alert('Error al eliminar producto: ' + error.message)
      } finally {
        setLoading(false)
      }
    }
  }

  const eliminarPresentacion = async (presentacion: any) => {
    // Verificar si la presentación tiene ventas registradas
    const { data: ventas, error: ventasError } = await supabase
      .from('ventas_detalle')
      .select('id')
      .eq('presentacion_id', presentacion.id)
      .limit(1)

    if (ventasError) {
      alert('Error al verificar ventas: ' + ventasError.message)
      return
    }

    if (ventas && ventas.length > 0) {
      if (!confirm(`Esta presentación tiene ventas registradas. No se puede eliminar, pero se puede desactivar. ¿Desea desactivarla?`)) {
        return
      }
      
      // Desactivar en lugar de eliminar
      setLoading(true)
      try {
        const { error } = await supabase
          .from('presentaciones')
          .update({ activo: false })
          .eq('id', presentacion.id)

        if (error) throw error
        alert('Presentación desactivada exitosamente')
        loadData()
      } catch (error: any) {
        alert('Error al desactivar presentación: ' + error.message)
      } finally {
        setLoading(false)
      }
    } else {
      // Si no tiene ventas, permitir eliminación completa
      if (!confirm(`¿Está seguro de eliminar la presentación "${presentacion.nombre}"?`)) {
        return
      }

      setLoading(true)
      try {
        const { error } = await supabase
          .from('presentaciones')
          .delete()
          .eq('id', presentacion.id)

        if (error) throw error
        alert('Presentación eliminada exitosamente')
        loadData()
      } catch (error: any) {
        alert('Error al eliminar presentación: ' + error.message)
      } finally {
        setLoading(false)
      }
    }
  }

  if (loading && inventario.length === 0) {
    return <div className="flex items-center justify-center h-64">
      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
    </div>
  }

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Inventario</h1>
        <p className="text-gray-600 mt-2">Seguimiento y gestión de stock</p>
      </div>

      {/* Estadísticas */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div className="card bg-gradient-to-br from-blue-500 to-blue-600 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-blue-100 text-sm">Total Productos</p>
              <p className="text-3xl font-bold mt-2">{estadisticas.totalProductos}</p>
            </div>
            <Package size={48} className="opacity-80" />
          </div>
        </div>

        <div className="card bg-gradient-to-br from-red-500 to-red-600 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-red-100 text-sm">Stock Bajo (&lt;10)</p>
              <p className="text-3xl font-bold mt-2">{estadisticas.stockBajo}</p>
            </div>
            <AlertCircle size={48} className="opacity-80" />
          </div>
        </div>

        <div className="card bg-gradient-to-br from-green-500 to-green-600 text-white">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-green-100 text-sm">Valor Total (USD)</p>
              <p className="text-3xl font-bold mt-2">{formatCurrency(estadisticas.valorTotal, 'USD')}</p>
            </div>
            <TrendingUp size={48} className="opacity-80" />
          </div>
        </div>
      </div>

      {/* Tabs */}
      <div className="mb-6 flex gap-2">
        <button
          onClick={() => setVistaActual('productos')}
          className={`px-6 py-2 rounded-lg font-medium transition-colors ${
            vistaActual === 'productos'
              ? 'bg-primary-600 text-white'
              : 'bg-white text-gray-700 hover:bg-gray-50'
          }`}
        >
          Productos e Inventario
        </button>
        <button
          onClick={() => setVistaActual('presentaciones')}
          className={`px-6 py-2 rounded-lg font-medium transition-colors ${
            vistaActual === 'presentaciones'
              ? 'bg-primary-600 text-white'
              : 'bg-white text-gray-700 hover:bg-gray-50'
          }`}
        >
          Presentaciones
        </button>
      </div>

      {/* Filtro */}
      <div className="card mb-6">
        <input
          type="text"
          placeholder="Buscar..."
          value={filtro}
          onChange={(e) => setFiltro(e.target.value)}
          className="input"
        />
      </div>

      {/* Vista de Productos */}
      {vistaActual === 'productos' && (
        <div className="card">
          <h2 className="text-xl font-semibold mb-4">Stock Disponible</h2>
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>Producto</th>
                  <th>Marca</th>
                  <th>Cantidad</th>
                  <th>Unidad</th>
                  <th>Costo Promedio</th>
                  <th>Valor Total</th>
                  <th>Estado</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                {inventarioFiltrado.map((item) => (
                  <tr key={item.id}>
                    <td className="font-medium">{item.productos?.nombre}</td>
                    <td>{item.productos?.marca}</td>
                    <td className="font-semibold">{item.cantidad_disponible.toFixed(2)}</td>
                    <td>{item.productos?.unidad_medida}</td>
                    <td>{formatCurrency(item.costo_promedio_usd, 'USD')}</td>
                    <td className="font-semibold">
                      {formatCurrency(item.cantidad_disponible * item.costo_promedio_usd, 'USD')}
                    </td>
                    <td>
                      {item.cantidad_disponible < 10 ? (
                        <span className="px-2 py-1 rounded text-xs font-medium bg-red-100 text-red-800 flex items-center gap-1 w-fit">
                          <AlertCircle size={14} />
                          Bajo
                        </span>
                      ) : item.cantidad_disponible < 50 ? (
                        <span className="px-2 py-1 rounded text-xs font-medium bg-yellow-100 text-yellow-800">
                          Medio
                        </span>
                      ) : (
                        <span className="px-2 py-1 rounded text-xs font-medium bg-green-100 text-green-800">
                          Óptimo
                        </span>
                      )}
                    </td>
                    <td>
                      <div className="flex gap-2">
                        <button
                          onClick={() => {
                            setProductoEdit({
                              ...item.productos,
                              cantidad_disponible: item.cantidad_disponible
                            })
                            setShowEditProductoModal(true)
                          }}
                          className="p-2 text-blue-600 hover:bg-blue-50 rounded"
                          title="Editar producto"
                        >
                          <Edit2 size={16} />
                        </button>
                        <button
                          onClick={() => {
                            setProductoEdit(item)
                            setShowEditStockModal(true)
                          }}
                          className="p-2 text-green-600 hover:bg-green-50 rounded"
                          title="Ajustar stock"
                        >
                          <Package size={16} />
                        </button>
                        <button
                          onClick={() => eliminarProducto(item.productos)}
                          className="p-2 text-red-600 hover:bg-red-50 rounded"
                          title="Eliminar producto"
                        >
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
                {inventarioFiltrado.length === 0 && (
                  <tr>
                    <td colSpan={8} className="text-center text-gray-500 py-8">
                      {filtro ? 'No se encontraron productos' : 'No hay productos en inventario'}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Vista de Presentaciones */}
      {vistaActual === 'presentaciones' && (
        <div className="card">
          <h2 className="text-xl font-semibold mb-4">Presentaciones Disponibles</h2>
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  <th>Producto</th>
                  <th>Presentación</th>
                  <th>Cantidad</th>
                  <th>Costo Envase</th>
                  <th>Precio Venta (₡)</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                {presentacionesFiltradas.map((pres) => (
                  <tr key={pres.id}>
                    <td className="font-medium">
                      {pres.productos?.nombre} - {pres.productos?.marca}
                    </td>
                    <td>{pres.nombre}</td>
                    <td>
                      {pres.cantidad} {pres.unidad}
                    </td>
                    <td>{formatCurrency(pres.costo_envase, 'USD')}</td>
                    <td className="font-semibold">
                      {formatCurrency(pres.precio_venta_colones, 'CRC')}
                    </td>
                    <td>
                      <div className="flex gap-2">
                        <button
                          onClick={() => {
                            setPresentacionEdit(pres)
                            setShowEditPresentacionModal(true)
                          }}
                          className="p-2 text-blue-600 hover:bg-blue-50 rounded"
                          title="Editar presentación"
                        >
                          <Edit2 size={16} />
                        </button>
                        <button
                          onClick={() => eliminarPresentacion(pres)}
                          className="p-2 text-red-600 hover:bg-red-50 rounded"
                          title="Eliminar presentación"
                        >
                          <Trash2 size={16} />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
                {presentacionesFiltradas.length === 0 && (
                  <tr>
                    <td colSpan={6} className="text-center text-gray-500 py-8">
                      {filtro ? 'No se encontraron presentaciones' : 'No hay presentaciones registradas'}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Modal: Editar Producto */}
      {showEditProductoModal && productoEdit && (
        <div className="modal-overlay">
          <div className="modal-content">
            <div className="modal-header">
              <h2 className="text-2xl font-bold">Editar Producto</h2>
              <button onClick={() => setShowEditProductoModal(false)} className="text-gray-500 hover:text-gray-700">
                <X size={24} />
              </button>
            </div>

            <div className="modal-body">
              <div className="form-group">
                <label>Nombre del Producto</label>
                <input
                  type="text"
                  value={productoEdit.nombre}
                  onChange={(e) => setProductoEdit({ ...productoEdit, nombre: e.target.value })}
                  className="input"
                />
              </div>

              <div className="form-group">
                <label>Marca</label>
                <input
                  type="text"
                  value={productoEdit.marca}
                  onChange={(e) => setProductoEdit({ ...productoEdit, marca: e.target.value })}
                  className="input"
                />
              </div>

              <div className="form-group">
                <label>Unidad de Medida</label>
                <select
                  value={productoEdit.unidad_medida}
                  onChange={(e) => setProductoEdit({ ...productoEdit, unidad_medida: e.target.value })}
                  className="input"
                >
                  <option value="litros">Litros</option>
                  <option value="gramos">Gramos</option>
                  <option value="unidades">Unidades</option>
                  <option value="kilogramos">Kilogramos</option>
                  <option value="mililitros">Mililitros</option>
                </select>
              </div>
            </div>

            <div className="modal-footer">
              <button onClick={() => setShowEditProductoModal(false)} className="btn-secondary">
                Cancelar
              </button>
              <button onClick={editarProducto} className="btn-primary" disabled={loading}>
                <Save size={20} />
                {loading ? 'Guardando...' : 'Guardar Cambios'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal: Ajustar Stock */}
      {showEditStockModal && productoEdit && (
        <div className="modal-overlay">
          <div className="modal-content">
            <div className="modal-header">
              <h2 className="text-2xl font-bold">Ajustar Stock</h2>
              <button onClick={() => setShowEditStockModal(false)} className="text-gray-500 hover:text-gray-700">
                <X size={24} />
              </button>
            </div>

            <div className="modal-body">
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-4">
                <p className="text-sm text-blue-900">
                  <strong>Producto:</strong> {productoEdit.productos?.nombre}
                </p>
                <p className="text-sm text-blue-900">
                  <strong>Stock actual:</strong> {productoEdit.cantidad_disponible.toFixed(2)} {productoEdit.productos?.unidad_medida}
                </p>
                <p className="text-sm text-blue-900">
                  <strong>Nuevo stock:</strong> {(productoEdit.cantidad_disponible + ajusteStock.cantidad).toFixed(2)} {productoEdit.productos?.unidad_medida}
                </p>
              </div>

              <div className="form-group">
                <label>Cantidad a Ajustar (positivo para agregar, negativo para quitar)</label>
                <input
                  type="number"
                  step="0.01"
                  value={ajusteStock.cantidad}
                  onChange={(e) => setAjusteStock({ ...ajusteStock, cantidad: parseFloat(e.target.value) || 0 })}
                  className="input"
                  placeholder="Ej: 10 o -5"
                />
              </div>

              <div className="form-group">
                <label>Notas (opcional)</label>
                <textarea
                  value={ajusteStock.notas}
                  onChange={(e) => setAjusteStock({ ...ajusteStock, notas: e.target.value })}
                  className="input"
                  rows={3}
                  placeholder="Razón del ajuste..."
                />
              </div>
            </div>

            <div className="modal-footer">
              <button onClick={() => setShowEditStockModal(false)} className="btn-secondary">
                Cancelar
              </button>
              <button onClick={ajustarStock} className="btn-primary" disabled={loading}>
                <Save size={20} />
                {loading ? 'Guardando...' : 'Ajustar Stock'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal: Editar Presentación */}
      {showEditPresentacionModal && presentacionEdit && (
        <div className="modal-overlay">
          <div className="modal-content">
            <div className="modal-header">
              <h2 className="text-2xl font-bold">Editar Presentación</h2>
              <button onClick={() => setShowEditPresentacionModal(false)} className="text-gray-500 hover:text-gray-700">
                <X size={24} />
              </button>
            </div>

            <div className="modal-body">
              <div className="form-group">
                <label>Nombre de la Presentación</label>
                <input
                  type="text"
                  value={presentacionEdit.nombre}
                  onChange={(e) => setPresentacionEdit({ ...presentacionEdit, nombre: e.target.value })}
                  className="input"
                  placeholder="Ej: 1 litro, 500g"
                />
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="form-group">
                  <label>Cantidad</label>
                  <input
                    type="number"
                    step="0.01"
                    value={presentacionEdit.cantidad}
                    onChange={(e) => setPresentacionEdit({ ...presentacionEdit, cantidad: parseFloat(e.target.value) || 0 })}
                    className="input"
                  />
                </div>

                <div className="form-group">
                  <label>Unidad</label>
                  <select
                    value={presentacionEdit.unidad}
                    onChange={(e) => setPresentacionEdit({ ...presentacionEdit, unidad: e.target.value })}
                    className="input"
                  >
                    <option value="litros">Litros</option>
                    <option value="gramos">Gramos</option>
                    <option value="unidades">Unidades</option>
                    <option value="kilogramos">Kilogramos</option>
                    <option value="mililitros">Mililitros</option>
                  </select>
                </div>
              </div>

              <div className="form-group">
                <label>Costo del Envase (USD)</label>
                <input
                  type="number"
                  step="0.01"
                  value={presentacionEdit.costo_envase}
                  onChange={(e) => setPresentacionEdit({ ...presentacionEdit, costo_envase: parseFloat(e.target.value) || 0 })}
                  className="input"
                />
              </div>

              <div className="form-group">
                <label>Precio de Venta (Colones)</label>
                <input
                  type="number"
                  step="0.01"
                  value={presentacionEdit.precio_venta_colones}
                  onChange={(e) => setPresentacionEdit({ ...presentacionEdit, precio_venta_colones: parseFloat(e.target.value) || 0 })}
                  className="input"
                />
              </div>
            </div>

            <div className="modal-footer">
              <button onClick={() => setShowEditPresentacionModal(false)} className="btn-secondary">
                Cancelar
              </button>
              <button onClick={editarPresentacion} className="btn-primary" disabled={loading}>
                <Save size={20} />
                {loading ? 'Guardando...' : 'Guardar Cambios'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
