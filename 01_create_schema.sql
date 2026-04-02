-- ============================================================
-- Retail Analytics — MySQL Schema
-- Tables: regions, customers, categories, products, orders,
--         order_items, returns
-- ============================================================

CREATE DATABASE IF NOT EXISTS retail_analytics;
USE retail_analytics;

-- 1. Regions
CREATE TABLE regions (
    region_id   INT          PRIMARY KEY AUTO_INCREMENT,
    region_name VARCHAR(50)  NOT NULL,
    country     VARCHAR(50)  NOT NULL DEFAULT 'India'
);

-- 2. Customers
CREATE TABLE customers (
    customer_id   INT           PRIMARY KEY AUTO_INCREMENT,
    full_name     VARCHAR(100)  NOT NULL,
    email         VARCHAR(120)  UNIQUE NOT NULL,
    phone         VARCHAR(20),
    city          VARCHAR(60),
    region_id     INT           NOT NULL,
    signup_date   DATE          NOT NULL,
    FOREIGN KEY (region_id) REFERENCES regions(region_id)
);

-- 3. Categories
CREATE TABLE categories (
    category_id   INT          PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(60)  NOT NULL,
    parent_category VARCHAR(60)
);

-- 4. Products
CREATE TABLE products (
    product_id    INT           PRIMARY KEY AUTO_INCREMENT,
    product_name  VARCHAR(120)  NOT NULL,
    category_id   INT           NOT NULL,
    unit_price    DECIMAL(10,2) NOT NULL,
    cost_price    DECIMAL(10,2) NOT NULL,
    stock_qty     INT           DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

-- 5. Orders
CREATE TABLE orders (
    order_id      INT           PRIMARY KEY AUTO_INCREMENT,
    customer_id   INT           NOT NULL,
    order_date    DATE          NOT NULL,
    status        ENUM('Completed','Pending','Cancelled') DEFAULT 'Completed',
    payment_mode  VARCHAR(30),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 6. Order Items
CREATE TABLE order_items (
    item_id       INT           PRIMARY KEY AUTO_INCREMENT,
    order_id      INT           NOT NULL,
    product_id    INT           NOT NULL,
    quantity      INT           NOT NULL,
    unit_price    DECIMAL(10,2) NOT NULL,
    discount_pct  DECIMAL(5,2)  DEFAULT 0.00,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- 7. Returns
CREATE TABLE returns (
    return_id     INT           PRIMARY KEY AUTO_INCREMENT,
    order_id      INT           NOT NULL,
    product_id    INT           NOT NULL,
    return_date   DATE          NOT NULL,
    reason        VARCHAR(120),
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Indexes for query performance
CREATE INDEX idx_orders_date        ON orders(order_date);
CREATE INDEX idx_orders_customer    ON orders(customer_id);
CREATE INDEX idx_items_order        ON order_items(order_id);
CREATE INDEX idx_items_product      ON order_items(product_id);
CREATE INDEX idx_customers_region   ON customers(region_id);
CREATE INDEX idx_products_category  ON products(category_id);
