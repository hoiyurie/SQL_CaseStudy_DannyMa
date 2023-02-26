/*
Create schema and tables, insert values for the tables
*/

----------------------------------------------------
CREATE SCHEMA dannys_diner;


CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');



  ------------------------------------------------------------

/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

--------------------------------------------------------------
-- 1. What is the total amount each customer spent at the restaurant?


-- create a subquery at first and name it 'sub'
-- use created subquery INNER JOIN sales table 

SELECT s.customer_id,SUM(sub.TotalSalesAmount) AS total_salesamount
FROM (
	SELECT 
		s.customer_id, 
		m.price, 
		COUNT(s.order_date) AS quantity,
		m.price* COUNT(s.order_date) AS TotalSalesAmount
	FROM dbo.sales s
	INNER JOIN dbo.menu m
	ON s.product_id = m.product_id
	GROUP BY customer_id,m.price
	) sub

INNER JOIN dbo.sales s
ON sub.customer_id = s.customer_id
GROUP BY s.customer_id

----------------------------------------------------------------------
-- 2. How many days has each customer visited the restaurant?


-- use CAST function to combine Month and Day and change it to string from integer
-- DISTINCT reduce duplicate 

SELECT 
customer_id,
COUNT(DISTINCT(CAST(MONTH(order_date) AS VARCHAR)+CAST(DAY(order_date) AS VARCHAR))) AS times
FROM dbo.sales
GROUP BY customer_id

SELECT *
FROM dbo.sales s
INNER JOIN dbo.menu m
ON s.product_id = m.product_id

--------------------------------------------------------------------------
-- 3. What was the first item from the menu purchased by each customer?

-- used ROW_NUMBER to create index for each customer
--create CTE 
-- fetch first row of each customer ( where RowNumberEachCustomer=1) 

WITH fetch_rows AS
(
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS RowNumberEachCustomer
	FROM 
		(SELECT 
			s.customer_id, 
			m.product_name,
			s.order_date
		FROM [dbo].[sales] s
			LEFT JOIN [dbo].[menu] m
				ON s.product_id = m.product_id

		) AS sales_menu
)

SELECT *
FROM fetch_rows
WHERE RowNumberEachCustomer = 1;

----------------------------------------------------------------------------------

--4. 