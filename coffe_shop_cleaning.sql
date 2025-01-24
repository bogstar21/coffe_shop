-- Cleaning of the data 
-- No null rows identifided 
SELECT *
FROM coffee_shop
WHERE transaction_id IS NULL
   OR transaction_date IS NULL;
   
DELETE FROM coffee_shop
WHERE transaction_id IS NULL
   OR transaction_date IS NULL;

DELETE FROM coffee_shop
WHERE ctid NOT IN (
    SELECT MIN(ctid)
    FROM coffee_shop
    GROUP BY transaction_id, transaction_date, store_id, product_id
);

-- NO INVALID INFORMATION
SELECT DISTINCT product_category FROM coffee_shop;

SELECT *
FROM coffee_shop
WHERE unit_price <= 0
   OR transaction_qty <= 0;

-- CREATE NEW COLUMNS 
ALTER TABLE coffee_shop ADD COLUMN transaction_total NUMERIC;
UPDATE coffee_shop
SET transaction_total = transaction_qty * unit_price;

   