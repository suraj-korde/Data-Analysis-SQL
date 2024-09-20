create database pizzahut;

use pizzahut;

-- select * from pizzas;

-- select * from pizza_types;

-- Basic:


-- Retrieve the total number of orders placed 

select count(order_id) as  TotalOrders from orders;

-- Calculate the total revenue generated from pizza sales.

select 
round(sum(order_details.quantity * pizzas.price),2) as total_sales
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id;

-- Identify the highest-priced pizza.

select  pizza_types.name, pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1;

-- Identify the most common pizza size ordered.

select pizzas.size, count(order_details.order_details_id) as Order_count
from pizzas join order_details 
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size order by Order_count desc;

-- List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name,
sum(order_details.quantity) as Quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by Quantity desc limit 5;


-- Intermediate:

-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category,
sum(order_details.quantity) as Quantity 
from pizza_types join pizzas
on pizza_types.pizza_type_id= pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by Quantity desc;


-- Determine the distribution of orders by hour of the day.

 select HOUR(time) as hours, count(order_id) as Order_count from orders
 group by HOUR(time);


-- Join relevant tables to find the category-wise distribution of pizzas.

select category , count(name) from pizza_types
group by category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),0) as Avg_Pizza_Ordered_Per_Day from 
(select orders.date, sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id= order_details.order_id
group by orders.date) as Order_Quantity;


-- Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name as Name, sum(order_details.quantity * pizzas.price) as Revenue 
from pizza_types join pizzas 
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by Revenue desc limit 3;


-- Advanced:

-- Calculate the percentage contribution of each pizza type to total revenue.


select pizza_types.category As Category, 
round(sum(order_details.quantity * pizzas.price)/ (select 
round(sum(order_details.quantity * pizzas.price),2) as total_sales
from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id)*100,2) Revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by Revenue desc;


-- Analyze the cumulative revenue generated over time.
select date,
sum(Revenue) over (order by date) as cum_revenue
from 
(select orders.date,
sum(order_details.quantity * pizzas.price) as Revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.date) as Sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from 
(select pizza_types.category, pizza_types.name,
sum((order_details.quantity)* pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id =pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as A

