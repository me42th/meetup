explain format=json select 
	country.country,
	category.name,
	sum(payment.amount) as money,
	count(actor.actor_id) as jobs, 
	film.release_year
	from film
	left join inventory
		on film.film_id = inventory.film_id 
	left join rental
		on rental.inventory_id = inventory.inventory_id 
	left join payment 
		on payment.rental_id = rental.rental_id 
	left join store
		on store.store_id = inventory.store_id 
	left join address 
		on store.address_id = address.address_id 
	left join city 
		on city.city_id = address.city_id
	left join country
		on country.country_id = city.country_id
	left join film_category
		on film_category.film_id = film.film_id
	left join category
		on category.category_id = film_category.category_id 
	left join film_actor 
		on film_actor.film_id = film.film_id 
	left join actor
		on actor.actor_id = film_actor.actor_id 
	group by film.release_year,country.country,category.name;


CREATE TABLE `finance` (
  `country` char(50) NOT NULL,
  `name` char(50) NOT NULL,
  `money` double NOT NULL,
  `jobs` int NOT NULL,
  `year` year,
  `key` char(40) GENERATED ALWAYS AS (md5(concat(`country`,`name`,`year`))) VIRTUAL,
  UNIQUE KEY `key` (`key`)
);

explain format=json select * from finance;

INSERT INTO	finance (`country`,`name`,`money`,`jobs`,`year` )
  (
	SELECT
		CASE
			WHEN country.country IS NULL THEN 'null'
			ELSE country.country
		END AS country,
		category.name,
		sum( CASE WHEN payment.amount IS NULL THEN 0 ELSE payment.amount END) AS money,
		count(actor.actor_id) AS jobs,
		film.release_year AS `year`
	FROM
		film
	LEFT JOIN inventory
		ON
		film.film_id = inventory.film_id
	LEFT JOIN rental
		ON
		rental.inventory_id = inventory.inventory_id
	LEFT JOIN payment 
		ON
		payment.rental_id = rental.rental_id
	LEFT JOIN store
		ON
		store.store_id = inventory.store_id
	LEFT JOIN address 
		ON
		store.address_id = address.address_id
	LEFT JOIN city 
		ON
		city.city_id = address.city_id
	LEFT JOIN country
		ON
		country.country_id = city.country_id
	LEFT JOIN film_category
		ON
		film_category.film_id = film.film_id
	LEFT JOIN category
		ON
		category.category_id = film_category.category_id
	LEFT JOIN film_actor 
		ON
		film_actor.film_id = film.film_id
	LEFT JOIN actor
		ON
		actor.actor_id = film_actor.actor_id
	GROUP BY
		film.release_year,
		country.country,
		category.name
        ) ON
	duplicate KEY
            UPDATE
		        country = VALUES(country),
				name = VALUES(name),
				money = VALUES(money),
				jobs = VALUES(jobs), 
				`year` = VALUES(`year`);
