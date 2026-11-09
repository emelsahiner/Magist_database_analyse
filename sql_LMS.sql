/*Question 1*/
select count(*) 
from orders; 

/*Question 2*/
select order_status, count(*) 
from orders 
group by order_status;

/*Question 3*/
select Year(order_purchase_timestamp),
	   Month (order_purchase_timestamp),
       count(customer_id)
from orders 
group by Year(order_purchase_timestamp), Month (order_purchase_timestamp)
order by Year(order_purchase_timestamp), Month (order_purchase_timestamp);

/*Question 4*/
select count(distinct product_id)
from products;

/*Question 5*/
select product_category_name, count(distinct product_id)
from products
group by product_category_name
order by count(product_id) desc;

/*Question 6*/
select count(distinct product_id)
from order_items;

/*Question 7*/
select max(price), min(price)
from order_items;

/*Question 8*/
select max(payment_value), min(payment_value)
from order_payments;

Maximum someone has paid for an order:

select sum(payment_value)
from order_payments
group by order_id
order by sum(payment_value) desc
limit 1;