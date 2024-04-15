Create Database pizzahut;
create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id) );

-- Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales.
select
round(sum(order_details.quantity * pizzas.price), 2) as total_sales
from order_details join pizzas on
pizzas.pizza_id = order_details.pizza_id;

-- Identify the highest-priced pizza.
select pizza_types1.name, pizzas.price
from pizza_types1 join pizzas
on pizza_types1.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1;

-- Identify the most common pizza size ordered.
select pizzas.size, count(order_details.order_details_id) as order_count 
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size order by order_count desc;

-- Join the necessary tables to find the
-- total quantity of each pizza category ordered.

select pizza_types1.category,
sum(order_details.quantity) as quantity
from pizza_types1 join pizzas
on pizza_types1.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types1.category order by quantity desc;

-- Determine the distribution of orders by hour of the day.
SELECT
HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the
-- category-wise distribution of pizzas.
select category, count(name) from pizza_types1
group by category;

-- Group the orders by date and calculate the average
-- number of pizzas ordered per day.
SELECT
ROUND (AVG(quantity), 0) as avg_pizza_ordered_per_day
FROM
(SELECT
orders.order_date, SUM(order_details.quantity) AS quantity
FROM
orders
JOIN order_details ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS order_quantity ;

-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types1.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types1 join pizzas
on pizzas.pizza_type_id = pizza_types1.pizza_type_id
join order_details
on order_details.pizza_id
=
pizzas.pizza_id
group by pizza_types1.name order by revenue desc limit 3;

-- pizza type to total revenue.
select pizza_types1.category,
round(sum(order_details.quantity *pizzas.price) / (SELECT
ROUND(SUM(order_details.quantity * pizzas.price),2)as total_sales
FROM
order_details
JOIN
pizzas ON pizzas.pizza_id = order_details.pizza_id) *100,2) as revenue
from pizza_types1 join pizzas
on pizza_types1.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types1.category order by revenue desc;

-- analyze the cumulative revenue generated over time
select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date,
sum(order_details. quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types
-- based on revenue for each pizza category.
select name, revenue from
(select category, name, revenue,
rank() over (partition by category order by revenue desc) as rn
from
(select pizza_types1.category, pizza_types1.name,
sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types1 join pizzas
on pizza_types1.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types1.category, pizza_types1.name) as a) as b
where rn <= 3;