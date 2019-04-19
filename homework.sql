 SHOW DATABASES;
  USE mysql;
  USE sakila;
  
  -- 1a. Display the first and last names of all actors from the table actor.

  SELECT first_name, last_name FROM actor;

  -- 1b. Display the first and last name of each actor in a single column in upper case letters. 
  -- Name the column Actor Name.

  SELECT UPPER (CONCAT(first_name, ' ', last_name)) AS "Actor Name" FROM actor;
  
  -- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
  -- What is one query would you use to obtain this information?
  
  SELECT actor_id, first_name, last_name FROM actor WHERE first_name = "Joe";
  
  -- 2b. Find all actors whose last name contain the letters GEN:
  
  SELECT first_name, last_name FROM actor WHERE last_name LIKE "%GEN%";
  
  -- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
  
  SELECT last_name, first_name FROM actor WHERE last_name LIKE "%LI%" 
  ORDER BY last_name, first_name;
  
  -- 2d. Using IN, display the country_id and country columns of the following countries: 
  -- Afghanistan, Bangladesh, and China:
  
  SELECT country_id, country FROM country WHERE country IN ("Afghanistan", "Bangladesh", "China");
  
  -- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
  -- so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
  -- as the difference between it and VARCHAR are significant).

ALTER TABLE actor
ADD COLUMN description BLOB(50);
SELECT * FROM actor;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.

ALTER TABLE actor
DROP COLUMN description;
SELECT * FROM actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, COUNT(last_name) FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors

SELECT last_name, COUNT(last_name) FROM actor 
GROUP BY last_name HAVING COUNT(last_name) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

UPDATE actor SET first_name = "HARPO" WHERE first_name = "GROUCHOaddress" AND last_name = "WILLIAMS";
SELECT first_name, last_name FROM actor WHERE last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor SET first_name = "GROUCHO" WHERE first_name = "HARPO" AND last_name = "WILLIAMS";
SELECT first_name, last_name FROM actor WHERE last_name = "WILLIAMS";

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html

 CREATE TABLE address (
    address_id INT(11) NOT NULL AUTO_INCREMENT,
	address VARCHAR(60) DEFAULT NULL,
    address2 VARCHAR(60) DEFAULT NULL,
    district VARCHAR(20) DEFAULT NULL,
    city_id INT(9) DEFAULT NULL,
    postal_code INT(15) DEFAULT NULL,
    phone INT(20) DEFAULT NULL,
    location VARCHAR(20) DEFAULT NULL,
    last_update VARCHAR(30) DEFAULT NULL,
   PRIMARY KEY (`address_id`)
   );
   
   -- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
   -- Use the tables staff and address:
   
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON address.address_id=staff.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT staff.staff_id, staff.last_name, staff.first_name, SUM(amount) AS total_amount
FROM payment
LEFT JOIN staff 
	ON staff.staff_id = payment.staff_id            
GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT film_actor.film_id, film.title, COUNT(actor_id) AS actor_count
FROM film_actor
INNER JOIN film 
	ON film_actor.film_id = film.film_id            
GROUP BY film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT inventory.film_id, film.title, COUNT(inventory.film_id) AS inventory_copies 
FROM inventory
INNER JOIN film 
	ON inventory.film_id = film.film_id WHERE film.title = "HUNCHBACK IMPOSSIBLE"
GROUP BY film.title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:

SELECT customer.first_name, customer.last_name, SUM(amount) AS "Total Amount Paid"
FROM payment
LEFT JOIN customer 
	ON customer.customer_id = payment.customer_id 
GROUP BY customer.customer_id
ORDER BY customer.last_name; 

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title FROM film WHERE language_id =
(SELECT language_id FROM language WHERE name = "English") 
AND film.title like 'K%' OR film.title LIKE 'Q%';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT first_name, last_name FROM actor where actor_id IN
(SELECT actor_id FROM film_actor WHERE film_id =
(SELECT film_id FROM film WHERE title = "ALONE TRIP"));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use JOINS to retrieve this information.

SELECT first_name, last_name, email
FROM customer
INNER JOIN address ON address.address_id=customer.address_id
INNER JOIN city ON city.city_id=address.city_id
INNER JOIN country ON country.country_id=city.country_id
WHERE country.country="Canada";

-- You can also use sub-queries:

SELECT first_name, last_name, email FROM customer where address_id IN
(SELECT address_id FROM address WHERE city_id IN
(SELECT city_id FROM city WHERE country_id IN
(SELECT country_id FROM country WHERE country="Canada")));

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

SELECT title FROM film where film_id IN
(SELECT film_id FROM film_category WHERE category_id IN
(SELECT category_id FROM category WHERE name="Family"));

-- 7e. Display the most frequently rented movies in descending order.
-- 
explain
SELECT film.title, COUNT(rental.rental_id) AS "Popular Rentals"
FROM rental
LEFT JOIN inventory ON inventory.inventory_id=rental.inventory_id
LEFT JOIN film ON film.film_id = inventory.film_id 
GROUP BY film.title
ORDER BY COUNT(rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store.store_id, SUM(amount) AS Business
FROM payment
LEFT JOIN staff ON staff.staff_id = payment.staff_id 
LEFT JOIN store ON store.manager_staff_id = staff.staff_id            
GROUP BY store.store_id
ORDER BY Business DESC;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country.country
FROM store
INNER JOIN address ON address.address_id = store.address_id 
INNER JOIN city ON city.city_id = address.city_id
INNER JOIN country ON country.country_id = city.country_id 
GROUP BY store.store_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT category.name AS Genre, SUM(amount) AS Revenue
FROM payment
LEFT JOIN rental ON rental.rental_id = payment.rental_id 
LEFT JOIN inventory ON inventory.inventory_id = rental.inventory_id
LEFT JOIN film_category ON film_category.film_id = inventory.film_id
LEFT JOIN category ON category.category_id = film_category.category_id   
GROUP BY category.name
ORDER BY Revenue DESC
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view.  If you haven't solved 7h, you can substitute another query to create a view.

-- https://stackoverflow.com/questions/6595252/mysql-creating-a-new-table-with-information-from-a-query/6595301#6595301

CREATE VIEW fav_genres AS
SELECT category.name AS Genre, SUM(amount) AS Revenue
FROM payment
LEFT JOIN rental ON rental.rental_id = payment.rental_id 
LEFT JOIN inventory ON inventory.inventory_id = rental.inventory_id
LEFT JOIN film_category ON film_category.film_id = inventory.film_id
LEFT JOIN category ON category.category_id = film_category.category_id   
GROUP BY category.name
ORDER BY Revenue DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT *
FROM fav_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

DROP VIEW fav_genres;

SELECT *
FROM fav_genres;


