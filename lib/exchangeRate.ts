// Servicio para obtener tasa de cambio USD a CRC
const EXCHANGE_API_URL = process.env.NEXT_PUBLIC_EXCHANGE_API_URL || 'https://api.exchangerate-api.com/v4/latest/USD'

export interface ExchangeRateResponse {
  success: boolean
  rate: number
  source: 'api' | 'manual' | 'cache'
  timestamp: number
}

// Cache de tasa de cambio (válida por 24 horas)
let cachedRate: { rate: number; timestamp: number } | null = null
const CACHE_DURATION = 24 * 60 * 60 * 1000 // 24 horas en milisegundos

export const getExchangeRate = async (manualRate?: number): Promise<ExchangeRateResponse> => {
  // Si se proporciona una tasa manual, usarla
  if (manualRate && manualRate > 0) {
    return {
      success: true,
      rate: manualRate,
      source: 'manual',
      timestamp: Date.now(),
    }
  }

  // Verificar si hay una tasa en cache válida
  if (cachedRate && Date.now() - cachedRate.timestamp < CACHE_DURATION) {
    return {
      success: true,
      rate: cachedRate.rate,
      source: 'cache',
      timestamp: cachedRate.timestamp,
    }
  }

  // Intentar obtener de la API
  try {
    const response = await fetch(EXCHANGE_API_URL)
    
    if (!response.ok) {
      throw new Error('Error al obtener tasa de cambio de la API')
    }

    const data = await response.json()
    
    // La API retorna tasas contra USD, necesitamos CRC
    const crcRate = data.rates?.CRC || null

    if (!crcRate) {
      throw new Error('Tasa CRC no disponible en la respuesta de la API')
    }

    // Guardar en cache
    cachedRate = {
      rate: crcRate,
      timestamp: Date.now(),
    }

    return {
      success: true,
      rate: crcRate,
      source: 'api',
      timestamp: Date.now(),
    }
  } catch (error) {
    console.error('Error obteniendo tasa de cambio:', error)

    // Si hay un cache previo aunque sea antiguo, usarlo
    if (cachedRate) {
      return {
        success: true,
        rate: cachedRate.rate,
        source: 'cache',
        timestamp: cachedRate.timestamp,
      }
    }

    // Si no hay cache, retornar tasa por defecto
    return {
      success: false,
      rate: 520, // Tasa por defecto
      source: 'manual',
      timestamp: Date.now(),
    }
  }
}

// Obtener tasa de cambio desde configuración de Supabase
import { supabase } from './supabase'

export const getExchangeRateFromConfig = async (): Promise<number> => {
  try {
    const { data, error } = await supabase
      .from('configuracion')
      .select('valor')
      .eq('clave', 'tasa_cambio_manual')
      .single()

    if (error || !data) {
      console.error('Error obteniendo tasa de configuración:', error)
      return 520 // Valor por defecto
    }

    return parseFloat(data.valor)
  } catch (error) {
    console.error('Error:', error)
    return 520
  }
}

// Actualizar tasa de cambio en configuración
export const updateExchangeRateConfig = async (newRate: number): Promise<boolean> => {
  try {
    const { error } = await supabase
      .from('configuracion')
      .update({ valor: newRate.toString() })
      .eq('clave', 'tasa_cambio_manual')

    if (error) {
      console.error('Error actualizando tasa:', error)
      return false
    }

    return true
  } catch (error) {
    console.error('Error:', error)
    return false
  }
}

// Obtener tasa combinada (API o manual según configuración)
export const getCombinedExchangeRate = async (): Promise<ExchangeRateResponse> => {
  try {
    // Verificar configuración para saber si usar API
    const { data: configData } = await supabase
      .from('configuracion')
      .select('valor')
      .eq('clave', 'usar_api_cambio')
      .single()

    const useAPI = configData?.valor === 'true'

    if (useAPI) {
      // Intentar usar API
      const apiResult = await getExchangeRate()
      if (apiResult.success) {
        return apiResult
      }
    }

    // Si no se usa API o falló, usar tasa manual de configuración
    const manualRate = await getExchangeRateFromConfig()
    return {
      success: true,
      rate: manualRate,
      source: 'manual',
      timestamp: Date.now(),
    }
  } catch (error) {
    console.error('Error obteniendo tasa combinada:', error)
    return {
      success: false,
      rate: 520,
      source: 'manual',
      timestamp: Date.now(),
    }
  }
}
