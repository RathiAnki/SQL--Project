Create Database Pizza_Sales

# Basic:
 Retrieve the total number of orders placed.

Select count(distinct order_id) as total_orders from order_details



--Calculate the total revenue generated from pizza sales.

Select Sum(p.price  * o.quantity) as total_revenue
from Pizzas P
join order_details o
on p.pizza_id =o.pizza_id


-- Identify the highest-priced pizza.

Select top 1 P1.name,P.Price from Pizzas p
join Pizza_types p1
on P.pizza_type_id =P1.pizza_type_id
order by price desc

--Identify the most common pizza size ordered.

Select  top 1 p.size, count(o.order_details_id) as total_pizza_ordered  from Pizzas p
Join order_details o
on P.pizza_id = o.pizza_id
group by p.size
order by total_pizza_ordered desc


--List the top 5 most ordered pizza types along with their quantities.

Select  top 5 p.name,Sum(o.quantity) as pizza_qty
from Pizza_types P
Join Pizzas P1
on p.pizza_type_id =P1.pizza_type_id
Join order_details o
on P1.pizza_id =o.pizza_id
group by p.name
order  by pizza_qty desc


# Intermediate:

--Join the necessary tables to find the total quantity of each pizza category ordered.

Select P.category, Sum(o.quantity)as total_qty
from Pizza_types P
Join pizzas P1
on P.pizza_type_id = p1.pizza_type_id
join order_details o
on P1.pizza_id=o.pizza_id
group by p.category
order by total_qty desc


--Determine the distribution of orders by hour of the day.


Select DATEPART(Hour,o.time)as hour_time, count(distinct o1.order_id)as order_count
from orders o
join order_details o1
on o.order_id =o1.order_id
group by DATEPART(Hour,o.time)
order by order_count


--Join relevant tables to find the category-wise distribution of pizzas.

Select P.category, count( name) as pizza_count
from  Pizza_types P
group by p.category


--Group the orders by date and calculate the average number of pizzas ordered per day.

select avg(total_pizza_order) as avg_piza_order_per_day from
(
Select o.date,SUm(o1.quantity)as total_pizza_order
from orders o
join order_details o1
on o.order_id =o1.order_id
group by o.date )as pizza_qty



--Determine the top 3 most ordered pizza types based on revenue.

Select top 3  p1.name, sum(o.quantity*p.price)as revenue
from order_details o
Join Pizzas p
on p.pizza_id =o.pizza_id
join Pizza_types p1
on p.pizza_type_id=p1.pizza_type_id
group by P1.name
order By revenue desc


# Advanced:

--Calculate the percentage contribution of each pizza type to total revenue.

With revenue_cte as(
Select sum(o.quantity * p.price) as total_revenue
from order_details o
Join Pizzas p
on o.pizza_id =p.pizza_id
)

, pizza_type_revenue as(
Select  p1.category, sum(o.quantity*p.price)as revenue
from order_details o
Join Pizzas p
on p.pizza_id =o.pizza_id
join Pizza_types p1
on p.pizza_type_id=p1.pizza_type_id
group by P1.category)


Select p.category,round(p.revenue /r.total_revenue*100.0,2) as perecent_share
from revenue_cte r
join pizza_type_revenue p
on 1=1


--Analyze the cumulative revenue generated over time.

with daily_revenue_cte as(
Select o1.date , Sum(o.quantity * p.price) as daily_revenue
from order_details  o
join orders o1
on o.order_id =o1.order_id
join Pizzas p
on o.pizza_id =p.pizza_id
group by o1.date
)
Select date,daily_revenue,
sum(daily_revenue)over(order by date rows between unbounded preceding and Current row)
from daily_revenue_cte




--Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with rank_cte as(
select *, rank()over(partition by category order by revenue desc)as rn from (

Select category,p.name ,sum(o.quantity*P1.price)as revenue
from Pizza_types p
join Pizzas p1
on p.pizza_type_id =p1.pizza_type_id
join order_details o
on p1.pizza_id =o.pizza_id
group by category,p.name )a
)

Select category, name,round(revenue,2) from rank_cte
where rn <=3
