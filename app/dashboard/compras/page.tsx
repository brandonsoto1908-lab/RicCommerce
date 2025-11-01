'use client'

import { useEffect, useState } from 'react'
import { supabase, Producto, Compra, CompraDetalle } from '@/lib/supabase'
import { Plus, Trash2, Save, Edit, X } from 'lucide-react'
import { formatCurrency, formatDateShort } from '@/lib/utils'

interface ProductoCompra {
  producto_id: string
  producto_nombre: string
  producto_marca: string
  cantidad: number
  precio_unitario_usd: number
  subtotal_usd: number
}

export default function ComprasPage() {
  const [productos, setProductos] = useState<Producto[]>([])
  const [compras, setCompras] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [showNewProductModal, setShowNewProductModal] = useState(false)
  
  // Estado para nueva compra
  const [fecha, setFecha] = useState(new Date().toISOString().split('T')[0])
  const [notas, setNotas] = useState('')
  const [productosCompra, setProductosCompra] = useState<ProductoCompra[]>([])
  
  // Estado para nuevo producto
  const [nuevoProducto, setNuevoProducto] = useState({
    nombre: '',
    marca: '',
    descripcion: '',
    unidad_medida: 'litros'
  })

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      // Cargar productos
      const { data: productosData } = await supabase
        .from('productos')
        .select('*')
        .eq('activo', true)
        .order('nombre')

      if (productosData) setProductos(productosData)

      // Cargar compras con detalles
      const { data: comprasData } = await supabase
        .from('compras')
        .select(`
          *,
          compras_detalle (
            *,
            productos (nombre, marca)
          )
        `)
        .order('fecha', { ascending: false })
        .limit(20)

      if (comprasData) setCompras(comprasData)
    } catch (error) {
      console.error('Error cargando datos:', error)
    } finally {
      setLoading(false)
    }
  }

  const agregarProductoCompra = () => {
    setProductosCompra([
      ...productosCompra,
      {
        producto_id: '',
        producto_nombre: '',
        producto_marca: '',
        cantidad: 0,
        precio_unitario_usd: 0,
        subtotal_usd: 0,
      },
    ])
  }

  const actualizarProductoCompra = (index: number, field: string, value: any) => {
    const nuevosProductos = [...productosCompra]
    
    if (field === 'producto_id') {
      const producto = productos.find(p => p.id === value)
      if (producto) {
        nuevosProductos[index].producto_id = value
        nuevosProductos[index].producto_nombre = producto.nombre
        nuevosProductos[index].producto_marca = producto.marca
      }
    } else if (field === 'subtotal_usd' || field === 'cantidad') {
      // Actualizar el campo
      (nuevosProductos[index] as any)[field] = value
      
      // Calcular precio unitario automáticamente si tenemos cantidad y subtotal
      const cantidad = field === 'cantidad' ? value : nuevosProductos[index].cantidad
      const subtotal = field === 'subtotal_usd' ? value : nuevosProductos[index].subtotal_usd
      
      if (cantidad > 0 && subtotal > 0) {
        nuevosProductos[index].precio_unitario_usd = subtotal / cantidad
      }
    } else {
      (nuevosProductos[index] as any)[field] = value
    }
    
    // Calcular subtotal si se actualizó precio unitario o cantidad manualmente
    if (field === 'precio_unitario_usd' || (field === 'cantidad' && !nuevosProductos[index].subtotal_usd)) {
      const cantidad = nuevosProductos[index].cantidad
      const precio = nuevosProductos[index].precio_unitario_usd
      nuevosProductos[index].subtotal_usd = cantidad * precio
    }
    
    setProductosCompra(nuevosProductos)
  }

  const eliminarProductoCompra = (index: number) => {
    setProductosCompra(productosCompra.filter((_, i) => i !== index))
  }

  const calcularTotal = () => {
    return productosCompra.reduce((sum, p) => sum + p.subtotal_usd, 0)
  }

  const guardarCompra = async () => {
    if (productosCompra.length === 0) {
      alert('Debe agregar al menos un producto')
      return
    }

    if (productosCompra.some(p => !p.producto_id || p.cantidad <= 0 || p.precio_unitario_usd <= 0)) {
      alert('Complete todos los datos de los productos')
      return
    }

    setLoading(true)
    try {
      const { data: { user } } = await supabase.auth.getUser()

      // Insertar compra
      const { data: compra, error: compraError } = await supabase
        .from('compras')
        .insert([
          {
            fecha,
            total_usd: calcularTotal(),
            notas,
            usuario_id: user?.id,
          },
        ])
        .select()
        .single()

      if (compraError) throw compraError

      // Insertar detalles de compra
      const detalles = productosCompra.map(p => ({
        compra_id: compra.id,
        producto_id: p.producto_id,
        cantidad: p.cantidad,
        precio_unitario_usd: p.precio_unitario_usd,
        subtotal_usd: p.subtotal_usd,
      }))

      const { error: detallesError } = await supabase
        .from('compras_detalle')
        .insert(detalles)

      if (detallesError) throw detallesError

      alert('Compra registrada exitosamente')
      setShowModal(false)
      setProductosCompra([])
      setNotas('')
      loadData()
    } catch (error: any) {
      console.error('Error guardando compra:', error)
      alert('Error al guardar compra: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const crearProducto = async () => {
    if (!nuevoProducto.nombre || !nuevoProducto.marca) {
      alert('Complete nombre y marca del producto')
      return
    }

    setLoading(true)
    try {
      const { data, error } = await supabase
        .from('productos')
        .insert([nuevoProducto])
        .select()
        .single()

      if (error) throw error

      alert('Producto creado exitosamente')
      setShowNewProductModal(false)
      setNuevoProducto({
        nombre: '',
        marca: '',
        descripcion: '',
        unidad_medida: 'litros'
      })
      loadData()
    } catch (error: any) {
      console.error('Error creando producto:', error)
      alert('Error al crear producto: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const eliminarCompra = async (id: string) => {
    if (!confirm('¿Está seguro de eliminar esta compra?\n\nEsta acción revertirá el inventario automáticamente.')) return

    setLoading(true)
    try {
      const { data: { user } } = await supabase.auth.getUser()
      
      // Obtener los detalles de la compra
      const { data: detalles, error: detallesError } = await supabase
        .from('compras_detalle')
        .select('*')
        .eq('compra_id', id)

      if (detallesError) throw detallesError

      // Revertir inventario por cada detalle (quitar el stock que se agregó)
      if (detalles) {
        for (const detalle of detalles) {
          // Obtener inventario actual
          const { data: invActual, error: invError } = await supabase
            .from('inventario')
            .select('cantidad_disponible, costo_promedio_usd')
            .eq('producto_id', detalle.producto_id)
            .single()

          if (invError) throw invError

          const nuevaCantidad = invActual.cantidad_disponible - detalle.cantidad

          if (nuevaCantidad < 0) {
            alert(`No se puede eliminar: El producto ya fue vendido y no hay suficiente stock.`)
            setLoading(false)
            return
          }

          // Actualizar inventario (restar lo que se había sumado)
          const { error: updateError } = await supabase
            .from('inventario')
            .update({ 
              cantidad_disponible: nuevaCantidad
            })
            .eq('producto_id', detalle.producto_id)

          if (updateError) throw updateError

          // Registrar movimiento de ajuste
          await supabase
            .from('movimientos_inventario')
            .insert({
              producto_id: detalle.producto_id,
              tipo: 'ajuste',
              cantidad: detalle.cantidad,
              referencia_tipo: 'eliminacion_compra',
              referencia_id: id,
              notas: `Reversión de compra eliminada`,
              usuario_id: user?.id
            })
        }
      }

      // Ahora eliminar la compra (CASCADE eliminará los detalles)
      const { error } = await supabase
        .from('compras')
        .delete()
        .eq('id', id)

      if (error) throw error

      alert('Compra eliminada exitosamente. El inventario ha sido revertido.')
      loadData()
    } catch (error: any) {
      alert('Error al eliminar: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  if (loading && compras.length === 0) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  return (
    <div>
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Compras</h1>
          <p className="text-gray-600 mt-2">Gestión de compras y entradas de inventario</p>
        </div>
        <div className="flex gap-3">
          <button
            onClick={() => setShowNewProductModal(true)}
            className="btn btn-secondary flex items-center gap-2"
          >
            <Plus size={20} />
            Nuevo Producto
          </button>
          <button
            onClick={() => setShowModal(true)}
            className="btn btn-primary flex items-center gap-2"
          >
            <Plus size={20} />
            Nueva Compra
          </button>
        </div>
      </div>

      {/* Lista de compras */}
      <div className="card">
        <h2 className="text-xl font-semibold mb-4">Historial de Compras</h2>
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>Fecha</th>
                <th>Total (USD)</th>
                <th>Productos</th>
                <th>Notas</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {compras.map((compra) => (
                <tr key={compra.id}>
                  <td>{formatDateShort(compra.fecha)}</td>
                  <td className="font-semibold">{formatCurrency(compra.total_usd, 'USD')}</td>
                  <td>{compra.compras_detalle?.length || 0} producto(s)</td>
                  <td className="max-w-xs truncate">{compra.notas || '-'}</td>
                  <td>
                    <button
                      onClick={() => eliminarCompra(compra.id)}
                      className="text-red-600 hover:text-red-800"
                    >
                      <Trash2 size={18} />
                    </button>
                  </td>
                </tr>
              ))}
              {compras.length === 0 && (
                <tr>
                  <td colSpan={5} className="text-center text-gray-500 py-8">
                    No hay compras registradas
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal Nueva Compra */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-4xl w-full max-h-[90vh] overflow-y-auto p-6">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold">Nueva Compra</h2>
              <button
                onClick={() => setShowModal(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                <X size={24} />
              </button>
            </div>

            <div className="mb-6 grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="label">Fecha</label>
                <input
                  type="date"
                  value={fecha}
                  onChange={(e) => setFecha(e.target.value)}
                  className="input"
                />
              </div>
              <div>
                <label className="label">Notas</label>
                <input
                  type="text"
                  value={notas}
                  onChange={(e) => setNotas(e.target.value)}
                  className="input"
                  placeholder="Observaciones de la compra"
                />
              </div>
            </div>

            <div className="mb-6">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold">Productos</h3>
                <button
                  onClick={agregarProductoCompra}
                  className="btn btn-secondary flex items-center gap-2 text-sm"
                >
                  <Plus size={16} />
                  Agregar Producto
                </button>
              </div>

              {productosCompra.map((producto, index) => (
                <div key={index} className="grid grid-cols-1 md:grid-cols-6 gap-3 mb-3 p-4 bg-gray-50 rounded-lg">
                  <div className="md:col-span-2">
                    <label className="label text-xs">Producto</label>
                    <select
                      value={producto.producto_id}
                      onChange={(e) => actualizarProductoCompra(index, 'producto_id', e.target.value)}
                      className="input text-sm"
                    >
                      <option value="">Seleccione...</option>
                      {productos.map((p) => (
                        <option key={p.id} value={p.id}>
                          {p.nombre} - {p.marca}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="label text-xs">Cantidad</label>
                    <input
                      type="number"
                      value={producto.cantidad || ''}
                      onChange={(e) => actualizarProductoCompra(index, 'cantidad', parseFloat(e.target.value) || 0)}
                      className="input text-sm"
                      min="0"
                      step="0.01"
                      placeholder="Ej: 1000"
                    />
                  </div>
                  <div>
                    <label className="label text-xs">Total Compra (USD)</label>
                    <input
                      type="number"
                      value={producto.subtotal_usd || ''}
                      onChange={(e) => actualizarProductoCompra(index, 'subtotal_usd', parseFloat(e.target.value) || 0)}
                      className="input text-sm"
                      min="0"
                      step="0.01"
                      placeholder="Ej: 570"
                    />
                  </div>
                  <div>
                    <label className="label text-xs">Precio Unit. (USD)</label>
                    <input
                      type="text"
                      value={producto.precio_unitario_usd > 0 ? formatCurrency(producto.precio_unitario_usd, 'USD') : '$0.00'}
                      className="input text-sm bg-gray-100 font-semibold"
                      disabled
                      title="Calculado automáticamente"
                    />
                  </div>
                  <div className="flex items-end">
                    <button
                      onClick={() => eliminarProductoCompra(index)}
                      className="btn btn-danger w-full"
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>
                </div>
              ))}

              {productosCompra.length === 0 && (
                <div className="text-center py-8 text-gray-500">
                  No hay productos agregados
                </div>
              )}
            </div>

            <div className="border-t pt-4 flex justify-between items-center">
              <div className="text-xl font-bold">
                Total: {formatCurrency(calcularTotal(), 'USD')}
              </div>
              <div className="flex gap-3">
                <button
                  onClick={() => setShowModal(false)}
                  className="btn btn-secondary"
                >
                  Cancelar
                </button>
                <button
                  onClick={guardarCompra}
                  disabled={loading}
                  className="btn btn-primary flex items-center gap-2"
                >
                  <Save size={20} />
                  Guardar Compra
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Modal Nuevo Producto */}
      {showNewProductModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold">Nuevo Producto</h2>
              <button
                onClick={() => setShowNewProductModal(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                <X size={24} />
              </button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="label">Nombre del Producto</label>
                <input
                  type="text"
                  value={nuevoProducto.nombre}
                  onChange={(e) => setNuevoProducto({ ...nuevoProducto, nombre: e.target.value })}
                  className="input"
                  placeholder="Ej: Cloro"
                />
              </div>

              <div>
                <label className="label">Marca</label>
                <input
                  type="text"
                  value={nuevoProducto.marca}
                  onChange={(e) => setNuevoProducto({ ...nuevoProducto, marca: e.target.value })}
                  className="input"
                  placeholder="Ej: Clorox"
                />
              </div>

              <div>
                <label className="label">Descripción (opcional)</label>
                <textarea
                  value={nuevoProducto.descripcion}
                  onChange={(e) => setNuevoProducto({ ...nuevoProducto, descripcion: e.target.value })}
                  className="input"
                  rows={3}
                  placeholder="Descripción del producto"
                />
              </div>

              <div>
                <label className="label">Unidad de Medida</label>
                <select
                  value={nuevoProducto.unidad_medida}
                  onChange={(e) => setNuevoProducto({ ...nuevoProducto, unidad_medida: e.target.value })}
                  className="input"
                >
                  <option value="litros">Litros</option>
                  <option value="gramos">Gramos</option>
                  <option value="kilogramos">Kilogramos</option>
                  <option value="unidades">Unidades</option>
                </select>
              </div>
            </div>

            <div className="flex gap-3 mt-6">
              <button
                onClick={() => setShowNewProductModal(false)}
                className="btn btn-secondary flex-1"
              >
                Cancelar
              </button>
              <button
                onClick={crearProducto}
                disabled={loading}
                className="btn btn-primary flex-1"
              >
                Crear Producto
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
