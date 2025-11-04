'use client'

import { useEffect, useState } from 'react'
import { supabase, Producto, Presentacion } from '@/lib/supabase'
import { Plus, Trash2, Save, X } from 'lucide-react'
import { formatCurrency, calcularMargen, formatDateShort } from '@/lib/utils'
import { getCombinedExchangeRate } from '@/lib/exchangeRate'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'

interface ProductoVenta {
  presentacion_id: string
  nombre_presentacion: string
  cantidad: number
  precio_unitario_colones: number
  subtotal_colones: number
  costo_unitario_usd: number
  margen_porcentaje: number
}

export default function VentasPage() {
  const [presentaciones, setPresentaciones] = useState<any[]>([])
  const [ventas, setVentas] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [showPresentacionModal, setShowPresentacionModal] = useState(false)
  const [tasaCambio, setTasaCambio] = useState(520)
  
  // Estado para nueva venta
  const [fecha, setFecha] = useState(new Date().toISOString().split('T')[0])
  const [notas, setNotas] = useState('')
  const [productosVenta, setProductosVenta] = useState<ProductoVenta[]>([])
  
  // Estado para nueva presentación
  const [productos, setProductos] = useState<Producto[]>([])
  const [gastosUtilitarios, setGastosUtilitarios] = useState(0)
  const [inventarioTotalLitros, setInventarioTotalLitros] = useState(0)
  const [costoPorLitroOverhead, setCostoPorLitroOverhead] = useState(0)
  const [nuevaPresentacion, setNuevaPresentacion] = useState({
    producto_id: '',
    nombre: '',
    cantidad: 0,
    unidad: 'litros',
    costo_envase: 0,
    precio_venta_colones: 0,
    margen_objetivo: 30, // Margen objetivo por defecto
    incluir_gastos_utilitarios: true // Por defecto incluir gastos
  })
  const [margenPreview, setMargenPreview] = useState({ margenPorcentaje: 0, margenColones: 0, margenDolares: 0 })

  useEffect(() => {
    loadData()
    loadTasaCambio()
  }, [])

  useEffect(() => {
    if (nuevaPresentacion.producto_id && nuevaPresentacion.precio_venta_colones > 0) {
      calcularMargenPreview()
    }
  }, [nuevaPresentacion, tasaCambio])

  const loadTasaCambio = async () => {
    const result = await getCombinedExchangeRate()
    setTasaCambio(result.rate)
  }

  const loadData = async () => {
    try {
      // Obtener el usuario actual
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) {
        console.error('Usuario no autenticado')
        return
      }

      // Cargar presentaciones con productos
      const { data: presentacionesData, error: presentacionesError } = await supabase
        .from('presentaciones')
        .select(`
          *,
          productos!inner (
            id,
            nombre,
            marca,
            unidad_medida
          )
        `)
        .eq('activo', true)
        .order('nombre')

      if (presentacionesError) {
        console.error('Error cargando presentaciones:', presentacionesError)
      }
      
      // Cargar inventario para cada producto
      if (presentacionesData) {
        const presentacionesConInventario = await Promise.all(
          presentacionesData.map(async (pres) => {
            const { data: inventarioData } = await supabase
              .from('inventario')
              .select('cantidad_disponible, costo_promedio_usd')
              .eq('producto_id', pres.producto_id)
              .eq('usuario_id', user.id)
              .single()
            
            return {
              ...pres,
              productos: {
                ...pres.productos,
                inventario: inventarioData ? [inventarioData] : []
              }
            }
          })
        )
        
        console.log('✅ Presentaciones cargadas con inventario:', presentacionesConInventario)
        setPresentaciones(presentacionesConInventario)
      }

      // Cargar productos
      const { data: productosData } = await supabase
        .from('productos')
        .select('*')
        .eq('activo', true)
        .order('nombre')

      if (productosData) setProductos(productosData)

      // Cargar gastos utilitarios activos (mensuales)
      const { data: gastosData } = await supabase
        .from('gastos')
        .select('monto_usd')
        .eq('tipo', 'utilitario')
        .eq('activo', true)

      const totalGastosUtilitarios = gastosData?.reduce((sum, g) => sum + g.monto_usd, 0) || 0
      setGastosUtilitarios(totalGastosUtilitarios)

      // Calcular inventario total en litros (para prorrateo)
      const { data: inventarioData } = await supabase
        .from('inventario')
        .select(`
          cantidad_disponible,
          productos!inner (
            unidad_medida
          )
        `)

      let totalLitros = 0
      inventarioData?.forEach((inv: any) => {
        const cantidad = inv.cantidad_disponible
        const unidad = inv.productos.unidad_medida
        
        // Convertir todo a litros para el cálculo
        if (unidad === 'litros') {
          totalLitros += cantidad
        } else if (unidad === 'mililitros') {
          totalLitros += cantidad / 1000
        }
        // Solo consideramos productos líquidos para el prorrateo
      })

      setInventarioTotalLitros(totalLitros)
      
      // Calcular costo por litro de overhead
      const costoOverhead = totalLitros > 0 ? totalGastosUtilitarios / totalLitros : 0
      setCostoPorLitroOverhead(costoOverhead)

      console.log('💡 Cálculo de overhead:', {
        gastosUtilitarios: totalGastosUtilitarios,
        inventarioTotalLitros: totalLitros,
        costoPorLitro: costoOverhead
      })

      // Cargar ventas recientes
      const { data: ventasData } = await supabase
        .from('ventas')
        .select(`
          *,
          ventas_detalle (
            *,
            presentaciones (
              nombre,
              productos (nombre, marca)
            )
          )
        `)
        .order('fecha', { ascending: false })
        .limit(20)

      if (ventasData) setVentas(ventasData)
    } catch (error) {
      console.error('Error cargando datos:', error)
    } finally {
      setLoading(false)
    }
  }

  // Función para convertir unidades a la unidad base del producto
  const convertirUnidades = (cantidad: number, unidadOrigen: string, unidadDestino: string): number => {
    // Si las unidades son iguales, no hay conversión
    if (unidadOrigen === unidadDestino) return cantidad
    
    // Conversiones de volumen
    if (unidadOrigen === 'mililitros' && unidadDestino === 'litros') return cantidad / 1000
    if (unidadOrigen === 'litros' && unidadDestino === 'mililitros') return cantidad * 1000
    
    // Conversiones de peso
    if (unidadOrigen === 'gramos' && unidadDestino === 'kilogramos') return cantidad / 1000
    if (unidadOrigen === 'kilogramos' && unidadDestino === 'gramos') return cantidad * 1000
    
    // Si no hay conversión definida, devolver cantidad original
    return cantidad
  }

  const calcularMargenPreview = async () => {
    const producto = productos.find((p: Producto) => p.id === nuevaPresentacion.producto_id)
    if (!producto) return

    const { data: inventarioData } = await supabase
      .from('inventario')
      .select('costo_promedio_usd')
      .eq('producto_id', nuevaPresentacion.producto_id)
      .single()

    // Convertir la cantidad de la presentación a la unidad base del producto
    const cantidadEnUnidadBase = convertirUnidades(
      nuevaPresentacion.cantidad,
      nuevaPresentacion.unidad,
      producto.unidad_medida
    )
    
    const costoUnitarioUSD = (inventarioData?.costo_promedio_usd || 0) * cantidadEnUnidadBase
    const margen = calcularMargen(
      costoUnitarioUSD,
      nuevaPresentacion.precio_venta_colones,
      tasaCambio,
      nuevaPresentacion.costo_envase
    )
    
    setMargenPreview(margen)
  }

  const calcularPrecioRecomendado = async () => {
    const producto = productos.find((p: Producto) => p.id === nuevaPresentacion.producto_id)
    if (!producto || !nuevaPresentacion.cantidad || !nuevaPresentacion.margen_objetivo) {
      return
    }

    const { data: inventarioData } = await supabase
      .from('inventario')
      .select('costo_promedio_usd')
      .eq('producto_id', nuevaPresentacion.producto_id)
      .single()

    const costoProductoUSD = inventarioData?.costo_promedio_usd || 0
    
    // VALIDACIÓN: Verificar si el producto tiene costo en inventario
    if (costoProductoUSD === 0) {
      alert(`⚠️ ERROR: El producto "${producto.nombre}" no tiene costo registrado en el inventario.\n\n` +
            `Esto ocurre porque:\n` +
            `• No se ha registrado ninguna compra de este producto\n` +
            `• El inventario está vacío (cantidad = 0)\n\n` +
            `SOLUCIÓN:\n` +
            `1. Ve al módulo de COMPRAS\n` +
            `2. Registra una compra del producto con su costo\n` +
            `3. Vuelve aquí y usa "Calcular Precio"\n\n` +
            `No se puede calcular un precio de venta sin conocer el costo del producto.`)
      return
    }
    
    // Convertir la cantidad de la presentación a la unidad base del producto
    const cantidadEnUnidadBase = convertirUnidades(
      nuevaPresentacion.cantidad,
      nuevaPresentacion.unidad,
      producto.unidad_medida
    )
    
    // Calcular costo de gastos utilitarios si está habilitado
    let costoGastosUtilitarios = 0
    if (nuevaPresentacion.incluir_gastos_utilitarios && costoPorLitroOverhead > 0) {
      // Convertir la cantidad a litros para el cálculo de overhead
      const cantidadEnLitros = convertirUnidades(
        nuevaPresentacion.cantidad,
        nuevaPresentacion.unidad,
        'litros'
      )
      costoGastosUtilitarios = costoPorLitroOverhead * cantidadEnLitros
    }
    
    console.log('🔢 Conversión de unidades:', {
      cantidadPresentacion: nuevaPresentacion.cantidad,
      unidadPresentacion: nuevaPresentacion.unidad,
      unidadProducto: producto.unidad_medida,
      cantidadConvertida: cantidadEnUnidadBase,
      costoUnitario: costoProductoUSD,
      costoProducto: costoProductoUSD * cantidadEnUnidadBase,
      costoEnvase: nuevaPresentacion.costo_envase || 0,
      costoGastosUtilitarios: costoGastosUtilitarios,
      costoTotal: (costoProductoUSD * cantidadEnUnidadBase) + (nuevaPresentacion.costo_envase || 0) + costoGastosUtilitarios
    })
    
    const costoProductoTotal = costoProductoUSD * cantidadEnUnidadBase
    const costoTotalUSD = costoProductoTotal + (nuevaPresentacion.costo_envase || 0) + costoGastosUtilitarios
    
    // Fórmula: Precio = Costo Total * (1 + Margen/100)
    const precioVentaUSD = costoTotalUSD * (1 + nuevaPresentacion.margen_objetivo / 100)
    const precioVentaColones = precioVentaUSD * tasaCambio
    
    setNuevaPresentacion({
      ...nuevaPresentacion,
      precio_venta_colones: Math.ceil(precioVentaColones / 5) * 5 // Redondear a múltiplo de 5
    })
  }

  const agregarProductoVenta = () => {
    setProductosVenta([
      ...productosVenta,
      {
        presentacion_id: '',
        nombre_presentacion: '',
        cantidad: 0,
        precio_unitario_colones: 0,
        subtotal_colones: 0,
        costo_unitario_usd: 0,
        margen_porcentaje: 0,
      },
    ])
  }

  const actualizarProductoVenta = async (index: number, field: string, value: any) => {
    const nuevosProductos = [...productosVenta]
    
    if (field === 'presentacion_id') {
      const presentacion = presentaciones.find((p: any) => p.id === value)
      if (presentacion) {
        // 🔍 Consultar inventario DIRECTAMENTE desde la base de datos
        const { data: inventarioData, error: inventarioError } = await supabase
          .from('inventario')
          .select('cantidad_disponible, costo_promedio_usd')
          .eq('producto_id', presentacion.producto_id)
          .maybeSingle()
        
        if (inventarioError) {
          console.error('❌ Error consultando inventario:', inventarioError)
        }
        
        console.log('📦 PRESENTACIÓN SELECCIONADA:', {
          nombre: presentacion.nombre,
          cantidad: presentacion.cantidad,
          producto_id: presentacion.producto_id,
          inventarioConsultado: inventarioData
        })
        
        nuevosProductos[index].presentacion_id = value
        nuevosProductos[index].nombre_presentacion = `${presentacion.productos.nombre} - ${presentacion.nombre}`
        nuevosProductos[index].precio_unitario_colones = presentacion.precio_venta_colones
        
        // Calcular costo UNITARIO (por cada presentación) en USD
        const costoProductoUSD = inventarioData?.costo_promedio_usd || 0
        
        // Convertir la cantidad de la presentación a la unidad base del producto
        const cantidadEnUnidadBase = convertirUnidades(
          presentacion.cantidad,
          presentacion.unidad,
          presentacion.productos.unidad_medida
        )
        
        const costoEnvaseUSD = presentacion.costo_envase || 0
        
        // VALIDACIÓN: Verificar si el producto tiene costo en inventario
        if (costoProductoUSD === 0) {
          alert(`⚠️ ADVERTENCIA: El producto "${presentacion.productos.nombre} - ${presentacion.productos.marca}" no tiene costo registrado en el inventario.\n\n` +
                `Esto puede ocurrir porque:\n` +
                `1. No se ha registrado ninguna compra de este producto específico\n` +
                `2. El inventario tiene cantidad 0\n\n` +
                `Por favor, ve al módulo de COMPRAS y registra una compra del producto "${presentacion.productos.nombre} - ${presentacion.productos.marca}"\n` +
                `antes de usar esta presentación en una venta.\n\n` +
                `Sin el costo correcto, el margen de ganancia será incorrecto.`)
        }
        
        // Costo de UNA presentación
        const costoUnitarioUSD = (costoProductoUSD * cantidadEnUnidadBase) + costoEnvaseUSD
        
        nuevosProductos[index].costo_unitario_usd = costoUnitarioUSD
        
        // Calcular margen por UNIDAD de presentación
        const precioVentaUSD = presentacion.precio_venta_colones / tasaCambio
        
        // Margen = (Precio - Costo) / Costo * 100
        const margenPorcentaje = costoUnitarioUSD > 0
          ? ((precioVentaUSD - costoUnitarioUSD) / costoUnitarioUSD) * 100
          : 0
        
        nuevosProductos[index].margen_porcentaje = margenPorcentaje
        
        // Debug: mostrar cálculos en consola
        console.log('🔍 Cálculo de margen:', {
          presentacion: presentacion.nombre,
          cantidad: presentacion.cantidad,
          unidadPresentacion: presentacion.unidad,
          unidadProducto: presentacion.productos.unidad_medida,
          cantidadConvertida: cantidadEnUnidadBase,
          costoProductoPorUnidadBase: costoProductoUSD,
          costoEnvaseUSD,
          costoUnitarioUSD: costoUnitarioUSD.toFixed(4),
          precioVentaColones: presentacion.precio_venta_colones,
          precioVentaUSD: precioVentaUSD.toFixed(4),
          tasaCambio,
          margenCalculado: margenPorcentaje.toFixed(2) + '%',
          nota: 'Este margen es por UNIDAD de presentación, no cambia con la cantidad vendida'
        })
      }
    } else {
      (nuevosProductos[index] as any)[field] = value
    }
    
    // Calcular subtotal (precio × cantidad de unidades vendidas)
    const cantidad = nuevosProductos[index].cantidad
    const precio = nuevosProductos[index].precio_unitario_colones
    nuevosProductos[index].subtotal_colones = cantidad * precio
    
    setProductosVenta(nuevosProductos)
  }

  const eliminarProductoVenta = (index: number) => {
    setProductosVenta(productosVenta.filter((_, i) => i !== index))
  }

  const calcularTotal = () => {
    return productosVenta.reduce((sum, p) => sum + p.subtotal_colones, 0)
  }

  const guardarVenta = async () => {
    if (productosVenta.length === 0) {
      alert('Debe agregar al menos un producto')
      return
    }

    if (productosVenta.some(p => !p.presentacion_id || p.cantidad <= 0)) {
      alert('Complete todos los datos de los productos')
      return
    }

    setLoading(true)
    try {
      const { data: { user } } = await supabase.auth.getUser()
      const totalColones = calcularTotal()
      const totalUSD = totalColones / tasaCambio

      // Insertar venta
      const { data: venta, error: ventaError } = await supabase
        .from('ventas')
        .insert([
          {
            fecha,
            total_colones: totalColones,
            total_usd: totalUSD,
            tasa_cambio: tasaCambio,
            notas,
            usuario_id: user?.id,
          },
        ])
        .select()
        .single()

      if (ventaError) throw ventaError

      // Insertar detalles de venta
      const detalles = productosVenta.map(p => ({
        venta_id: venta.id,
        presentacion_id: p.presentacion_id,
        cantidad: p.cantidad,
        precio_unitario_colones: p.precio_unitario_colones,
        subtotal_colones: p.subtotal_colones,
        costo_unitario_usd: p.costo_unitario_usd,
        margen_porcentaje: p.margen_porcentaje,
      }))

      const { error: detallesError } = await supabase
        .from('ventas_detalle')
        .insert(detalles)

      if (detallesError) throw detallesError

      alert('Venta registrada exitosamente')
      setShowModal(false)
      setProductosVenta([])
      setNotas('')
      loadData()
    } catch (error: any) {
      console.error('Error guardando venta:', error)
      alert('Error al guardar venta: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const crearPresentacion = async () => {
    if (!nuevaPresentacion.producto_id || !nuevaPresentacion.nombre || nuevaPresentacion.precio_venta_colones <= 0) {
      alert('Complete todos los campos requeridos')
      return
    }

    setLoading(true)
    try {
      // Obtener usuario actual
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) {
        alert('Error: Usuario no autenticado')
        return
      }

      // Extraer solo los campos que existen en la tabla presentaciones
      const { margen_objetivo, incluir_gastos_utilitarios, ...presentacionData } = nuevaPresentacion
      
      const { data, error } = await supabase
        .from('presentaciones')
        .insert([{
          ...presentacionData,
          usuario_id: user.id
        }])
        .select()
        .single()

      if (error) throw error

      alert('Presentación creada exitosamente')
      setShowPresentacionModal(false)
      setNuevaPresentacion({
        producto_id: '',
        nombre: '',
        cantidad: 0,
        unidad: 'litros',
        costo_envase: 0,
        precio_venta_colones: 0,
        margen_objetivo: 30,
        incluir_gastos_utilitarios: true
      })
      loadData()
    } catch (error: any) {
      console.error('Error creando presentación:', error)
      alert('Error al crear presentación: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  const eliminarVenta = async (venta: any) => {
    if (!confirm(`¿Está seguro de eliminar la venta del ${formatDateShort(venta.fecha)} por ${formatCurrency(venta.total_colones, 'CRC')}?\n\nEsta acción revertirá el inventario automáticamente.`)) {
      return
    }

    setLoading(true)
    try {
      const { data: { user } } = await supabase.auth.getUser()
      
      // Primero obtenemos los detalles de la venta
      const { data: detalles, error: detallesError } = await supabase
        .from('ventas_detalle')
        .select(`
          *,
          presentaciones (
            producto_id,
            cantidad
          )
        `)
        .eq('venta_id', venta.id)

      if (detallesError) throw detallesError

      // Revertir inventario por cada detalle (devolver el stock)
      if (detalles) {
        for (const detalle of detalles) {
          const cantidadTotal = detalle.presentaciones.cantidad * detalle.cantidad
          const productoId = detalle.presentaciones.producto_id
          
          // Obtener inventario actual
          const { data: invActual, error: invError } = await supabase
            .from('inventario')
            .select('cantidad_disponible')
            .eq('producto_id', productoId)
            .single()

          if (invError) throw invError

          // Actualizar inventario (sumar de vuelta)
          const { error: updateError } = await supabase
            .from('inventario')
            .update({ 
              cantidad_disponible: invActual.cantidad_disponible + cantidadTotal 
            })
            .eq('producto_id', productoId)

          if (updateError) throw updateError

          // Registrar movimiento de ajuste
          await supabase
            .from('movimientos_inventario')
            .insert({
              producto_id: productoId,
              tipo: 'ajuste',
              cantidad: cantidadTotal,
              referencia_tipo: 'eliminacion_venta',
              referencia_id: venta.id,
              notas: `Reversión de venta eliminada del ${formatDateShort(venta.fecha)}`,
              usuario_id: user?.id
            })
        }
      }

      // Ahora eliminar la venta (CASCADE eliminará los detalles automáticamente)
      const { error: deleteError } = await supabase
        .from('ventas')
        .delete()
        .eq('id', venta.id)

      if (deleteError) throw deleteError

      alert('Venta eliminada exitosamente. El inventario ha sido revertido.')
      loadData()
    } catch (error: any) {
      console.error('Error eliminando venta:', error)
      alert('Error al eliminar venta: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  if (loading && ventas.length === 0) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
      </div>
    )
  }

  // Datos para el gráfico de margen
  const datosGrafico = [
    { precio: 0, margen: 0 },
    { precio: nuevaPresentacion.precio_venta_colones * 0.5, margen: calcularMargen((productos.find((p: Producto) => p.id === nuevaPresentacion.producto_id) ? 1 : 0), nuevaPresentacion.precio_venta_colones * 0.5, tasaCambio).margenPorcentaje },
    { precio: nuevaPresentacion.precio_venta_colones, margen: margenPreview.margenPorcentaje },
    { precio: nuevaPresentacion.precio_venta_colones * 1.5, margen: calcularMargen((productos.find((p: Producto) => p.id === nuevaPresentacion.producto_id) ? 1 : 0), nuevaPresentacion.precio_venta_colones * 1.5, tasaCambio).margenPorcentaje },
  ]

  return (
    <div>
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Ventas</h1>
          <p className="text-gray-600 mt-2">Gestión de ventas y salidas de inventario</p>
        </div>
        <div className="flex gap-3">
          <button
            onClick={() => setShowPresentacionModal(true)}
            className="btn btn-secondary flex items-center gap-2"
          >
            <Plus size={20} />
            Nueva Presentación
          </button>
          <button
            onClick={() => setShowModal(true)}
            className="btn btn-primary flex items-center gap-2"
          >
            <Plus size={20} />
            Nueva Venta
          </button>
        </div>
      </div>

      <div className="mb-6 card">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600">Tasa de Cambio USD → CRC</p>
            <p className="text-2xl font-bold text-primary-600">₡{tasaCambio.toFixed(2)}</p>
          </div>
          <button
            onClick={loadTasaCambio}
            className="btn btn-secondary text-sm"
          >
            Actualizar Tasa
          </button>
        </div>
      </div>

      {/* Lista de Presentaciones Disponibles */}
      <div className="card mb-6">
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
                <th>Margen %</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {presentaciones.map((presentacion: any) => {
                // Calcular el margen de cada presentación
                const producto = presentacion.productos
                const inventario = producto?.inventario?.[0]
                const costoPromedioUSD = inventario?.costo_promedio_usd || 0
                
                // Convertir la cantidad de la presentación a la unidad base del producto
                const cantidadEnUnidadBase = convertirUnidades(
                  presentacion.cantidad,
                  presentacion.unidad,
                  producto?.unidad_medida || 'unidades'
                )
                
                // Calcular costo del producto en esta presentación
                const costoProductoUSD = cantidadEnUnidadBase * costoPromedioUSD
                const costoProductoCRC = costoProductoUSD * tasaCambio
                const costoEnvaseUSD = presentacion.costo_envase || 0
                const costoEnvaseCRC = costoEnvaseUSD * tasaCambio
                const costoTotalCRC = costoProductoCRC + costoEnvaseCRC
                
                // Calcular margen
                const precioVentaCRC = presentacion.precio_venta_colones || 0
                const margenCRC = precioVentaCRC - costoTotalCRC
                const margenPorcentaje = costoTotalCRC > 0 ? (margenCRC / costoTotalCRC) * 100 : 0

                return (
                  <tr key={presentacion.id}>
                    <td>{producto?.nombre || 'N/A'} {producto?.marca ? `- ${producto.marca}` : ''}</td>
                    <td className="font-semibold">{presentacion.nombre}</td>
                    <td>{presentacion.cantidad} {presentacion.unidad}</td>
                    <td>{formatCurrency(presentacion.costo_envase || 0, 'USD')}</td>
                    <td className="font-bold">{formatCurrency(presentacion.precio_venta_colones || 0, 'CRC')}</td>
                    <td>
                      <span 
                        className={`px-3 py-1 rounded-full text-sm font-bold ${
                          margenPorcentaje >= 30 ? 'bg-green-100 text-green-800' :
                          margenPorcentaje >= 15 ? 'bg-yellow-100 text-yellow-800' :
                          'bg-red-100 text-red-800'
                        }`}
                      >
                        {margenPorcentaje.toFixed(1)}%
                      </span>
                    </td>
                    <td>
                      <button
                        onClick={() => {
                          // Aquí puedes agregar función para editar presentación
                          alert('Función de edición en desarrollo')
                        }}
                        className="p-2 text-blue-600 hover:bg-blue-50 rounded"
                        title="Editar presentación"
                      >
                        <Save size={18} />
                      </button>
                    </td>
                  </tr>
                )
              })}
              {presentaciones.length === 0 && (
                <tr>
                  <td colSpan={7} className="text-center text-gray-500 py-8">
                    No hay presentaciones disponibles. Crea una nueva presentación para comenzar.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Lista de ventas */}
      <div className="card">
        <h2 className="text-xl font-semibold mb-4">Historial de Ventas</h2>
        <div className="table-container">
          <table className="table">
            <thead>
              <tr>
                <th>Fecha</th>
                <th>Total (₡)</th>
                <th>Total (USD)</th>
                <th>Productos</th>
                <th>Margen Promedio</th>
                <th>Notas</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {ventas.map((venta) => {
                // Calcular margen promedio de la venta
                const margenPromedio = venta.ventas_detalle?.length > 0
                  ? venta.ventas_detalle.reduce((sum: number, det: any) => sum + (det.margen_porcentaje || 0), 0) / venta.ventas_detalle.length
                  : 0

                return (
                  <tr key={venta.id}>
                    <td>{formatDateShort(venta.fecha)}</td>
                    <td className="font-semibold">{formatCurrency(venta.total_colones, 'CRC')}</td>
                    <td>{formatCurrency(venta.total_usd, 'USD')}</td>
                    <td>{venta.ventas_detalle?.length || 0} producto(s)</td>
                    <td>
                      <span 
                        className={`px-2 py-1 rounded text-xs font-bold cursor-help ${
                          margenPromedio >= 30 ? 'bg-green-100 text-green-800' :
                          margenPromedio >= 15 ? 'bg-yellow-100 text-yellow-800' :
                          'bg-red-100 text-red-800'
                        }`}
                        title={venta.ventas_detalle?.map((det: any) => 
                          `${det.presentaciones?.nombre || 'Producto'}: ${(det.margen_porcentaje || 0).toFixed(2)}%`
                        ).join('\n')}
                      >
                        {margenPromedio.toFixed(1)}%
                      </span>
                    </td>
                    <td className="max-w-xs truncate">{venta.notas || '-'}</td>
                    <td>
                      <button
                        onClick={() => eliminarVenta(venta)}
                        className="p-2 text-red-600 hover:bg-red-50 rounded"
                        title="Eliminar venta"
                      >
                        <Trash2 size={16} />
                      </button>
                    </td>
                  </tr>
                )
              })}
              {ventas.length === 0 && (
                <tr>
                  <td colSpan={7} className="text-center text-gray-500 py-8">
                    No hay ventas registradas
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal Nueva Venta */}
      {showModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4 overflow-y-auto">
          <div className="bg-white rounded-lg max-w-5xl w-full max-h-[90vh] overflow-y-auto p-6 my-8">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold">Nueva Venta</h2>
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
                  placeholder="Observaciones de la venta"
                />
              </div>
            </div>

            <div className="mb-6">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold">Productos</h3>
                <button
                  onClick={agregarProductoVenta}
                  className="btn btn-secondary flex items-center gap-2 text-sm"
                >
                  <Plus size={16} />
                  Agregar Producto
                </button>
              </div>

              {productosVenta.map((producto, index) => (
                <div key={index} className="grid grid-cols-1 md:grid-cols-7 gap-3 mb-3 p-4 bg-gray-50 rounded-lg">
                  <div className="md:col-span-2">
                    <label className="label text-xs">Presentación</label>
                    <select
                      value={producto.presentacion_id}
                      onChange={(e) => actualizarProductoVenta(index, 'presentacion_id', e.target.value)}
                      className="input text-sm"
                    >
                      <option value="">Seleccione...</option>
                      {presentaciones.map((p: any) => (
                        <option key={p.id} value={p.id}>
                          {p.productos.nombre} - {p.nombre}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div>
                    <label className="label text-xs">Cantidad</label>
                    <input
                      type="number"
                      value={producto.cantidad || ''}
                      onChange={(e) => actualizarProductoVenta(index, 'cantidad', parseInt(e.target.value) || 0)}
                      className="input text-sm"
                      min="1"
                    />
                  </div>
                  <div>
                    <label className="label text-xs">Precio Unit. (₡)</label>
                    <input
                      type="text"
                      value={formatCurrency(producto.precio_unitario_colones, 'CRC')}
                      className="input text-sm bg-gray-100"
                      disabled
                    />
                  </div>
                  <div>
                    <label className="label text-xs">Subtotal (₡)</label>
                    <input
                      type="text"
                      value={formatCurrency(producto.subtotal_colones, 'CRC')}
                      className="input text-sm bg-gray-100"
                      disabled
                    />
                  </div>
                  <div>
                    <label className="label text-xs">Margen %</label>
                    <input
                      type="text"
                      value={`${producto.margen_porcentaje.toFixed(1)}%`}
                      className={`input text-sm font-bold ${
                        producto.margen_porcentaje < 15 ? 'bg-red-100' : 
                        producto.margen_porcentaje < 30 ? 'bg-yellow-100' : 
                        'bg-green-100'
                      }`}
                      disabled
                    />
                  </div>
                  <div className="flex items-end">
                    <button
                      onClick={() => eliminarProductoVenta(index)}
                      className="btn btn-danger w-full"
                    >
                      <Trash2 size={16} />
                    </button>
                  </div>
                </div>
              ))}

              {productosVenta.length === 0 && (
                <div className="text-center py-8 text-gray-500">
                  No hay productos agregados
                </div>
              )}
            </div>

            <div className="border-t pt-4 flex justify-between items-center">
              <div className="text-xl font-bold">
                Total: {formatCurrency(calcularTotal(), 'CRC')}
              </div>
              <div className="flex gap-3">
                <button
                  onClick={() => setShowModal(false)}
                  className="btn btn-secondary"
                >
                  Cancelar
                </button>
                <button
                  onClick={guardarVenta}
                  disabled={loading}
                  className="btn btn-primary flex items-center gap-2"
                >
                  <Save size={20} />
                  Guardar Venta
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Modal Nueva Presentación */}
      {showPresentacionModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4 overflow-y-auto">
          <div className="bg-white rounded-lg max-w-4xl w-full max-h-[90vh] overflow-y-auto p-6 my-8">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-bold">Nueva Presentación</h2>
              <button
                onClick={() => setShowPresentacionModal(false)}
                className="text-gray-500 hover:text-gray-700"
              >
                <X size={24} />
              </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="space-y-4">
                <div>
                  <label className="label">Producto</label>
                  <select
                    value={nuevaPresentacion.producto_id}
                    onChange={(e) => setNuevaPresentacion({ ...nuevaPresentacion, producto_id: e.target.value })}
                    className="input"
                  >
                    <option value="">Seleccione un producto...</option>
                    {productos.map((p) => (
                      <option key={p.id} value={p.id}>
                        {p.nombre} - {p.marca}
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="label">Nombre de Presentación</label>
                  <input
                    type="text"
                    value={nuevaPresentacion.nombre}
                    onChange={(e) => setNuevaPresentacion({ ...nuevaPresentacion, nombre: e.target.value })}
                    className="input"
                    placeholder="Ej: 1 litro, 500ml, etc."
                  />
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="label">Cantidad</label>
                    <input
                      type="number"
                      value={nuevaPresentacion.cantidad || ''}
                      onChange={(e) => setNuevaPresentacion({ ...nuevaPresentacion, cantidad: parseFloat(e.target.value) || 0 })}
                      className="input"
                      min="0"
                      step="0.01"
                    />
                  </div>
                  <div>
                    <label className="label">Unidad</label>
                    <select
                      value={nuevaPresentacion.unidad}
                      onChange={(e) => setNuevaPresentacion({ ...nuevaPresentacion, unidad: e.target.value })}
                      className="input"
                    >
                      <option value="litros">Litros</option>
                      <option value="mililitros">Mililitros</option>
                      <option value="gramos">Gramos</option>
                      <option value="kilogramos">Kilogramos</option>
                      <option value="unidades">Unidades</option>
                    </select>
                  </div>
                </div>

                <div>
                  <label className="label">Costo del Envase (USD)</label>
                  <input
                    type="number"
                    value={nuevaPresentacion.costo_envase || ''}
                    onChange={(e) => setNuevaPresentacion({ ...nuevaPresentacion, costo_envase: parseFloat(e.target.value) || 0 })}
                    className="input"
                    min="0"
                    step="0.01"
                  />
                </div>

                {/* Checkbox para incluir gastos utilitarios */}
                <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
                  <label className="flex items-start gap-3 cursor-pointer">
                    <input
                      type="checkbox"
                      checked={nuevaPresentacion.incluir_gastos_utilitarios}
                      onChange={(e) => setNuevaPresentacion({ ...nuevaPresentacion, incluir_gastos_utilitarios: e.target.checked })}
                      className="checkbox mt-1"
                    />
                    <div>
                      <div className="font-semibold text-yellow-900">Incluir Gastos Utilitarios</div>
                      <div className="text-sm text-yellow-700 mt-1">
                        {gastosUtilitarios > 0 ? (
                          <>
                            Se prorrateará <span className="font-bold">{formatCurrency(gastosUtilitarios, 'USD')}</span> de gastos 
                            (luz, agua, etc.) entre <span className="font-bold">{inventarioTotalLitros.toFixed(2)}L</span> de inventario total.
                            <br />
                            <span className="text-xs">Costo adicional: ~{formatCurrency(costoPorLitroOverhead, 'USD')}/litro</span>
                          </>
                        ) : (
                          <span className="text-yellow-600">No hay gastos utilitarios registrados</span>
                        )}
                      </div>
                    </div>
                  </label>
                </div>

                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                  <label className="label text-blue-900 mb-2">Margen Objetivo (%)</label>
                  <div className="flex gap-2">
                    <input
                      type="number"
                      value={nuevaPresentacion.margen_objetivo || ''}
                      onChange={(e) => setNuevaPresentacion({ ...nuevaPresentacion, margen_objetivo: parseFloat(e.target.value) || 0 })}
                      className="input flex-1"
                      min="0"
                      step="1"
                      placeholder="Ej: 30"
                    />
                    <button
                      onClick={calcularPrecioRecomendado}
                      className="btn btn-primary whitespace-nowrap"
                      disabled={!nuevaPresentacion.producto_id || !nuevaPresentacion.cantidad}
                      title="Calcular precio recomendado según margen objetivo"
                    >
                      Calcular Precio
                    </button>
                  </div>
                  <p className="text-xs text-blue-700 mt-2">
                    💡 Ingresa el margen que deseas obtener y el sistema calculará el precio de venta recomendado
                  </p>
                </div>

                <div>
                  <label className="label">Precio de Venta (₡)</label>
                  <input
                    type="number"
                    value={nuevaPresentacion.precio_venta_colones || ''}
                    onChange={(e) => setNuevaPresentacion({ ...nuevaPresentacion, precio_venta_colones: parseFloat(e.target.value) || 0 })}
                    className="input"
                    min="0"
                    step="0.01"
                  />
                  <p className="text-xs text-gray-500 mt-1">
                    Puedes editarlo manualmente o usar el botón "Calcular Precio"
                  </p>
                </div>
              </div>

              <div className="space-y-4">
                <div className="card bg-gradient-to-br from-primary-50 to-primary-100">
                  <h3 className="text-lg font-semibold mb-4">Margen de Ganancia</h3>
                  <div className="space-y-3">
                    <div className="flex justify-between items-center">
                      <span className="text-gray-700">Margen %:</span>
                      <span className={`text-2xl font-bold ${
                        margenPreview.margenPorcentaje < 15 ? 'text-red-600' : 
                        margenPreview.margenPorcentaje < 30 ? 'text-yellow-600' : 
                        'text-green-600'
                      }`}>
                        {margenPreview.margenPorcentaje.toFixed(2)}%
                      </span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-gray-700">Margen (₡):</span>
                      <span className="text-xl font-semibold">
                        {formatCurrency(margenPreview.margenColones, 'CRC')}
                      </span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-gray-700">Margen (USD):</span>
                      <span className="text-xl font-semibold">
                        {formatCurrency(margenPreview.margenDolares, 'USD')}
                      </span>
                    </div>
                  </div>
                </div>

                <div className="card">
                  <h3 className="text-sm font-semibold mb-2">Gráfico de Margen</h3>
                  <ResponsiveContainer width="100%" height={200}>
                    <LineChart data={datosGrafico}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis dataKey="precio" label={{ value: 'Precio (₡)', position: 'insideBottom', offset: -5 }} />
                      <YAxis label={{ value: 'Margen %', angle: -90, position: 'insideLeft' }} />
                      <Tooltip />
                      <Line type="monotone" dataKey="margen" stroke="#0ea5e9" strokeWidth={2} />
                    </LineChart>
                  </ResponsiveContainer>
                </div>
              </div>
            </div>

            <div className="flex gap-3 mt-6">
              <button
                onClick={() => setShowPresentacionModal(false)}
                className="btn btn-secondary flex-1"
              >
                Cancelar
              </button>
              <button
                onClick={crearPresentacion}
                disabled={loading}
                className="btn btn-primary flex-1"
              >
                Crear Presentación
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
