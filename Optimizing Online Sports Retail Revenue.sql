-- Counting missing values

SELECT 
    COUNT(*) AS total_rows, 
    COUNT(i.description) AS count_description, 
    COUNT(f.listing_price) AS count_listing_price, 
    COUNT(t.last_visited) AS count_last_visited 
FROM info AS i
INNER JOIN finance AS f
    ON i.product_id = f.product_id
INNER JOIN traffic AS t
    ON t.product_id = f.product_id;
    
-- Nike vs Adidas pricing

SELECT 
    b.brand, 
    f.listing_price, 
    COUNT(*)
FROM finance AS f
INNER JOIN brands AS b 
    ON f.product_id = b.product_id
WHERE listing_price > 0
GROUP BY b.brand, f.listing_price
ORDER BY listing_price DESC;

-- Labeling price ranges

SELECT 
    b.brand, 
    COUNT(*), 
    SUM(f.revenue) AS total_revenue,
    CASE 
        WHEN f.listing_price < 42 THEN 'Budget'
        WHEN f.listing_price >= 42 AND f.listing_price < 74 THEN 'Average'
        WHEN f.listing_price >= 74 AND f.listing_price < 129 THEN 'Expensive'
        ELSE 'Elite' 
    END AS price_category
FROM finance AS f
INNER JOIN brands AS b 
    ON f.product_id = b.product_id
WHERE b.brand IS NOT NULL
GROUP BY b.brand, price_category
ORDER BY total_revenue DESC;

-- Average discount by brand

SELECT 
    b.brand, 
    AVG(f.discount) * 100 AS average_discount
FROM brands AS b
INNER JOIN finance AS f 
    ON b.product_id = f.product_id
GROUP BY b.brand
HAVING b.brand IS NOT NULL
ORDER BY average_discount;

-- Correlation between revenue and reviews

SELECT 
    (count(*) * sum(r.reviews * f.revenue) - sum(r.reviews) * sum(f.revenue)) / 
        (sqrt(count(*) * sum(r.reviews * r.reviews) - sum(r.reviews) * sum(r.reviews)) * sqrt(count(*) * sum(f.revenue * f.revenue) - sum(f.revenue) * sum(f.revenue))) 
        AS review_revenue_corr
FROM reviews AS r
JOIN finance AS f 
    ON r.product_id = f.product_id;
    
-- Ratings and reviews by product description length
    
SELECT 
    TRUNCATE(LENGTH(i.description), -2) AS description_length,
    ROUND(AVG(r.rating), 2) AS average_rating
FROM info AS i
INNER JOIN reviews AS r 
    ON i.product_id = r.product_id
WHERE i.description IS NOT NULL
GROUP BY description_length
ORDER BY description_length;

-- Reviews by month and brand

SELECT 
    b.brand, 
   MONTH(STR_TO_DATE(t.last_visited, '%m/%d/%Y')) AS month, 
    COUNT(*) AS num_reviews
FROM brands AS b
INNER JOIN traffic AS t 
    ON b.product_id = t.product_id
INNER JOIN reviews AS r 
    ON t.product_id = r.product_id
GROUP BY b.brand, month
HAVING b.brand IS NOT NULL
    AND month IS NOT NULL
ORDER BY b.brand, month;


-- Footwear product performance

/* we have been primarily analyzing Adidas vs Nike products. 
 Now, let's switch our attention to the type of products being sold. 
 As there are no labels for product type, we will create a view  that 
 filters description for keywords, then use the results to find out how 
 much of the company's stock consists of footwear products and the 
 median revenue generated by these items. */

CREATE VIEW  footwear  AS
SELECT 
	i.description, 
	f.revenue
FROM info AS i
INNER JOIN finance AS f 
	ON i.product_id = f.product_id
WHERE i.description LIKE '%shoe%'
	OR i.description LIKE '%trainer%'
	OR i.description LIKE '%foot%'
	AND i.description IS NOT NULL;


SET @row_index := -1;
SELECT
    COUNT(*) AS num_clothing_products, 
    (SELECT  AVG(subq.revenue) as median_value
	 FROM (
		SELECT @row_index:=@row_index + 1 AS row_index, revenue
		FROM  footwear
		ORDER BY revenue) AS subq
	 WHERE subq.row_index 
	IN (FLOOR(@row_index / 2) , CEIL(@row_index / 2))) AS median_footwear_revenue
FROM  footwear;


-- Clothing product performance
SET @row_index := -1;
SELECT
    COUNT(*) AS num_clothing_products, 
    (SELECT  AVG(revenue) as median_value
	 FROM (
		SELECT @row_index:=@row_index + 1 AS row_index, f.revenue
		FROM info AS i
		INNER JOIN finance AS f on i.product_id = f.product_id
        WHERE i.description NOT IN (SELECT description FROM footwear)
		ORDER BY f.revenue) AS subq
	 WHERE subq.row_index 
	IN (FLOOR(@row_index / 2) , CEIL(@row_index / 2))) AS median_clothing_revenue
FROM info