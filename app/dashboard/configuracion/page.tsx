'use client'

import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'
import { Save, RefreshCw } from 'lucide-react'
import { getCombinedExchangeRate, updateExchangeRateConfig } from '@/lib/exchangeRate'

export default function ConfiguracionPage() {
  const [loading, setLoading] = useState(false)
  const [tasaCambioManual, setTasaCambioManual] = useState('520')
  const [usarAPI, setUsarAPI] = useState(true)
  const [margenMinimo, setMargenMinimo] = useState('15')
  const [tasaCambioActual, setTasaCambioActual] = useState(0)

  useEffect(() => {
    loadConfiguracion()
    loadTasaCambio()
  }, [])

  const loadConfiguracion = async () => {
    try {
      const { data } = await supabase
        .from('configuracion')
        .select('*')

      if (data) {
        data.forEach(config => {
          if (config.clave === 'tasa_cambio_manual') {
            setTasaCambioManual(config.valor)
          } else if (config.clave === 'usar_api_cambio') {
            setUsarAPI(config.valor === 'true')
          } else if (config.clave === 'margen_minimo_alerta') {
            setMargenMinimo(config.valor)
          }
        })
      }
    } catch (error) {
      console.error('Error cargando configuración:', error)
    }
  }

  const loadTasaCambio = async () => {
    const result = await getCombinedExchangeRate()
    setTasaCambioActual(result.rate)
  }

  const guardarConfiguracion = async () => {
    setLoading(true)
    try {
      // Actualizar tasa de cambio manual
      await supabase
        .from('configuracion')
        .update({ valor: tasaCambioManual })
        .eq('clave', 'tasa_cambio_manual')

      // Actualizar uso de API
      await supabase
        .from('configuracion')
        .update({ valor: usarAPI ? 'true' : 'false' })
        .eq('clave', 'usar_api_cambio')

      // Actualizar margen mínimo
      await supabase
        .from('configuracion')
        .update({ valor: margenMinimo })
        .eq('clave', 'margen_minimo_alerta')

      alert('Configuración guardada exitosamente')
    } catch (error: any) {
      alert('Error al guardar: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div>
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">Configuración</h1>
        <p className="text-gray-600 mt-2">Ajustes generales del sistema</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Configuración de Tasa de Cambio */}
        <div className="card">
          <h2 className="text-xl font-semibold mb-4">Tasa de Cambio</h2>
          
          <div className="mb-4 p-4 bg-primary-50 rounded-lg">
            <div className="flex justify-between items-center">
              <span className="text-gray-700">Tasa Actual:</span>
              <div className="flex items-center gap-2">
                <span className="text-2xl font-bold text-primary-600">
                  ₡{tasaCambioActual.toFixed(2)}
                </span>
                <button
                  onClick={loadTasaCambio}
                  className="p-1 hover:bg-primary-100 rounded"
                  title="Actualizar tasa"
                >
                  <RefreshCw size={18} />
                </button>
              </div>
            </div>
          </div>

          <div className="space-y-4">
            <div>
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={usarAPI}
                  onChange={(e) => setUsarAPI(e.target.checked)}
                  className="w-4 h-4 text-primary-600 rounded focus:ring-primary-500"
                />
                <span className="text-sm font-medium text-gray-700">
                  Usar API para obtener tasa automáticamente
                </span>
              </label>
              <p className="text-xs text-gray-500 mt-1 ml-6">
                Se actualiza cada 24 horas desde exchangerate-api.com
              </p>
            </div>

            <div>
              <label className="label">Tasa de Cambio Manual (USD → CRC)</label>
              <input
                type="number"
                value={tasaCambioManual}
                onChange={(e) => setTasaCambioManual(e.target.value)}
                className="input"
                min="0"
                step="0.01"
                disabled={usarAPI}
              />
              <p className="text-xs text-gray-500 mt-1">
                {usarAPI 
                  ? 'Se usará como respaldo si la API falla' 
                  : 'Esta tasa se usará para todas las conversiones'
                }
              </p>
            </div>
          </div>
        </div>

        {/* Configuración de Márgenes */}
        <div className="card">
          <h2 className="text-xl font-semibold mb-4">Alertas y Márgenes</h2>
          
          <div className="space-y-4">
            <div>
              <label className="label">Margen Mínimo de Ganancia (%)</label>
              <input
                type="number"
                value={margenMinimo}
                onChange={(e) => setMargenMinimo(e.target.value)}
                className="input"
                min="0"
                step="0.1"
              />
              <p className="text-xs text-gray-500 mt-1">
                Se mostrará una alerta cuando el margen sea menor a este porcentaje
              </p>
            </div>

            <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
              <h3 className="font-medium text-yellow-800 mb-2">Niveles de Alerta</h3>
              <ul className="text-sm text-yellow-700 space-y-1">
                <li>🔴 Margen &lt; {margenMinimo}% - Bajo (Rojo)</li>
                <li>🟡 Margen &lt; 30% - Medio (Amarillo)</li>
                <li>🟢 Margen ≥ 30% - Óptimo (Verde)</li>
              </ul>
            </div>
          </div>
        </div>

        {/* Información del Sistema */}
        <div className="card lg:col-span-2">
          <h2 className="text-xl font-semibold mb-4">Información del Sistema</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="p-4 bg-gray-50 rounded-lg">
              <p className="text-sm text-gray-600">Versión del Sistema</p>
              <p className="text-lg font-semibold mt-1">1.0.0</p>
            </div>

            <div className="p-4 bg-gray-50 rounded-lg">
              <p className="text-sm text-gray-600">Base de Datos</p>
              <p className="text-lg font-semibold mt-1">Supabase</p>
            </div>

            <div className="p-4 bg-gray-50 rounded-lg">
              <p className="text-sm text-gray-600">Despliegue</p>
              <p className="text-lg font-semibold mt-1">Vercel</p>
            </div>
          </div>

          <div className="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
            <h3 className="font-medium text-blue-800 mb-2">Características Principales</h3>
            <ul className="text-sm text-blue-700 grid grid-cols-1 md:grid-cols-2 gap-2">
              <li>✓ Gestión de compras y ventas</li>
              <li>✓ Control de inventario en tiempo real</li>
              <li>✓ Cálculo automático de márgenes</li>
              <li>✓ Registro de gastos operativos</li>
              <li>✓ Reportes descargables en PDF</li>
              <li>✓ Conversión automática de moneda</li>
              <li>✓ Sistema multiusuario</li>
              <li>✓ Interfaz responsive</li>
            </ul>
          </div>
        </div>
      </div>

      {/* Botón de Guardar */}
      <div className="mt-8 flex justify-end">
        <button
          onClick={guardarConfiguracion}
          disabled={loading}
          className="btn btn-primary flex items-center gap-2"
        >
          <Save size={20} />
          Guardar Configuración
        </button>
      </div>
    </div>
  )
}
