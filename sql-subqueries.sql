USE sakila;

# 1. How many copies of the film Hunchback Impossible exist in the inventory system?

WITH relevant_movies AS (SELECT 
    film_id, title
FROM
    film
WHERE
    title = 'Hunchback Impossible')
SELECT 
    title, COUNT(*) AS number_of_copies
FROM
    inventory
JOIN
    relevant_movies ON relevant_movies.film_id = inventory.film_id; # 6 copies
    
# 2. List all films whose length is longer than the average of all the films.

SELECT 
    film_id, length, title
FROM
    film
WHERE
    length > (SELECT 
            AVG(length)
        FROM
            film);

# Check the average amount
SELECT 
    AVG(length)
FROM
    film; # 115.27 minnutes

# 3. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT 
    first_name, last_name
FROM
    actor
        JOIN
    (SELECT 
        actor_id
    FROM
        film_actor
    WHERE
        film_id = (	SELECT 
						film_id
					FROM
						film
					WHERE
						title = 'Alone Trip')) AS actors 
		ON actors.actor_id = actor.actor_id;

#4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. \
# Identify all movies categorized as family films.

SELECT 
    title
FROM
    film
        JOIN
    (SELECT 
        film_id
    FROM
        film_category
    WHERE
        category_id = (SELECT 
                category_id
            FROM
                category
            WHERE
                name = 'Family')) AS family_films ON family_films.film_id = film.film_id;


# 5. Get name and email from customers from Canada using subqueries. Do the same with joins. \
# Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, \
# that will help you get the relevant information.

SELECT 
	first_name, last_name, email 
FROM 
	customer
JOIN
	(SELECT 
		address_id 
	FROM 
		address
	JOIN
		(SELECT 
			city_id 
		 FROM 
			city 
		 WHERE 
			country_id = (SELECT 
							country_id 
						  FROM 
							country 
						  WHERE 
							country = "Canada")) 
		  AS 
			canada_cities
	ON 
		canada_cities.city_id = address.city_id) 
	AS 
		canada_addresses
ON 
	canada_addresses.address_id = customer.address_id;

# 6. Which are films starred by the most prolific actor? Most prolific actor is defined as \
# the actor that has acted in the most number of films. First you will have to find the most prolific actor \
#  and then use that actor_id to find the different films that he/she starred in.
SELECT 
    title
FROM
    film
JOIN
(SELECT 
    film_id
FROM
    film_actor 
WHERE 
	actor_id = (SELECT 
					actor_id 
				FROM
				(SELECT 
					actor_id, COUNT(*) AS number_of_films
				FROM
					film_actor
				GROUP BY 
					actor_id
				ORDER BY 
					number_of_films DESC
				LIMIT 1) AS prolific_actor)) AS films
ON films.film_id = film.film_id;

# 7. Films rented by most profitable customer. You can use the customer table and payment table \
# to find the most profitable customer, i.e. the customer that has made the largest sum of payments

SELECT 
    title
FROM
    film
JOIN inventory
ON inventory.film_id = film.film_id
JOIN rental
ON rental.inventory_id = inventory.inventory_id
WHERE customer_id = (SELECT 
						customer_id 
					 FROM
						(SELECT 
							customer_id, SUM(amount) OVER (PARTITION BY customer_id) AS total_payments
						 FROM
							payment
						 ORDER BY total_payments DESC 
					 LIMIT 1) AS prolific);

# 8. Get the client_id and the total_amount_spent of those clients who spent more than the average of the \
# total_amount spent by each client.
SELECT 
    customer_id, SUM(amount) AS total_amount_spent
FROM
    payment
GROUP BY customer_id
HAVING total_amount_spent > (SELECT 
								AVG(amount) AS average_amount_spent
							FROM
								payment);