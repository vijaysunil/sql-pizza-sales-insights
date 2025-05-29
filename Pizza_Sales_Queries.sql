-- 🍕 Pizza Sales Analysis - SQL Project
-- Description: Contains SQL queries to analyze pizza sales data,
-- organized by Basic, Intermediate, and Advanced levels.
-- Database: pizzahut

-- ===================================================
-- 🔹 BASIC QUERIES
-- ===================================================

-- 1. Total number of orders placed
SELECT COUNT(order_id) AS total_orders 
FROM pizzahut.orders;

-- 2. Total revenue generated from pizza sales
SELECT ROUND(SUM(orders_details.quantity * pizzas.price), 2) AS total_sales
FROM pizzahut.orders_details
JOIN pizzahut.pizzas ON pizzas.pizza_id = orders_details.pizza_id;

-- 3. Highest-priced pizza
SELECT pizza_types.name, pizzas.price
FROM pizzahut.pizzas
JOIN pizzahut.pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4. Most common pizza size ordered
SELECT pizzas.size, COUNT(orders_details.order_details_id) AS order_count
FROM pizzahut.pizzas
JOIN pizzahut.orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- 5. Top 5 most ordered pizza types by quantity
SELECT pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM pizzahut.pizza_types
JOIN pizzahut.pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN pizzahut.orders_details ON orders_details.pizza_id = pizzas.pizza_id 
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;


-- ===================================================
-- 🔸 INTERMEDIATE QUERIES
-- ===================================================

-- 6. Total quantity of each pizza category ordered
SELECT pizza_types.category, SUM(orders_details.quantity) AS quantity
FROM pizzahut.pizza_types
JOIN pizzahut.pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN pizzahut.orders_details ON orders_details.pizza_id = pizzas.pizza_id 
GROUP BY pizza_types.category
ORDER BY quantity DESC;

-- 7. Order distribution by hour of day
SELECT HOUR(orders.order_time) AS hour, COUNT(order_id) AS orders_count
FROM pizzahut.orders
GROUP BY HOUR(orders.order_time);

-- 8. Category-wise distribution of pizzas
SELECT pizza_types.category, COUNT(pizza_types.name) AS pizza_count
FROM pizzahut.pizza_types
GROUP BY pizza_types.category;

-- 9. Average number of pizzas ordered per day
SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizzas_per_day
FROM (
    SELECT orders.order_date, SUM(orders_details.quantity) AS quantity
    FROM pizzahut.orders
    JOIN pizzahut.orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date
) AS daily_totals;

-- 10. Top 3 pizza types based on revenue
SELECT pizza_types.name, SUM(orders_details.quantity * pizzas.price) AS revenue
FROM pizzahut.pizza_types
JOIN pizzahut.pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN pizzahut.orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- ===================================================
-- 🔺 ADVANCED QUERIES
-- ===================================================

-- 11. Revenue percentage contribution by pizza category
SELECT pizza_types.category, 
    ROUND(SUM(orders_details.quantity * pizzas.price) * 100 / (
        SELECT SUM(orders_details.quantity * pizzas.price)
        FROM pizzahut.orders_details
        JOIN pizzahut.pizzas ON pizzas.pizza_id = orders_details.pizza_id
    ), 2) AS revenue_percentage
FROM pizzahut.pizza_types
JOIN pizzahut.pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN pizzahut.orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue_percentage DESC;

-- 12. Cumulative revenue over time
SELECT 
    orders.order_date,
    ROUND(SUM(SUM(orders_details.quantity * pizzas.price)) OVER (ORDER BY orders.order_date), 2) AS cumulative_revenue
FROM pizzahut.orders_details
JOIN pizzahut.pizzas ON orders_details.pizza_id = pizzas.pizza_id 
JOIN pizzahut.orders ON orders_details.order_id = orders.order_id
GROUP BY orders.order_date
ORDER BY orders.order_date;

-- 13. Top 3 pizza types by revenue for each category
SELECT category, name, revenue
FROM (
    SELECT 
        category, 
        name, 
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_within_category
    FROM (
        SELECT 
            pizza_types.category, 
            pizza_types.name, 
            SUM(orders_details.quantity * pizzas.price) AS revenue
        FROM pizzahut.orders_details
        JOIN pizzahut.pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN pizzahut.pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        GROUP BY pizza_types.category, pizza_types.name
    ) AS category_revenues
) AS ranked_pizzas
WHERE rank_within_category <= 3;
