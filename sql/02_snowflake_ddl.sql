CREATE SCHEMA analytics;

CREATE TABLE analytics.dim_country (
    country_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_name text NOT NULL UNIQUE
);

CREATE TABLE analytics.dim_location (
    location_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    address text,
    city text,
    state text,
    country_id bigint NOT NULL REFERENCES analytics.dim_country(country_id),
    UNIQUE NULLS NOT DISTINCT (address, city, state, country_id)
);

CREATE TABLE analytics.dim_pet (
    pet_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    pet_type text,
    pet_name text,
    pet_breed text,
    UNIQUE NULLS NOT DISTINCT (pet_type, pet_name, pet_breed)
);

CREATE TABLE analytics.dim_customer (
    customer_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name text NOT NULL,
    last_name text NOT NULL,
    age integer,
    email text NOT NULL UNIQUE,
    postal_code text,
    country_id bigint NOT NULL REFERENCES analytics.dim_country(country_id),
    pet_id bigint REFERENCES analytics.dim_pet(pet_id)
);

CREATE TABLE analytics.dim_seller (
    seller_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text NOT NULL UNIQUE,
    postal_code text,
    country_id bigint NOT NULL REFERENCES analytics.dim_country(country_id)
);

CREATE TABLE analytics.dim_store (
    store_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    store_name text NOT NULL,
    phone text,
    email text NOT NULL UNIQUE,
    location_id bigint NOT NULL REFERENCES analytics.dim_location(location_id)
);

CREATE TABLE analytics.dim_supplier (
    supplier_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_name text NOT NULL,
    contact_name text,
    email text NOT NULL UNIQUE,
    phone text,
    location_id bigint NOT NULL REFERENCES analytics.dim_location(location_id)
);

CREATE TABLE analytics.dim_product_category (
    category_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_category text NOT NULL,
    pet_category text NOT NULL,
    UNIQUE (product_category, pet_category)
);

CREATE TABLE analytics.dim_product (
    product_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_product_id bigint NOT NULL UNIQUE,
    product_name text NOT NULL,
    category_id bigint NOT NULL REFERENCES analytics.dim_product_category(category_id),
    supplier_id bigint NOT NULL REFERENCES analytics.dim_supplier(supplier_id),
    price numeric(12, 2) NOT NULL,
    stock_quantity integer NOT NULL,
    weight numeric(12, 2),
    color text,
    size text,
    brand text,
    material text,
    description text,
    rating numeric(3, 1),
    reviews integer,
    release_date date,
    expiry_date date
);

CREATE TABLE analytics.dim_date (
    date_id integer PRIMARY KEY,
    full_date date NOT NULL UNIQUE,
    day_of_month smallint NOT NULL,
    month_number smallint NOT NULL,
    month_name text NOT NULL,
    quarter_number smallint NOT NULL,
    year_number smallint NOT NULL,
    day_of_week smallint NOT NULL,
    day_name text NOT NULL
);

CREATE TABLE analytics.fact_sales (
    sale_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source_row_id bigint NOT NULL UNIQUE,
    source_sale_id integer NOT NULL,
    customer_id bigint NOT NULL REFERENCES analytics.dim_customer(customer_id),
    seller_id bigint NOT NULL REFERENCES analytics.dim_seller(seller_id),
    product_id bigint NOT NULL REFERENCES analytics.dim_product(product_id),
    store_id bigint NOT NULL REFERENCES analytics.dim_store(store_id),
    date_id integer NOT NULL REFERENCES analytics.dim_date(date_id),
    quantity integer NOT NULL,
    total_price numeric(12, 2) NOT NULL
);

CREATE INDEX fact_sales_customer_id_idx ON analytics.fact_sales(customer_id);
CREATE INDEX fact_sales_seller_id_idx ON analytics.fact_sales(seller_id);
CREATE INDEX fact_sales_product_id_idx ON analytics.fact_sales(product_id);
CREATE INDEX fact_sales_store_id_idx ON analytics.fact_sales(store_id);
CREATE INDEX fact_sales_date_id_idx ON analytics.fact_sales(date_id);
