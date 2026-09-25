PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS dim_customers (
    customer_id TEXT PRIMARY KEY,
    customer_city TEXT,
    customer_state TEXT
);


CREATE TABLE IF NOT EXISTS dim_products (
    product_id TEXT PRIMARY KEY,
    category_name TEXT
);

CREATE TABLE IF NOT EXISTS dim_sellers (
    seller_id TEXT PRIMARY KEY,
    seller_city TEXT,
    seller_state TEXT
);

CREATE TABLE IF NOT EXISTS dim_date (
    date_key TEXT PRIMARY KEY,
    year INTEGER,
    month INTEGER,
    name_month TEXT
);

CREATE TABLE IF NOT EXISTS fact_orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT,
    order_status TEXT,
    
    FOREIGN KEY (customer_id) REFERENCES dim_customers (customer_id)
);

CREATE TABLE IF NOT EXISTS fact_order_items (
    item_id INTEGER PRIMARY KEY,
    order_id TEXT,
    product_id TEXT,
    seller_id TEXT,
    purchase_date TEXT,
    price REAL,
    freight_value REAL,
    total_value REAL,

    FOREIGN KEY (order_id) REFERENCES fact_orders (order_id),
    FOREIGN KEY (product_id) REFERENCES dim_products (product_id),
    FOREIGN KEY (seller_id) REFERENCES dim_sellers (seller_id),
    FOREIGN KEY (purchase_date) REFERENCES dim_date (date_key)
);