USE sakila;

-- Step 1: Create a View
CREATE VIEW rental_summary AS
SELECT 
	customer.customer_id, 
    customer.first_name, 
    customer.last_name, 
    customer.email,
    COUNT(rental.rental_id) AS rental_count
FROM customer
JOIN rental ON customer.customer_id = rental.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name, customer.email;


-- Step 2: Create a Temporary Table
CREATE TEMPORARY TABLE temp_table AS
SELECT
	rental_summary.customer_id, 
    rental_summary.first_name, 
    rental_summary.last_name, 
    rental_summary.email,
    SUM(payment.amount) AS total_paid
FROM rental_summary
JOIN payment ON rental_summary.customer_id = payment.customer_id
GROUP BY rental_summary.customer_id, rental_summary.first_name, rental_summary.last_name, rental_summary.email;


-- Step 3: Create a CTE and the Customer Summary Report
WITH cte_table AS (
    SELECT
        rental_summary.customer_id, 
        rental_summary.first_name, 
        rental_summary.last_name, 
        rental_summary.email,
        temp_table.total_paid,
        rental_summary.rental_count
    FROM rental_summary
    JOIN temp_table ON rental_summary.customer_id = temp_table.customer_id
)
SELECT
     customer_id, 
	 first_name, 
	 last_name, 
	 email,
	 total_paid,
	 rental_count,
     ROUND(total_paid / cte_table.rental_count, 2) AS average_payment_per_rental
FROM cte_table;

