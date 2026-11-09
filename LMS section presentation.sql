
/*What categories of tech products does Magist have?*/
SELECT DISTINCT
    pc.product_category_name_english
FROM
    products p
        LEFT JOIN
    product_category_name_translation pc ON pc.product_category_name = p.product_category_name
WHERE
    pc.product_category_name_english IN ('audio' , 'consoles_games',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony');

/*How many products of these tech categories have been sold (within the time window of the database snapshot)? What percentage does that represent from the overall number of products sold?*/

SELECT 
    SUM(CASE
        WHEN
            pc.product_category_name_english IN ('audio' , 'consoles_games',
                'electronics',
                'computers_accessories',
                'pc_gamer',
                'computers',
                'tablets_printing_image',
                'telephony')
        THEN
            1
        ELSE 0
    END) AS tech_product_count,
    COUNT(o.product_id) AS total_product_count,
    (SUM(CASE
        WHEN
            pc.product_category_name_english IN ('audio' , 'consoles_games',
                'electronics',
                'computers_accessories',
                'pc_gamer',
                'computers',
                'tablets_printing_image',
                'telephony')
        THEN
            1
        ELSE 0
    END) * 100.0) / COUNT(o.product_id) AS tech_percentage
FROM
    order_items o
        JOIN
    products p ON p.product_id = o.product_id
        LEFT JOIN
    product_category_name_translation pc ON pc.product_category_name = p.product_category_name;


/*What’s the average price of the products being sold?*/

SELECT 
    round(AVG(o.price)) AS average_price
FROM
    order_items o
        JOIN
    products p ON p.product_id = o.product_id
        LEFT JOIN
    product_category_name_translation pc ON pc.product_category_name = p.product_category_name
WHERE
    pc.product_category_name_english IN ('audio' , 'consoles_games',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony');

/*Are expensive tech products popular?*/

SELECT 
    CASE
        WHEN
            o.price > (SELECT 
                    AVG(o2.price) AS average_price
                FROM
                    order_items o2
                        JOIN
                    products p2 ON p2.product_id = o2.product_id
                        LEFT JOIN
                    product_category_name_translation pc2 ON pc2.product_category_name = p2.product_category_name
                WHERE
                    pc2.product_category_name_english IN ('audio' , 'consoles_games',
                        'electronics',
                        'computers_accessories',
                        'pc_gamer',
                        'computers',
                        'tablets_printing_image',
                        'telephony'))
        THEN
            'Expensive'
        ELSE 'Cheap'
    END AS price_category,
    COUNT(o.product_id) AS total_sold
FROM
    order_items o
        JOIN
    products p ON o.product_id = p.product_id
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
GROUP BY price_category
ORDER BY total_sold DESC;

/*How many months of data are included in the magist database?*/
SELECT 
    COUNT(DISTINCT DATE_FORMAT(order_purchase_timestamp, '%Y-%m')) AS total_months
FROM
    orders;

/*How many sellers are there?*/
SELECT 
    count(distinct seller_id) as total_sellers
FROM
    sellers;
       
/*How many Tech sellers are there?*/

SELECT 
    COUNT(DISTINCT s.seller_id) AS total_tech_sellers
FROM
    sellers s
        JOIN
    order_items oi ON s.seller_id = oi.seller_id
        JOIN
    products p ON oi.product_id = p.product_id
        JOIN
    product_category_name_translation pc ON pc.product_category_name = p.product_category_name
WHERE
    pc.product_category_name_english IN ('audio' , 'consoles_games',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony');
        
/*What percentage of overall sellers are Tech sellers?*/
SELECT 
    t1.total_sellers,
    t2.total_tech_sellers,
    (t2.total_tech_sellers * 100 / t1.total_sellers) AS tech_sellers_percentage
FROM
    (SELECT 
        COUNT(DISTINCT seller_id) AS total_sellers
    FROM
        sellers) AS t1,
    (SELECT 
        COUNT(DISTINCT s.seller_id) AS total_tech_sellers
    FROM
        sellers s
    JOIN order_items oi ON s.seller_id = oi.seller_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
    WHERE
        pc.product_category_name_english IN ('audio' , 'consoles_games', 'electronics', 'computers_accessories', 'pc_gamer', 'computers', 'tablets_printing_image', 'telephony')) AS t2;
	
/*What is the total amount earned by all sellers?*/
SELECT 
    round(SUM(price)) AS total_earns
FROM
    order_items;

/*What is the total amount earned by all Tech sellers?*/
SELECT 
    ROUND(SUM(price)) AS total_tech_earns
FROM
    order_items o
        JOIN
    products p ON p.product_id = o.product_id
        LEFT JOIN
    product_category_name_translation pc ON pc.product_category_name = p.product_category_name
WHERE
    pc.product_category_name_english IN ('audio' , 'consoles_games',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony');
        
	/*Can you work out the average monthly income of all sellers? */
    SELECT 
    round(AVG(monthly_revenue)) AS avg_monthly_income_all_sellers
FROM
    (SELECT 
        s.seller_id,
            LEFT(o.order_purchase_timestamp, 7) AS order_month,
            SUM(oi.price) AS monthly_revenue
    FROM
        sellers s
    JOIN order_items oi ON s.seller_id = oi.seller_id
    JOIN orders o ON o.order_id = oi.order_id
    GROUP BY s.seller_id , order_month) AS subquery;
    
    /*Can you work out the average monthly income of Tech sellers?*/
    select 
    round(avg(monthly_revenue)) as avg_monthly_income_tech_sellers
    from
    (
    SELECT
    s.seller_id,
    left(o.order_purchase_timestamp, 7) as order_month,
    sum(oi.price) as monthly_revenue
    FROM
    sellers s
    join
    order_items oi
    on
    s.seller_id=oi.seller_id
    join
    orders o
    on
    o.order_id = oi.order_id
    JOIN
    products p ON p.product_id = oi.product_id
	JOIN
    product_category_name_translation pc ON pc.product_category_name = p.product_category_name
WHERE
    pc.product_category_name_english IN ('audio' , 'consoles_games',
        'electronics',
        'computers_accessories',
        'pc_gamer',
        'computers',
        'tablets_printing_image',
        'telephony')
    group by s.seller_id, order_month) as subquery;

/*What’s the average time between the order being placed and the product being delivered?*/
SELECT 
    AVG(DATEDIFF(order_delivered_customer_date,  order_purchase_timestamp)) as average_delivered_time
FROM
    orders
WHERE
    order_status = 'delivered';

/*How many orders are delivered on time vs orders delivered with a delay?*/

SELECT 
    case when 
    order_delivered_customer_date<=order_estimated_delivery_date then 'on_time_delivered'
    Else 'delayed_orders'
    end as delivery_status,
    count(*) as total_orders
FROM
    orders
WHERE
    order_status = 'delivered'
    group by delivery_status;
    
/*Is there any pattern for delayed orders, e.g. big products being delayed more often?*/

SELECT 
    case when 
    order_delivered_customer_date<=order_estimated_delivery_date then 'on_time_delivered'
    Else 'delayed_orders'
      end as delivery_status,
    avg(p.product_weight_g) as avg_product_weight,
    avg(p.product_length_cm * p.product_height_cm * p.product_width_cm) as avg_product_volume
FROM
    orders o
    join
    order_items oi
    on
    o.order_id = oi.order_id
    JOIN
    products p ON p.product_id = oi.product_id
WHERE
    order_status = 'delivered'
    group by delivery_status;