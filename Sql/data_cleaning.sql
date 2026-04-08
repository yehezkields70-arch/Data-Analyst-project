--  =========================================================================
-- DATA CLEANING
-- Tujuan: Mengetahui apakah ada data yang kosong, tidak valid, atau duplikat
-- =========================================================================

USE retail_db;

-- cek data kosong
SELECT * FROM sales
WHERE quantity IS NULL;

-- cek nilai tidak valid
SELECT * FROM sales
WHERE quantity <= 0;

-- cek duplicate
SELECT transaction_id, COUNT(*)
FROM sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;