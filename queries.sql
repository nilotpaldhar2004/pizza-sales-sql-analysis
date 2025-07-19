-- 1. Total number of orders 

SELECT 
    COUNT(DISTINCT order_id) AS total_orders
FROM
    orders; 
    
-- 2. Total revenue from pizza sales 

SELECT 
    ROUND(SUM(pizzas.price * order_details.quantity),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
-- 3. Highest-priced pizza 

SELECT name, price 
FROM pizzas 
ORDER BY price DESC 
LIMIT 1; 
-- 4. Most common pizza size ordered 
SELECT 
    size, COUNT(*) AS count
FROM
    pizzas
GROUP BY size
ORDER BY count DESC
LIMIT 1;-- 5. Top 5 most ordered pizza types 
SELECT 
    pizzas.name, SUM(order_details.quantity) AS total_quantity
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.name
ORDER BY total_quantity DESC
LIMIT 5;

-- 6. Total quantity per pizza category 

SELECT 
    categories.category_name,
    SUM(order_details.quantity) AS total_quantity
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    categories ON pizzas.category_id = categories.category_id
GROUP BY categories.category_name;-- 7. Order distribution by hour 
SELECT 
    HOUR(order_time) AS hour, COUNT(*) AS order_count
FROM
    orders
GROUP BY hour
ORDER BY hour;

 -- 8. Category-wise pizza distribution 
 
SELECT 
    categories.category_name,
    COUNT(pizzas.pizza_id) AS total_pizzas
FROM
    pizzas
        JOIN
    categories ON pizzas.category_id = categories.category_id
GROUP BY categories.category_name;

 -- 9. Average number of pizzas ordered per day 
 
SELECT 
    order_date, AVG(quantity) AS avg_pizzas
FROM
    order_details
        JOIN
    orders ON order_details.order_id = orders.order_id
GROUP BY order_date; 

-- 10. Top 3 pizzas by revenue 

SELECT 
    pizzas.name,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.name
ORDER BY revenue DESC
LIMIT 3; 

 -- 11. Percentage contribution of each pizza to total revenue 
 
SELECT 
    pizzas.name,
    ROUND(SUM(pizzas.price * order_details.quantity) * 100.0 / (SELECT 
                    SUM(pizzas.price * order_details.quantity)
                FROM
                    order_details
                        JOIN
                    pizzas ON order_details.pizza_id = pizzas.pizza_id),
            2) AS revenue_percent
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.name
ORDER BY revenue_percent DESC; 

 -- 12. Cumulative revenue over time 
 
SELECT order_date, 
       SUM(pizzas.price * order_details.quantity) AS daily_revenue, 
       SUM(SUM(pizzas.price * order_details.quantity)) OVER (ORDER BY order_date) AS 
cumulative_revenue 
FROM orders 
JOIN order_details ON orders.order_id = order_details.order_id 
JOIN pizzas ON order_details.pizza_id = pizzas.pizza_id 
GROUP BY order_date; 

 -- 13. Top 3 pizzas by revenue in each category 
 
SELECT category_name, name, revenue FROM ( 
    SELECT c.category_name, p.name, 
           SUM(p.price * od.quantity) AS revenue, 
           ROW_NUMBER() OVER (PARTITION BY c.category_name ORDER BY SUM(p.price * od.quantity) 
DESC) AS rank 
    FROM order_details od 
    JOIN pizzas p ON od.pizza_id = p.pizza_id 
    JOIN categories c ON p.category_id = c.category_id 
GROUP BY c.category_name, p.name 
) AS ranked 
WHERE rank <= 3;