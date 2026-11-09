/*Total sellers_tech_sellers_ratio*/
SELECT 
    -- 1. Toplam satıcı sayısı
    COUNT(DISTINCT s.seller_id) AS total_sellers,
    
    -- 2. Tech (Teknoloji) kategorisinde ürünü olan satıcı sayısı
    COUNT(DISTINCT CASE 
        WHEN pct.product_category_name_english IN ('audio' , 'consoles_games',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony') 
        THEN s.seller_id 
    END) AS tech_sellers,
    
    -- 3. Tech satıcılarının tüm satıcılara oranı (%)
    (COUNT(DISTINCT CASE 
        WHEN pct.product_category_name_english IN ('audio' , 'consoles_games',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony') 
        THEN s.seller_id 
    END) * 100.0) / COUNT(DISTINCT s.seller_id) AS percentage_tech_sellers

FROM 
    sellers s
LEFT JOIN 
    order_items oi ON s.seller_id = oi.seller_id
LEFT JOIN 
    products p ON oi.product_id = p.product_id
LEFT JOIN 
    product_category_name_translation pct ON p.product_category_name = pct.product_category_name;

/*what is the most ordered product category?*/
SELECT 
    COUNT(o.order_id) as total_order,
    pc.product_category_name_english as product_category_name
FROM
    order_items o
        LEFT JOIN
    products p ON p.product_id = o.product_id
        LEFT JOIN
    product_category_name_translation pc ON pc.product_category_name = p.product_category_name
GROUP BY pc.product_category_name_english
ORDER BY total_order DESC;

/*which seller has the highest and lowest sale?*/
SELECT 
    distinct s.seller_id,
    s.seller_zip_code_prefix,
    g.city,
    g.state,
    COUNT(o.order_id) as total_order
FROM
    sellers s
        LEFT JOIN
    order_items o ON s.seller_id = o.seller_id
        LEFT JOIN
    geo g ON g.zip_code_prefix = s.seller_zip_code_prefix
GROUP BY s.seller_id , s.seller_zip_code_prefix
ORDER BY COUNT(o.order_id) DESC;

/*which custumer has the highest and lowest payment?*/
SELECT 
    c.customer_id AS customers,
    SUM(oi.price) AS total_order_price,
	g.city,
    g.state
FROM
    customers c
        LEFT JOIN
    orders o ON c.customer_id = o.customer_id
        LEFT JOIN
    order_items oi ON o.order_id = oi.order_id
     LEFT JOIN
    geo g ON g.zip_code_prefix = c.customer_zip_code_prefix
GROUP BY c.customer_id
ORDER BY SUM(oi.price) DESC;

/*which custumer has the highest and lowest total order?*/
SELECT 
    c.customer_id AS customers,
    COUNT(oi.order_id) AS total_order_count
FROM
    customers c
        LEFT JOIN
    orders o ON c.customer_id = o.customer_id
        LEFT JOIN
    order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id
ORDER BY COUNT(oi.order_id) DESC;

/*what is the average priceoverall?*/
SELECT 
    round(AVG(price)) AS average_price
FROM
    order_items ;
 
    
/*what is the average price in every category?*/
SELECT 
    pc.product_category_name_english as category,
    round(AVG(o.price)) AS average_price
FROM
    order_items o
        JOIN
    products p ON p.product_id = o.product_id
        LEFT JOIN
    product_category_name_translation pc ON pc.product_category_name = p.product_category_name
    group by pc.product_category_name_english
    order by average_price desc;

/*What’s the average time for tech categories between the order being placed and the product being delivered?*/
SELECT 
    AVG(DATEDIFF(order_delivered_customer_date,  order_purchase_timestamp)) as average_delivered_time
FROM
   orders o
    
Left join order_items oi
on
o.order_id=oi.order_id
left join 
products p ON p.product_id = oi.product_id
        LEFT JOIN
    product_category_name_translation pc ON pc.product_category_name = p.product_category_name
    
    WHERE
    pc.product_category_name_english IN ('audio' , 'consoles_games',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony')
and
    order_status = 'delivered';
    
/*Customer reviews for all category*/

SELECT 
    round(avg(orev.review_score), 2) as av_review_score,
    pc.product_category_name_english,
    COUNT(distinct orev.order_id) AS review_count
FROM
    order_reviews orev
        INNER JOIN
    order_items oi ON orev.order_id = oi.order_id
        INNER JOIN
    products p ON oi.product_id = p.product_id
        INNER JOIN
    product_category_name_translation pc ON p.product_category_name = pc.product_category_name
GROUP BY pc.product_category_name_english
ORDER BY av_review_score DESC;

/*Customer reviews for tech category*/

SELECT 
    pc.product_category_name_english as tech_category,
    count(distinct orev.review_id) as total_reviews,
	round(avg(orev.review_score) , 2)  as avg_review_score
FROM
    order_reviews orev
        INNER JOIN
    order_items oi ON orev.order_id = oi.order_id
        INNER JOIN
    products p ON oi.product_id = p.product_id
        INNER JOIN
    product_category_name_translation pc ON p.product_category_name = pc.product_category_name
     WHERE
    pc.product_category_name_english IN ('audio' , 'consoles_games',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony')
GROUP BY pc.product_category_name_english
ORDER BY avg_review_score DESC;

/*In tech categories what is the total revenue and total sales?*/
SELECT 
    pc.product_category_name_english AS tech_category,
    COUNT(DISTINCT oi.order_id) AS total_sales_count,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
  
FROM
    order_items oi
        INNER JOIN
    products p ON oi.product_id = p.product_id
        INNER JOIN
    product_category_name_translation pc ON p.product_category_name = pc.product_category_name

WHERE
    pc.product_category_name_english IN ('audio' , 'consoles_games',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony')
GROUP BY pc.product_category_name_english
ORDER BY total_revenue DESC;

/*Customer Loyalty/Repeat Purchases*/
SELECT 
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count
FROM
    orders o
        JOIN
    customers c ON o.customer_id = c.customer_id
        JOIN
    order_items oi ON o.order_id = oi.order_id
        JOIN
    products p ON oi.product_id = p.product_id
        JOIN
    product_category_name_translation pct ON p.product_category_name = pct.product_category_name
WHERE
    pct.product_category_name_english IN ('audio' , 'computers_accessories',
        'electronics',
        'computers',
        'tablets_printing_image',
        'telephony')
GROUP BY c.customer_unique_id
HAVING order_count > 1 
ORDER BY order_count DESC ;

/*yy*/
SELECT
oi.seller_id,

  t.product_category_name_english AS category,

  COUNT(DISTINCT o.order_id) AS orders,

  SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date

           THEN 1 ELSE 0 END) AS late_orders,

  ROUND(100 * SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date

                       THEN 1 ELSE 0 END) / COUNT(*), 1) AS late_percent,

  AVG(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date

           THEN DATEDIFF(o.order_delivered_customer_date,

                         o.order_estimated_delivery_date) END) AS avg_delay_days

FROM orders o

JOIN order_items oi ON oi.order_id = o.order_id

JOIN products p ON p.product_id = oi.product_id

JOIN product_category_name_translation t

  ON t.product_category_name = p.product_category_name

WHERE o.order_status = 'delivered'

  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY oi.seller_id, t.product_category_name_english

HAVING COUNT(DISTINCT o.order_id) >= 20

ORDER BY late_orders DESC

LIMIT 20;

/*category_orders_late_orders_late_percent_avg_delays*/
SELECT

  t.product_category_name_english AS category,

  COUNT(DISTINCT o.order_id) AS orders,

  COUNT(DISTINCT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date

        THEN o.order_id END) AS late_orders,

  ROUND(100 * COUNT(DISTINCT CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date

        THEN o.order_id END) / COUNT(DISTINCT o.order_id), 1) AS late_percent,

  AVG(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date

        THEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) END) AS avg_delay_days

FROM orders o

JOIN order_items oi ON oi.order_id = o.order_id

JOIN products p ON p.product_id = oi.product_id

JOIN product_category_name_translation t ON t.product_category_name = p.product_category_name

WHERE o.order_status = 'delivered'

  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY t.product_category_name_english

HAVING COUNT(DISTINCT o.order_id) >= 50;