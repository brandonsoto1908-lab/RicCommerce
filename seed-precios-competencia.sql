-- =========================================
-- SEED: PRECIOS DE COMPETENCIA
-- =========================================
-- Insertar los 31 productos de competencia
-- (Walmart y PriceSmart)
-- =========================================

BEGIN;

DO $$
DECLARE
  v_user_id UUID;
BEGIN
  -- Obtener el ID del usuario system@stonebyric.com
  SELECT id INTO v_user_id FROM auth.users WHERE email = 'system@stonebyric.com';
  
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION '❌ Usuario system@stonebyric.com no encontrado';
  END IF;
  
  RAISE NOTICE '✅ Usuario encontrado: %', v_user_id;
  RAISE NOTICE '📝 Insertando precios de competencia...';

  -- ============================================
  -- PRICESMART - 19 productos
  -- ============================================
  
  INSERT INTO precios_competencia (usuario_id, marca, producto, precio_crc, precio_usd, cantidad, unidad_medida, distribuidor, categoria) VALUES
  (v_user_id, 'TRONEX', 'TRONEX FLORAL FANTASY SCENT', 5495.00, 10.95, 9474, 'mililitros', 'PRICESMART', 'detergente'),
  (v_user_id, 'MAS', 'MAS OSCURA LIQUID DETERGENT', 11495.00, 22.93, 9000, 'mililitros', 'PRICESMART', 'detergente'),
  (v_user_id, 'ARIEL', 'ARIEL LIQUID DETERGENT', 12995.00, 25.88, 8500, 'mililitros', 'PRICESMART', 'detergente'),
  (v_user_id, 'FABULO FABULOSO', 'FABULOSO DISINFECTANT', 7295.00, 14.55, 10000, 'mililitros', 'PRICESMART', 'desinfectante'),
  (v_user_id, 'MEMBER SELECTION', 'MEMBER SELECTION DISINFECTANT', 6295.00, 12.56, 10000, 'mililitros', 'PRICESMART', 'desinfectante'),
  (v_user_id, 'MAS', 'MAS BEBÉ LIQUID DETERGENT', 10395.00, 20.73, 8300, 'mililitros', 'PRICESMART', 'detergente'),
  (v_user_id, 'XEDEX', 'XEDEX LIQUID DETERGENT', 12995.00, 25.88, 10000, 'mililitros', 'PRICESMART', 'detergente'),
  (v_user_id, 'DOWNY', 'DOWNY SCENTED BEADS', 7295.00, 14.55, 694, 'gramos', 'PRICESMART', 'perlas'),
  (v_user_id, 'DOWNY', 'DOWNY SCENTED BEADS 963g', 9195.00, 18.34, 963, 'gramos', 'PRICESMART', 'perlas'),
  (v_user_id, 'DOWNY', 'DOWNY SCENTED BEADS 963g v2', 9196.00, 18.34, 963, 'gramos', 'PRICESMART', 'perlas'),
  (v_user_id, 'MEMBER', 'MEMBER SELECTION SCENTED BEADS', 6995.00, 13.95, 1060, 'gramos', 'PRICESMART', 'perlas'),
  (v_user_id, 'TIDE', 'TIDE LIQUID DETERGENT', 17795.00, 35.48, 5020, 'mililitros', 'PRICESMART', 'detergente'),
  (v_user_id, 'DAWN', 'DAWN LIQUID DISH SOAP 2.66L', 5760.00, 11.50, 2660, 'mililitros', 'PRICESMART', 'jabon'),
  (v_user_id, 'DAWN', 'DAWN LIQUID DISH SOAP 2.66L v2', 7995.00, 15.94, 2660, 'mililitros', 'PRICESMART', 'jabon'),
  (v_user_id, 'MEMBER', 'MEMBER SELECTION LIQUID DISH SOAP', 3995.00, 7.97, 2661, 'mililitros', 'PRICESMART', 'jabon'),
  (v_user_id, 'DOWNY', 'DOWNY FABRIC SOFTENER 4.45L', 10495.00, 20.94, 4450, 'mililitros', 'PRICESMART', 'suavizante'),
  (v_user_id, 'DOWNY', 'DOWNY FABRIC SOFTENER 4.45L v2', 9995.00, 19.93, 4450, 'mililitros', 'PRICESMART', 'suavizante'),
  (v_user_id, 'SUAVITEL', 'SUAVITEL FABRIC SOFTENER', 12395.00, 24.72, 8500, 'mililitros', 'PRICESMART', 'suavizante'),
  (v_user_id, 'MEMBER SELECTION', 'MEMBER SELECTION FABRIC SOFTENER', 8995.00, 17.93, 10000, 'mililitros', 'PRICESMART', 'suavizante');

  RAISE NOTICE '  ✅ PRICESMART: 19 productos insertados';

  -- ============================================
  -- WALMART - 12 productos
  -- ============================================
  
  INSERT INTO precios_competencia (usuario_id, marca, producto, precio_crc, precio_usd, cantidad, unidad_medida, distribuidor, categoria) VALUES
  (v_user_id, 'GAIN', 'GAIN FLING DETERGENT', 5800.00, 11.57, 324, 'gramos', 'WALMART', 'detergente'),
  (v_user_id, 'CLOROX', 'CLOROX LAVENDER BLEACH', 1700.00, 3.39, 3785, 'mililitros', 'WALMART', 'cloro'),
  (v_user_id, 'GREAT VALUE', 'GREAT VALUE BLEACH', 900.00, 1.79, 1893, 'mililitros', 'WALMART', 'cloro'),
  (v_user_id, 'DAWN', 'DAWN LIQUID DISH SOAP', 1870.00, 3.73, 434, 'mililitros', 'WALMART', 'jabon'),
  (v_user_id, 'XEDEX', 'XEDEX LIQUID DETERGENT', 3960.00, 7.89, 2000, 'mililitros', 'WALMART', 'detergente'),
  (v_user_id, 'FABULOSO', 'FABULOSO LAVENDER', 730.00, 1.46, 750, 'mililitros', 'WALMART', 'desinfectante'),
  (v_user_id, 'FABULOSO', 'FABULOSO ULTRA FRESH LEMON', 3300.00, 6.58, 3780, 'mililitros', 'WALMART', 'desinfectante'),
  (v_user_id, 'GAIN', 'GAIN SCENT BEADS', 6400.00, 12.76, 680, 'gramos', 'WALMART', 'perlas'),
  (v_user_id, 'DWY', 'DOWNY UNS FRESH SCENT BEADS', 6400.00, 12.76, 680, 'gramos', 'WALMART', 'perlas'),
  (v_user_id, 'SUAVITEL', 'SUAVITEL NIGHT SOFTENER', 2290.00, 4.57, 1300, 'mililitros', 'WALMART', 'suavizante'),
  (v_user_id, 'IREX', 'IREX VANILLA COMFORT', 3130.00, 6.24, 3000, 'mililitros', 'WALMART', 'suavizante'),
  (v_user_id, 'TIDE', 'TIDE LIQUID DETERGENT', 17500.00, 34.87, 3900, 'mililitros', 'WALMART', 'detergente');

  RAISE NOTICE '  ✅ WALMART: 12 productos insertados';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Total: 31 precios de competencia insertados';
  
END $$;

COMMIT;

-- ============================================
-- VERIFICACIÓN
-- ============================================

SELECT 
  distribuidor,
  COUNT(*) as total_productos,
  SUM(precio_crc) as total_precio_crc,
  SUM(precio_usd) as total_precio_usd
FROM precios_competencia
WHERE usuario_id = (SELECT id FROM auth.users WHERE email = 'system@stonebyric.com')
GROUP BY distribuidor
ORDER BY distribuidor;
