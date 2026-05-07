1.-- Retrieve the total number of orders placed.

SELECT count(order_id) AS total_orders
FROM orders;


2.-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(p.price * o.quantity), 2) AS Total_revenue
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id;


3. -- Identify the highest-priced pizza.

SELECT 
    t.name, p.price AS higheshprice
FROM
    pizza_types t
        JOIN
    pizzas p ON t.pizza_type_id = p.pizza_type_id
ORDER BY higheshprice DESC
LIMIT 1;

4.-- Identify the most common pizza size ordered.

SELECT 
    p.size, COUNT(o.order_details_id) AS order_count
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
GROUP BY size
ORDER BY order_count DESC
LIMIT 1;


5.-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    p.name, SUM(o.quantity) AS Total_quantity
FROM
    pizza_types p
        JOIN
    pizzas S ON p.pizza_type_id = S.pizza_type_id
        JOIN
    order_details o ON o.pizza_id = S.pizza_id
GROUP BY name
ORDER BY Total_quantity DESC
LIMIT 5;


6.-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS Total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.Pizza_id
GROUP BY pizza_types.category
ORDER BY Total_quantity DESC;


7. -- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time), COUNT(order_id) AS total_count
FROM
    orders
GROUP BY HOUR(Order_time)
ORDER BY total_count DESC;


8. -- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS total_category_count
FROM
    pizza_types
GROUP BY category
ORDER BY total_category_count DESC;


9. -- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(total_count), 0) AS avg_ordered_per_day
FROM
    (SELECT 
        orders.order_date AS order_by_date,
            SUM(order_details.quantity) AS total_count
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY order_by_date) AS total_ordered_per_day;


10. -- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS total_revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizza_types.name
ORDER BY total_revenue DESC
LIMIT 3;


11. -- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category AS pizza_type,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    SUM(order_details.quantity * pizzas.price)
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id),
            2) * 100 AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.Pizza_id = pizzas.pizza_id
GROUP BY pizza_type
ORDER BY revenue DESC;


12.-- Analyze the cumulative revenue generated over time.

select order_date, sum(revenue) over (order by order_date) as cum_revenue
From
(select orders.order_date, sum(order_details.Quantity*pizzas.price) as revenue
from orders
join order_details
on order_details.order_id=orders.Order_id
join pizzas
on pizzas.pizza_id=order_details.Pizza_id
group by orders.order_date) as daily_revenue;


13.-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, category, revenue
from
(select name,category,revenue,
rank() over (partition by category order by revenue desc) as rn
from
(select pizza_types.name,pizza_types.category, sum(order_details.quantity*pizzas.price) as revenue
from pizza_types
join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.Pizza_id=pizzas.pizza_id
group by pizza_types.name,pizza_types.category) as a) as b
where rn<=3;

