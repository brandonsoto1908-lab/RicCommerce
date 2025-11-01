// Utilidades para formateo de moneda
export const formatCurrency = (amount: number, currency: 'USD' | 'CRC' = 'USD'): string => {
  return new Intl.NumberFormat('es-CR', {
    style: 'currency',
    currency: currency,
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amount)
}

// Convertir USD a CRC
export const convertUSDtoCRC = (amountUSD: number, exchangeRate: number): number => {
  return amountUSD * exchangeRate
}

// Convertir CRC a USD
export const convertCRCtoUSD = (amountCRC: number, exchangeRate: number): number => {
  return amountCRC / exchangeRate
}

// Calcular margen de ganancia
export interface MargenCalculado {
  margenPorcentaje: number
  margenColones: number
  margenDolares: number
}

export const calcularMargen = (
  costoUSD: number,
  precioVentaColones: number,
  tasaCambio: number,
  costoEnvaseUSD: number = 0,
  gastosProporcionalesUSD: number = 0
): MargenCalculado => {
  // Costo total en USD
  const costoTotalUSD = costoUSD + costoEnvaseUSD + gastosProporcionalesUSD
  
  // Convertir precio de venta a USD
  const precioVentaUSD = convertCRCtoUSD(precioVentaColones, tasaCambio)
  
  // Calcular margen en USD
  const margenDolares = precioVentaUSD - costoTotalUSD
  
  // Calcular margen en colones
  const margenColones = convertUSDtoCRC(margenDolares, tasaCambio)
  
  // Calcular porcentaje de margen
  const margenPorcentaje = costoTotalUSD > 0 
    ? (margenDolares / costoTotalUSD) * 100 
    : 0
  
  return {
    margenPorcentaje: Math.round(margenPorcentaje * 100) / 100,
    margenColones: Math.round(margenColones * 100) / 100,
    margenDolares: Math.round(margenDolares * 100) / 100,
  }
}

// Formatear fecha
export const formatDate = (date: string | Date): string => {
  const d = new Date(date)
  return d.toLocaleDateString('es-CR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

// Formatear fecha corta
export const formatDateShort = (date: string | Date): string => {
  const d = new Date(date)
  return d.toLocaleDateString('es-CR', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  })
}

// Validar email
export const isValidEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return emailRegex.test(email)
}

// Truncar texto
export const truncateText = (text: string, maxLength: number): string => {
  if (text.length <= maxLength) return text
  return text.substring(0, maxLength) + '...'
}

// Generar ID único (alternativa a UUID)
export const generateId = (): string => {
  return Date.now().toString(36) + Math.random().toString(36).substring(2)
}

// Calcular gastos utilitarios proporcionales
export const calcularGastosProporcionados = (
  gastosUtilitariosMensuales: number,
  cantidadProductosVendidosMes: number
): number => {
  if (cantidadProductosVendidosMes === 0) return 0
  return gastosUtilitariosMensuales / cantidadProductosVendidosMes
}

// Redondear a 2 decimales
export const roundToTwo = (num: number): number => {
  return Math.round(num * 100) / 100
}

// Obtener rango de fechas para filtros
export const getDateRange = (period: 'hoy' | 'semana' | 'mes' | 'año' | 'custom'): { start: Date; end: Date } => {
  const end = new Date()
  let start = new Date()

  switch (period) {
    case 'hoy':
      start.setHours(0, 0, 0, 0)
      break
    case 'semana':
      start.setDate(end.getDate() - 7)
      break
    case 'mes':
      start.setMonth(end.getMonth() - 1)
      break
    case 'año':
      start.setFullYear(end.getFullYear() - 1)
      break
    default:
      start = end
  }

  return { start, end }
}

// Validar número positivo
export const isPositiveNumber = (value: any): boolean => {
  const num = Number(value)
  return !isNaN(num) && num > 0
}

// Formatear número con separadores de miles
export const formatNumber = (num: number): string => {
  return new Intl.NumberFormat('es-CR').format(num)
}
