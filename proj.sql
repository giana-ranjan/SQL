create database pizzahut;
use  pizzahut;
create table orders (
order_id int not null primary key,
order_date date not null,
order_time time not null);
select * from orders;
create table orders_details (
order_details_id int not null primary key,
order_id int not null,
pizza_id text not null,
quantity int not null);

drop table orders_details;
create table order_details (
order_details_id int not null primary key,
order_id int not null,
pizza_id text not null,
quantity int not null);
-- Retrieve totalno.of orders

select count(order_id) from orders;

-- calculate total rev generated from pizza sales

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),2)
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- identify highest priced pizza
select pizza_types.name, pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
where pizzas.price = (select max(price) from pizzas);

-- maximum pizza type ordered
SELECT 
    pizzas.size, COUNT(order_details.order_details_id)
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY COUNT(order_details.order_details_id) DESC
LIMIT 1;

-- list the top 5 most ordered pizza types along w their quantities
select pizza_types.name, pizzas.pizza_type_id 
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_types.name, pizzas.pizza_type_id
order by COUNT(order_details.order_details_id) desc
limit 5;

-- join the necessary tables to find total quantity of each pizza ordered
select pizza_types.category, sum(order_details.quantity)
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by sum(order_details.quantity) desc;

-- group orders by date and calculate avg no. of pizzas ordered per day

SELECT 
    ROUND(AVG(quantity), 0)
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
    -- determine top 3 most ordered pizza types based on revenue
    
SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS revenue
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- calculate the percentage contribution of each pizza type to total revenue
SELECT 
    pizza_types.category,
    round(SUM(order_details.quantity*pizzas.price)/(select round(SUM(order_details.quantity * pizzas.price),2) as totalsales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,2) as revenue
FROM
    pizzas
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY pizza_types.category order by revenue desc;

-- analyse cumulative revenue over time
select order_date,
sum(revenue) over (order by order_date)
from
(select orders.order_date,
SUM(order_details.quantity*pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

-- determine the top 3 most ordered pizza types based on rev for each category

select name, revenue from
(select category, name, revenue,
rank() over (partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity)*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <=3;