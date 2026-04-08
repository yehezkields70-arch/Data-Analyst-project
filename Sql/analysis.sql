/* ============================================================================
PHASE 1: SQL DATA ANALYSIS (SALES PERFORMANCE ANALYSIS)
============================================================================

Petunjuk Umum:
1. Pastikan database sudah di-import:
   - retail_db

2. Relasi Tabel:
   - sales.product_id  = products.product_id
   - sales.store_id    = stores.store_id
   - sales.customer_id = customers.customer_id

3. Fokus analisis:
   - Revenue (quantity * price)
   - Store performance
   - Product contribution
   - Customer behavior
*/

-- =========================================================================
-- SOAL 1: Bagaimana tren revenue dari waktu ke waktu?
-- Tujuan: Mengetahui apakah penjualan stabil, meningkat, atau fluktuatif
-- =========================================================================

SELECT
    DATE_FORMAT(s.order_date, '%Y-%m')  AS order_month,
    SUM(s.quantity * p.unit_price_usd)  AS total_revenue
FROM sales s
JOIN products p ON s.product_key = p.product_key
GROUP BY order_month
ORDER BY order_month;


-- =========================================================================
-- SOAL 2: Produk mana yang paling berkontribusi terhadap revenue?
-- Tujuan: Mengidentifikasi produk utama yang menjadi driver penjualan
-- =========================================================================

SELECT
    p.product_name,
    p.category,
    SUM(s.quantity * p.unit_price_usd)   AS total_revenue,
    SUM(s.quantity)                      AS total_quantity
FROM sales s
JOIN products p ON s.product_key = p.product_key
GROUP BY p.product_key, p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 10;

-- =========================================================================
-- SOAL 3: Kategori produk mana yang paling mendominasi revenue?
-- Tujuan: Mengidentifikasi produk yang populer tapi kurang bernilai
-- =========================================================================

SELECT
    p.category,
    SUM(s.quantity * p.unit_price_usd)                              AS total_revenue,
    SUM(s.quantity)                                                 AS total_quantity,
    ROUND(SUM(s.quantity * p.unit_price_usd) /
        SUM(SUM(s.quantity * p.unit_price_usd)) OVER() * 100, 2)   AS revenue_pct
FROM sales s
JOIN products p ON s.product_key = p.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- =========================================================================
-- SOAL 4: Toko mana yang paling efisien dalam menghasilkan revenue?
-- Tujuan: Membandingkan performa toko berdasarkan nilai transaksi
-- =========================================================================

SELECT
    st.store_key,
    st.country,
    st.state,
    COUNT(DISTINCT s.order_number)                                      AS total_orders,
    SUM(s.quantity * p.unit_price_usd)                                  AS total_revenue,
    ROUND(SUM(s.quantity * p.unit_price_usd) /
          COUNT(DISTINCT s.order_number), 2)                            AS avg_revenue_per_order
FROM sales s
JOIN products p ON s.product_key = p.product_key
JOIN stores st  ON s.store_key   = st.store_key
GROUP BY st.store_key, st.country, st.state
ORDER BY total_revenue DESC
LIMIT 10;

-- =========================================================================
-- SOAL 5: Siapa customer yang paling banyak berkontribusi?
-- Tujuan: Mengidentifikasi high-value customers
-- =========================================================================

SELECT
    c.customer_key,
    c.name,
    c.gender,
    c.country,
    COUNT(DISTINCT s.order_number)      AS total_orders,
    SUM(s.quantity * p.unit_price_usd)  AS total_revenue
FROM sales s
JOIN products  p ON s.product_key  = p.product_key
JOIN customers c ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.name, c.gender, c.country
ORDER BY total_revenue DESC
LIMIT 10;

-- =========================================================================
-- SOAL 6: Apakah gender atau kelompok usia tertentu menghasilkan revenue lebih tinggi?
-- Tujuan: Memahami demografi customer yang paling bernilai bagi bisnis
-- =========================================================================

-- 6A: Per Gender
SELECT
    c.gender,
    COUNT(DISTINCT c.customer_key)      AS total_customers,
    SUM(s.quantity * p.unit_price_usd)  AS total_revenue
FROM sales s
JOIN products  p ON s.product_key  = p.product_key
JOIN customers c ON s.customer_key = c.customer_key
GROUP BY c.gender
ORDER BY total_revenue DESC;

-- 6B: Per Age Group
SELECT
    CASE
        WHEN TIMESTAMPDIFF(YEAR, c.birthday, CURDATE()) < 27 THEN 'Gen Z (<27)'
        WHEN TIMESTAMPDIFF(YEAR, c.birthday, CURDATE()) < 43 THEN 'Millennial (27-42)'
        WHEN TIMESTAMPDIFF(YEAR, c.birthday, CURDATE()) < 59 THEN 'Gen X (43-58)'
        ELSE 'Baby Boomer (59+)'
    END                                 AS age_group,
    COUNT(DISTINCT c.customer_key)      AS total_customers,
    SUM(s.quantity * p.unit_price_usd)  AS total_revenue
FROM sales s
JOIN products  p ON s.product_key  = p.product_key
JOIN customers c ON s.customer_key = c.customer_key
GROUP BY age_group
ORDER BY total_revenue DESC;