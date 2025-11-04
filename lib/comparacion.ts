// =========================================
// UTILIDADES PARA COMPARACIÓN DE PRECIOS
// =========================================

/**
 * Convierte cualquier cantidad a litros (para líquidos) o kilogramos (para sólidos)
 */
export const normalizarCantidad = (cantidad: number, unidad: string): { cantidad: number, unidadNormalizada: string } => {
  const unidadLower = unidad.toLowerCase()
  
  // Líquidos -> Litros
  if (unidadLower.includes('ml') || unidadLower === 'mililitros') {
    return { cantidad: cantidad / 1000, unidadNormalizada: 'litros' }
  }
  if (unidadLower.includes('litro') || unidadLower === 'litros') {
    return { cantidad, unidadNormalizada: 'litros' }
  }
  
  // Sólidos -> Kilogramos
  if (unidadLower.includes('g') && !unidadLower.includes('kg') || unidadLower === 'gramos') {
    return { cantidad: cantidad / 1000, unidadNormalizada: 'kilogramos' }
  }
  if (unidadLower.includes('kg') || unidadLower === 'kilogramos') {
    return { cantidad, unidadNormalizada: 'kilogramos' }
  }
  
  // Por defecto, retornar como está
  return { cantidad, unidadNormalizada: unidad }
}

/**
 * Calcula el precio por unidad normalizada (litro o kilogramo)
 */
export const calcularPrecioPorUnidad = (
  precioTotal: number,
  cantidad: number,
  unidad: string
): number => {
  const { cantidad: cantidadNormalizada } = normalizarCantidad(cantidad, unidad)
  
  if (cantidadNormalizada === 0) return 0
  return precioTotal / cantidadNormalizada
}

/**
 * Compara el precio de un producto con los precios de la competencia
 * Retorna el precio promedio de la competencia y la diferencia porcentual
 */
export interface ComparacionPrecio {
  tuPrecio: number
  promedioCompetencia: number
  minimoCompetencia: number
  maximoCompetencia: number
  diferenciaPorcentaje: number
  esCompetitivo: boolean // true si tu precio es menor o igual al promedio
  walmart?: number
  pricesmart?: number
}

export const compararConCompetencia = (
  tuPrecio: number,
  tuCantidad: number,
  tuUnidad: string,
  preciosCompetencia: Array<{
    precio_usd: number
    cantidad: number
    unidad_medida: string
    distribuidor: string
  }>
): ComparacionPrecio | null => {
  if (preciosCompetencia.length === 0) {
    return null
  }

  // Normalizar tu precio
  const tuPrecioPorUnidad = calcularPrecioPorUnidad(tuPrecio, tuCantidad, tuUnidad)

  // Normalizar precios de competencia
  const preciosNormalizados = preciosCompetencia.map(p => ({
    precioPorUnidad: calcularPrecioPorUnidad(p.precio_usd, p.cantidad, p.unidad_medida),
    distribuidor: p.distribuidor
  }))

  // Calcular estadísticas
  const precios = preciosNormalizados.map(p => p.precioPorUnidad)
  const promedioCompetencia = precios.reduce((sum, p) => sum + p, 0) / precios.length
  const minimoCompetencia = Math.min(...precios)
  const maximoCompetencia = Math.max(...precios)

  // Precios por distribuidor
  const walmart = preciosNormalizados
    .filter(p => p.distribuidor === 'WALMART')
    .map(p => p.precioPorUnidad)
  const promedioWalmart = walmart.length > 0 
    ? walmart.reduce((sum, p) => sum + p, 0) / walmart.length 
    : undefined

  const pricesmart = preciosNormalizados
    .filter(p => p.distribuidor === 'PRICESMART')
    .map(p => p.precioPorUnidad)
  const promedioPricesmart = pricesmart.length > 0 
    ? pricesmart.reduce((sum, p) => sum + p, 0) / pricesmart.length 
    : undefined

  // Calcular diferencia porcentual
  const diferenciaPorcentaje = ((tuPrecioPorUnidad - promedioCompetencia) / promedioCompetencia) * 100

  return {
    tuPrecio: tuPrecioPorUnidad,
    promedioCompetencia,
    minimoCompetencia,
    maximoCompetencia,
    diferenciaPorcentaje,
    esCompetitivo: tuPrecioPorUnidad <= promedioCompetencia,
    walmart: promedioWalmart,
    pricesmart: promedioPricesmart
  }
}

/**
 * Agrupa productos por categoría para comparación
 */
export const agruparPorCategoria = <T extends { categoria?: string }>(
  items: T[]
): Record<string, T[]> => {
  return items.reduce((grupos, item) => {
    const categoria = item.categoria || 'sin_categoria'
    if (!grupos[categoria]) {
      grupos[categoria] = []
    }
    grupos[categoria].push(item)
    return grupos
  }, {} as Record<string, T[]>)
}
