INSERT INTO analytics.dim_country (country_name)
SELECT DISTINCT country_name
FROM (
    SELECT customer_country AS country_name FROM mock_data
    UNION SELECT seller_country FROM mock_data
    UNION SELECT store_country FROM mock_data
    UNION SELECT supplier_country FROM mock_data
) countries
WHERE country_name IS NOT NULL AND country_name <> '';

INSERT INTO analytics.dim_location (address, city, state, country_id)
SELECT DISTINCT locations.address, locations.city, locations.state, c.country_id
FROM (
    SELECT NULLIF(store_location, '') AS address, NULLIF(store_city, '') AS city, NULLIF(store_state, '') AS state, store_country AS country_name FROM mock_data
    UNION
    SELECT NULLIF(supplier_address, ''), NULLIF(supplier_city, ''), NULL, supplier_country FROM mock_data
) locations
JOIN analytics.dim_country c ON c.country_name = locations.country_name;

INSERT INTO analytics.dim_pet (pet_type, pet_name, pet_breed)
SELECT DISTINCT NULLIF(customer_pet_type, ''), NULLIF(customer_pet_name, ''), NULLIF(customer_pet_breed, '')
FROM mock_data;

INSERT INTO analytics.dim_customer (first_name, last_name, age, email, postal_code, country_id, pet_id)
SELECT m.customer_first_name, m.customer_last_name, m.customer_age, m.customer_email,
       NULLIF(m.customer_postal_code, ''), c.country_id, p.pet_id
FROM mock_data m
JOIN analytics.dim_country c ON c.country_name = m.customer_country
JOIN analytics.dim_pet p
  ON p.pet_type IS NOT DISTINCT FROM NULLIF(m.customer_pet_type, '')
 AND p.pet_name IS NOT DISTINCT FROM NULLIF(m.customer_pet_name, '')
 AND p.pet_breed IS NOT DISTINCT FROM NULLIF(m.customer_pet_breed, '');

INSERT INTO analytics.dim_seller (first_name, last_name, email, postal_code, country_id)
SELECT m.seller_first_name, m.seller_last_name, m.seller_email, NULLIF(m.seller_postal_code, ''), c.country_id
FROM mock_data m
JOIN analytics.dim_country c ON c.country_name = m.seller_country;

INSERT INTO analytics.dim_store (store_name, phone, email, location_id)
SELECT m.store_name, NULLIF(m.store_phone, ''), m.store_email, l.location_id
FROM mock_data m
JOIN analytics.dim_country c ON c.country_name = m.store_country
JOIN analytics.dim_location l
  ON l.address IS NOT DISTINCT FROM NULLIF(m.store_location, '')
 AND l.city IS NOT DISTINCT FROM NULLIF(m.store_city, '')
 AND l.state IS NOT DISTINCT FROM NULLIF(m.store_state, '')
 AND l.country_id = c.country_id;

INSERT INTO analytics.dim_supplier (supplier_name, contact_name, email, phone, location_id)
SELECT m.supplier_name, NULLIF(m.supplier_contact, ''), m.supplier_email, NULLIF(m.supplier_phone, ''), l.location_id
FROM mock_data m
JOIN analytics.dim_country c ON c.country_name = m.supplier_country
JOIN analytics.dim_location l
  ON l.address IS NOT DISTINCT FROM NULLIF(m.supplier_address, '')
 AND l.city IS NOT DISTINCT FROM NULLIF(m.supplier_city, '')
 AND l.state IS NULL
 AND l.country_id = c.country_id;

INSERT INTO analytics.dim_product_category (product_category, pet_category)
SELECT DISTINCT product_category, pet_category
FROM mock_data;

INSERT INTO analytics.dim_product (source_product_id, product_name, category_id, supplier_id, price, stock_quantity, weight, color, size, brand, material, description, rating, reviews, release_date, expiry_date)
SELECT m.source_row_id, m.product_name, pc.category_id, s.supplier_id, m.product_price, m.product_quantity,
       m.product_weight, NULLIF(m.product_color, ''), NULLIF(m.product_size, ''), NULLIF(m.product_brand, ''),
       NULLIF(m.product_material, ''), NULLIF(m.product_description, ''), m.product_rating, m.product_reviews,
       to_date(m.product_release_date, 'MM/DD/YYYY'), to_date(m.product_expiry_date, 'MM/DD/YYYY')
FROM mock_data m
JOIN analytics.dim_product_category pc
  ON pc.product_category = m.product_category AND pc.pet_category = m.pet_category
JOIN analytics.dim_supplier s ON s.email = m.supplier_email;

INSERT INTO analytics.dim_date (date_id, full_date, day_of_month, month_number, month_name, quarter_number, year_number, day_of_week, day_name)
SELECT DISTINCT
       to_char(sale_day, 'YYYYMMDD')::integer,
       sale_day,
       extract(day FROM sale_day)::smallint,
       extract(month FROM sale_day)::smallint,
       trim(to_char(sale_day, 'Month')),
       extract(quarter FROM sale_day)::smallint,
       extract(year FROM sale_day)::smallint,
       extract(isodow FROM sale_day)::smallint,
       trim(to_char(sale_day, 'Day'))
FROM (SELECT to_date(sale_date, 'MM/DD/YYYY') AS sale_day FROM mock_data) dates;

INSERT INTO analytics.fact_sales (source_row_id, source_sale_id, customer_id, seller_id, product_id, store_id, date_id, quantity, total_price)
SELECT m.source_row_id, m.id, c.customer_id, s.seller_id, p.product_id, st.store_id,
       to_char(to_date(m.sale_date, 'MM/DD/YYYY'), 'YYYYMMDD')::integer,
       m.sale_quantity, m.sale_total_price
FROM mock_data m
JOIN analytics.dim_customer c ON c.email = m.customer_email
JOIN analytics.dim_seller s ON s.email = m.seller_email
JOIN analytics.dim_product p ON p.source_product_id = m.source_row_id
JOIN analytics.dim_store st ON st.email = m.store_email;
