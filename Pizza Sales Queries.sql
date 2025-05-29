# 1) Retrieve the total number of orders placed.
SELECT COUNT(Order_ID) AS Total_Orders FROM pizzahut.orders;

# 2) Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(orders_details.quantity * pizzas.price),2) AS Total_Sales
FROM pizzahut.orders_details
JOIN pizzahut.pizzas ON pizzas.pizza_id = orders_details.pizza_id;

# 3) Identify the highest-priced pizza.
SELECT pizza_types.name, pizzas.price
FROM pizzahut.pizzas
JOIN pizzahut.pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

# 4) Identify the most common pizza size ordered.
SELECT pizzas.size, COUNT(orders_details.order_details_id) AS Order_Count
FROM pizzahut.pizzas
JOIN pizzahut.orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.size
ORDER BY Order_Count DESC;

# 5) List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name, SUM(orders_details.quantity) AS Quantity
FROM pizzahut.pizza_types JOIN pizzahut.pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN pizzahut.orders_details ON orders_details.pizza_id = pizzas.pizza_id 
GROUP BY pizza_types.name
ORDER BY Quantity DESC
LIMIT 5;

# 6) Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category, SUM(orders_details.quantity) AS Quantity
FROM pizzahut.pizza_types JOIN pizzahut.pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN pizzahut.orders_details ON orders_details.pizza_id = pizzas.pizza_id 
GROUP BY pizza_types.category
ORDER BY Quantity DESC;

# 7) Determine the distribution of orders by hour of the day.
SELECT HOUR(orders.order_time) AS Hour,COUNT(orders.Order_ID) AS Orders_Count
FROM pizzahut.orders
GROUP BY HOUR(orders.order_time);

# 8) Join relevant tables to find the category-wise distribution of pizzas.
SELECT pizza_types.category, COUNT(pizza_types.name)
FROM pizzahut.pizza_types
GROUP BY pizza_types.category;

# 9) Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(Quantity), 0) AS Avg_Pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(orders_details.quantity) AS Quantity
    FROM
        pizzahut.orders
    JOIN pizzahut.orders_details ON orders.order_id = orders_details.order_id
    GROUP BY orders.order_date) AS order_quantity;

# 10) Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.name, SUM(orders_details.quantity * pizzas.price) AS Revenue
FROM pizzahut.pizza_types
JOIN pizzahut.pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN pizzahut.orders_details ON pizzas.Pizza_id = orders_details.Pizza_id
GROUP BY pizza_types.name
ORDER BY Revenue DESC
LIMIT 3;

# 11) Calculate the percentage contribution of each pizza type to total revenue.
SELECT pizza_types.category, 
ROUND(SUM(orders_details.quantity * pizzas.price)  / (SELECT 
     ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS Total_Sales
FROM
    pizzahut.orders_details
        JOIN
    pizzahut.pizzas ON pizzas.pizza_id = orders_details.pizza_id) *100,2) AS Revenue
FROM pizzahut.pizza_types
JOIN pizzahut.pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN pizzahut.orders_details ON pizzas.Pizza_id = orders_details.Pizza_id
GROUP BY pizza_types.category
ORDER BY REVENUE DESC;

# 12) Analyze the cumulative revenue generated over time
SELECT 
    orders.order_date,
    ROUND(SUM(SUM(orders_details.quantity * pizzas.price)) OVER (ORDER BY orders.order_date), 2) AS Cumulative_Revenue
FROM pizzahut.orders_details
JOIN pizzahut.pizzas ON orders_details.pizza_id = pizzas.pizza_id 
JOIN pizzahut.orders ON orders_details.order_id = orders.order_id
GROUP BY orders.order_date
ORDER BY orders.order_date;

# 13) Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT category, name, revenue
FROM
(SELECT category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
FROM
(SELECT pizza_types.category, pizza_types.name, SUM(orders_details.quantity * pizzas.price) AS Revenue
FROM pizzahut.orders_details
JOIN pizzahut.pizzas ON orders_details.pizza_id = pizzas.pizza_id
JOIN pizzahut.pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category, pizza_types.name) AS a) as b
WHERE rn <= 3;




