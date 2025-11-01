'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { Download, Filter } from 'lucide-react'
import { formatCurrency, formatDateShort } from '@/lib/utils'
import jsPDF from 'jspdf'
import autoTable from 'jspdf-autotable'

export default function ReportesPage() {
  const [loading, setLoading] = useState(false)
  const [tipoReporte, setTipoReporte] = useState<'ventas' | 'compras' | 'gastos' | 'inventario'>('ventas')
  const [fechaInicio, setFechaInicio] = useState(() => {
    const date = new Date()
    date.setMonth(date.getMonth() - 1)
    return date.toISOString().split('T')[0]
  })
  const [fechaFin, setFechaFin] = useState(new Date().toISOString().split('T')[0])
  const [datos, setDatos] = useState<any[]>([])

  const generarReporte = async () => {
    setLoading(true)
    try {
      let data: any[] = []

      switch (tipoReporte) {
        case 'ventas':
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
            .gte('fecha', fechaInicio)
            .lte('fecha', fechaFin)
            .order('fecha', { ascending: false })
          data = ventasData || []
          break

        case 'compras':
          const { data: comprasData } = await supabase
            .from('compras')
            .select(`
              *,
              compras_detalle (
                *,
                productos (nombre, marca)
              )
            `)
            .gte('fecha', fechaInicio)
            .lte('fecha', fechaFin)
            .order('fecha', { ascending: false })
          data = comprasData || []
          break

        case 'gastos':
          const { data: gastosData } = await supabase
            .from('gastos')
            .select('*')
            .gte('fecha', fechaInicio)
            .lte('fecha', fechaFin)
            .eq('activo', true)
            .order('fecha', { ascending: false })
          data = gastosData || []
          break

        case 'inventario':
          const { data: inventarioData } = await supabase
            .from('inventario')
            .select(`
              *,
              productos (nombre, marca, unidad_medida)
            `)
          data = inventarioData || []
          break
      }

      setDatos(data)
    } catch (error) {
      console.error('Error generando reporte:', error)
      alert('Error al generar reporte')
    } finally {
      setLoading(false)
    }
  }

  const descargarPDF = () => {
    const doc = new jsPDF()
    
    doc.setFontSize(18)
    doc.text(`Reporte de ${tipoReporte.toUpperCase()}`, 14, 22)
    doc.setFontSize(11)
    doc.text(`Período: ${fechaInicio} a ${fechaFin}`, 14, 30)

    let tableData: any[] = []
    let headers: string[] = []

    switch (tipoReporte) {
      case 'ventas':
        headers = ['Fecha', 'Total (₡)', 'Total (USD)', 'Productos']
        tableData = datos.map(v => [
          formatDateShort(v.fecha),
          formatCurrency(v.total_colones, 'CRC'),
          formatCurrency(v.total_usd, 'USD'),
          v.ventas_detalle?.length || 0
        ])
        break

      case 'compras':
        headers = ['Fecha', 'Total (USD)', 'Productos', 'Notas']
        tableData = datos.map(c => [
          formatDateShort(c.fecha),
          formatCurrency(c.total_usd, 'USD'),
          c.compras_detalle?.length || 0,
          c.notas || '-'
        ])
        break

      case 'gastos':
        headers = ['Fecha', 'Tipo', 'Categoría', 'Monto (USD)']
        tableData = datos.map(g => [
          formatDateShort(g.fecha),
          g.tipo === 'unico' ? 'Único' : 'Utilitario',
          g.categoria,
          formatCurrency(g.monto_usd, 'USD')
        ])
        break

      case 'inventario':
        headers = ['Producto', 'Marca', 'Stock', 'Costo Prom.', 'Valor Total']
        tableData = datos.map(i => [
          i.productos?.nombre,
          i.productos?.marca,
          `${i.cantidad_disponible.toFixed(2)} ${i.productos?.unidad_medida}`,
          formatCurrency(i.costo_promedio_usd, 'USD'),
          formatCurrency(i.cantidad_disponible * i.costo_promedio_usd, 'USD')
        ])
        break
    }

    autoTable(doc, {
      head: [headers],
      body: tableData,
      startY: 40,
      styles: { fontSize: 8 },
      headStyles: { fillColor: [14, 165, 233] }
    })

    doc.save(`reporte-${tipoReporte}-${new Date().getTime()}.pdf`)
  }

  useEffect(() => {
    generarReporte()
  }, [tipoReporte])

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Reportes</h1>
        <p className="text-gray-600 mt-2">Generación de informes y análisis de datos</p>
      </div>

      {/* Filtros */}
      <div className="card mb-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label className="label">Tipo de Reporte</label>
            <select
              value={tipoReporte}
              onChange={(e) => setTipoReporte(e.target.value as any)}
              className="input"
            >
              <option value="ventas">Ventas</option>
              <option value="compras">Compras</option>
              <option value="gastos">Gastos</option>
              <option value="inventario">Inventario</option>
            </select>
          </div>

          <div>
            <label className="label">Fecha Inicio</label>
            <input
              type="date"
              value={fechaInicio}
              onChange={(e) => setFechaInicio(e.target.value)}
              className="input"
            />
          </div>

          <div>
            <label className="label">Fecha Fin</label>
            <input
              type="date"
              value={fechaFin}
              onChange={(e) => setFechaFin(e.target.value)}
              className="input"
            />
          </div>

          <div className="flex items-end gap-2">
            <button
              onClick={generarReporte}
              disabled={loading}
              className="btn btn-primary flex items-center gap-2 flex-1"
            >
              <Filter size={20} />
              Filtrar
            </button>
            <button
              onClick={descargarPDF}
              disabled={loading || datos.length === 0}
              className="btn btn-success flex items-center gap-2"
            >
              <Download size={20} />
            </button>
          </div>
        </div>
      </div>

      {/* Resultados */}
      <div className="card">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-semibold">
            Resultados: {datos.length} registro(s)
          </h2>
        </div>

        {loading ? (
          <div className="flex items-center justify-center h-64">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
          </div>
        ) : datos.length > 0 ? (
          <div className="table-container">
            <table className="table">
              <thead>
                <tr>
                  {tipoReporte === 'ventas' && (
                    <>
                      <th>Fecha</th>
                      <th>Total (₡)</th>
                      <th>Total (USD)</th>
                      <th>Productos</th>
                      <th>Notas</th>
                    </>
                  )}
                  {tipoReporte === 'compras' && (
                    <>
                      <th>Fecha</th>
                      <th>Total (USD)</th>
                      <th>Productos</th>
                      <th>Notas</th>
                    </>
                  )}
                  {tipoReporte === 'gastos' && (
                    <>
                      <th>Fecha</th>
                      <th>Tipo</th>
                      <th>Categoría</th>
                      <th>Descripción</th>
                      <th>Monto (USD)</th>
                    </>
                  )}
                  {tipoReporte === 'inventario' && (
                    <>
                      <th>Producto</th>
                      <th>Marca</th>
                      <th>Stock</th>
                      <th>Costo Promedio</th>
                      <th>Valor Total</th>
                    </>
                  )}
                </tr>
              </thead>
              <tbody>
                {datos.map((item, index) => (
                  <tr key={index}>
                    {tipoReporte === 'ventas' && (
                      <>
                        <td>{formatDateShort(item.fecha)}</td>
                        <td className="font-semibold">{formatCurrency(item.total_colones, 'CRC')}</td>
                        <td>{formatCurrency(item.total_usd, 'USD')}</td>
                        <td>{item.ventas_detalle?.length || 0} producto(s)</td>
                        <td className="max-w-xs truncate">{item.notas || '-'}</td>
                      </>
                    )}
                    {tipoReporte === 'compras' && (
                      <>
                        <td>{formatDateShort(item.fecha)}</td>
                        <td className="font-semibold">{formatCurrency(item.total_usd, 'USD')}</td>
                        <td>{item.compras_detalle?.length || 0} producto(s)</td>
                        <td className="max-w-xs truncate">{item.notas || '-'}</td>
                      </>
                    )}
                    {tipoReporte === 'gastos' && (
                      <>
                        <td>{formatDateShort(item.fecha)}</td>
                        <td>
                          <span className={`px-2 py-1 rounded text-xs font-medium ${
                            item.tipo === 'unico' ? 'bg-blue-100 text-blue-800' : 'bg-purple-100 text-purple-800'
                          }`}>
                            {item.tipo === 'unico' ? 'Único' : 'Utilitario'}
                          </span>
                        </td>
                        <td>{item.categoria}</td>
                        <td className="max-w-xs truncate">{item.descripcion}</td>
                        <td className="font-semibold">{formatCurrency(item.monto_usd, 'USD')}</td>
                      </>
                    )}
                    {tipoReporte === 'inventario' && (
                      <>
                        <td className="font-medium">{item.productos?.nombre}</td>
                        <td>{item.productos?.marca}</td>
                        <td className="font-semibold">
                          {item.cantidad_disponible.toFixed(2)} {item.productos?.unidad_medida}
                        </td>
                        <td>{formatCurrency(item.costo_promedio_usd, 'USD')}</td>
                        <td className="font-semibold">
                          {formatCurrency(item.cantidad_disponible * item.costo_promedio_usd, 'USD')}
                        </td>
                      </>
                    )}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="text-center py-12 text-gray-500">
            No hay datos para mostrar con los filtros seleccionados
          </div>
        )}
      </div>
    </div>
  )
}
