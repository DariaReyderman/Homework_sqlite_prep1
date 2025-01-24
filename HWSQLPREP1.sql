CREATE TABLE category (
	category_id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL
);

CREATE TABLE orders (
	order_id INTEGER PRIMARY KEY AUTOINCREMENT,
	date_time TEXT NOT NULL,
	address TEXT NOT NULL,
	customer_name TEXT NOT NULL,
	customer_ph INTEGER UNIQUE NOT NULL,
	total_price REAL NOT NULL
);

-- ONE TO MANY
CREATE TABLE products (
	product_id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	price REAL NOT NULL,
	category_id INTEGER,
	FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- ONE TO MANY
CREATE TABLE nutritions (
	nutrition_id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	calories INTEGER NOT NULL,
	fats NUMERIC NOT NULL,
	sugar NUMERIC NOT NULL,
	product_id INTEGER,
	FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- MANY TO MANY
CREATE TABLE products_orders (
	order_id INTEGER NOT NULL,
	product_id INTEGER NOT NULL,
	amount INTEGER NOT NULL,
	PRIMARY KEY(order_id, product_id),
	FOREIGN KEY (order_id) REFERENCES orders(order_id),
	FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- d.i
SELECT p.name AS product_name,
	   n.calories AS calories,
	   n.fats AS fats,
	   n.sugar AS sugar,
	   c.name AS category_name
FROM products p
LEFT JOIN nutritions n ON p.product_id = n.product_id
LEFT JOIN category c ON p.category_id = c.category_id;

-- d.ii
SELECT o.order_id AS order_id,
	   o.date_time AS date_time,
	   o.address AS address,
	   o.customer_name AS customer_name,
	   o.customer_ph AS ph_number,
	   o.total_price AS total_price,
	   p.name AS prod_name,
	   p.price AS prod_price
FROM products_orders po
LEFT JOIN orders o ON po.order_id = o.order_id
LEFT JOIN products p ON po.product_id = p.product_id;

-- d.iii
INSERT OR IGNORE INTO products_orders (order_id, product_id, amount)
SELECT order_id, 19 AS product_id, 1 AS amount
FROM orders;

-- d.iv
UPDATE orders
SET total_price = (
    SELECT SUM(po.amount * p.price)
    FROM products_orders po
    JOIN products p ON po.product_id = p.product_id
    WHERE po.order_id = orders.order_id
);

-- d.v
SELECT order_id, MAX(total_price) AS max FROM orders;
SELECT order_id, MIN(total_price) AS min FROM orders;
SELECT printf('%,.2f', AVG(total_price)) AS avg_price
FROM orders;

-- d.vi
SELECT o.customer_name, COUNT(po.order_id) AS order_count
FROM orders o
LEFT JOIN products_orders po ON o.order_id = po.order_id
GROUP BY o.customer_name
ORDER BY order_count DESC LIMIT 1;

-- d.vii
SELECT p.name, COUNT(po.product_id) AS order_count
FROM products p
LEFT JOIN products_orders po ON p.product_id = po.product_id
GROUP BY p.name
ORDER BY order_count DESC;

SELECT COUNT(po.amount) AS total_amount,
printf('%,.2f', AVG(po.amount)) AS avg
FROM products_orders po;

-- d.viii
SELECT c.name AS category_name, SUM(po.amount) AS total_sold
FROM products_orders po
LEFT JOIN products p ON po.product_id = p.product_id
LEFT JOIN category c ON p.category_id = c.category_id
GROUP BY c.name
ORDER BY total_sold DESC;

-- d.ix *Bonus
SELECT p.name AS product_name,
COUNT(po.order_id) AS order_count
FROM products_orders po
LEFT JOIN products p ON po.product_id = p.product_id
GROUP BY p.name
ORDER BY order_count DESC
LIMIT 1;