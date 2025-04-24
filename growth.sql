-- growth.sql
-- year over year growth (org wide)
SELECT join_yr, COUNT(member_id) AS new_members_all
FROM
(SELECT member_id, YEAR(MIN(joined)) AS join_yr
FROM grp_member
GROUP BY member_id) a
GROUP BY join_yr
ORDER BY join_yr DESC;

/* It seems there is no big difference between  YEAR(MIN(joined)) and MIN(YEAR(joined))
*/
SELECT join_yr, COUNT(*) AS new_members_all
FROM
(SELECT member_id, MIN(YEAR(joined)) AS join_yr
FROM grp_member
GROUP BY member_id) a
GROUP BY join_yr
ORDER BY join_yr DESC;

/* Some members in the dataset have the same name but different member_ids.
For example there are 3 people with the name Alexandria.
There are 171 people with the name Alex.
*/
select member_name, count(*) from grp_member
group by member_name
having count(*) >1
order by member_name ;

select * from grp_member
where member_name = "Alex";

SET SQL_SAFE_UPDATES = 0;

-- group surburbs with their larger geographic area
UPDATE grp_member
SET city = "San Francisco"
WHERE city = "South San Francisco";

UPDATE grp_member
SET city = "Chicago"
WHERE city IN ("East Chicago", "West Chicago", "North Chicago", "Chicago Heights", "Chicago Ridge");

UPDATE grp_member
SET city = "New York"
WHERE city = "West New York";

-- year over year growth for NY
SELECT join_yr, COUNT(member_id) AS new_members_all
FROM
(SELECT member_id, YEAR(MIN(joined)) AS join_yr
FROM grp_member
WHERE city LIKE 'New York'
GROUP BY member_id) a
GROUP BY join_yr
ORDER BY join_yr DESC;

-- year over year growth for CHI
SELECT join_yr, COUNT(member_id) AS new_members_all
FROM
(SELECT member_id, YEAR(MIN(joined)) AS join_yr
FROM grp_member
WHERE city LIKE 'Chicago'
GROUP BY member_id) a
GROUP BY join_yr
ORDER BY join_yr DESC;

-- year over year growth for SF
SELECT join_yr, COUNT(member_id) AS new_members_all
FROM
(SELECT member_id, YEAR(MIN(joined)) AS join_yr
FROM grp_member
WHERE city LIKE 'San Francisco'
GROUP BY member_id) a
GROUP BY join_yr
ORDER BY join_yr DESC;

-- month over growth (2017)
SELECT month, COUNT(month) ct
FROM
(SELECT member_id, MONTH(MIN(joined)) month
FROM grp_member
WHERE YEAR(joined) = 2017
GROUP BY member_id) a
GROUP BY month
ORDER BY month;

-- feature_groups.sql
-- breakdown of group ratings
SELECT 
COUNT(*),
CASE
    WHEN rating = 0 THEN 'no rating'
    WHEN rating < 2 THEN '1-1.99'
    WHEN rating < 3 THEN '2-2.99'
    WHEN rating < 4 THEN '3-3.99'
    WHEN rating < 5 THEN '4-4.99'
    ELSE '5'
END AS ratings
FROM grp 
GROUP BY ratings
ORDER BY ratings;
/*745 groups have a 5 star rating while 1548 groups have no rating*/

/* Distribution of values in a group */

SELECT 
COUNT(*),
CASE
WHEN rating = 0 THEN 'no rating'
WHEN rating < 2 THEN '1-1.99'
WHEN rating < 3 THEN '2-2.99'
WHEN rating < 4 THEN '3-3.99'
WHEN rating < 5 THEN '4-4.99'
ELSE '5'
END AS ratings_distribution
FROM grp
GROUP BY ratings_distribution
ORDER BY ratings_distribution;

/* Case statements have to end with an 'end'
You can either use COUN(*) or SUM when you count the 1's*/


select
sum(case when rating = 0 or rating is null then 1 else 0 end) as no_rating,
sum(case when rating between 1 and 1.99 then 1 else 0 end) as one_rating,
sum(case when rating between 2 and 2.99 then 1 else 0 end) as two_rating,
sum(case when rating between 3 and 3.99 then 1 else 0 end) as three_rating,
sum(case when rating between 4 and 4.99 then 1 else 0 end) as four_rating,
sum(case when rating = 5 then 1 else 0 end) as five_rating
from grp;

-- sandbox
/*
You can use the sum function to put all the data on one line
select 
sum(case when rating = 0 or rating is null then 1 else 0 end) no_rating,
sum(case when rating between 1 and 1.99 then 1 else 0 end) low_rating,
sum(case when rating between 2 and 2.99 then 1 else 0 end) low_med_rating,
sum(case when rating between 3 and 3.99 then 1 else 0 end) med_rating,
sum(case when rating between 4 and 4.99 then 1 else 0 end) med_high_rating,
sum(case when rating = 5 then 1 else 0 end) high_rating
 from grp;
 */

-- Returns group_name, number of members and the city for groups with with a 5 star rating
SELECT group_name, members, c.city
FROM grp g
JOIN city c ON g.city_id = c.city_id
WHERE rating = 5
ORDER BY members DESC;
/*Four out of the top five most popular groups are all located in NYC.  
All have more than 2500 members with the max members being 9082.*/

/*Some students will use member_id to count the number of 
members in the groups*/
SELECT g.group_name, count(distinct gm.member_id) num_memb, c.city
FROM grp_member gm 
JOIN grp g ON gm.group_id = g.group_id
JOIN city c ON g.city_id = c.city_id
WHERE g.rating = 5
GROUP BY g.group_name, c.city
ORDER BY num_memb DESC;

-- Find the most popular categories of groups
SELECT category_name, COUNT(g.category_id)
FROM category c
JOIN grp g ON c.category_id = g.category_id
GROUP BY category_name
ORDER BY COUNT(g.category_id) DESC;
/*The most common categories are Tech, Career & Business and Socializing*/

-- Find groups outside of 3 most popular categories
SELECT group_name, members, c.city, category_name
FROM grp g
JOIN city c ON g.city_id = c.city_id
JOIN category cat ON g.category_id = cat.category_id
WHERE rating = 5 AND category_name NOT IN ("Tech", "Career & Business", "Socializing")
ORDER BY members DESC;

SELECT g.group_name, count(distinct gm.member_id) num_memb, c.city
FROM grp_member gm 
JOIN grp g ON gm.group_id = g.group_id
JOIN city c ON g.city_id = c.city_id
JOIN category cat ON g.category_id = cat.category_id
WHERE g.rating = 5 AND category_name NOT IN ("Tech", "Career & Business", "Socializing")
GROUP BY g.group_name, c.city
ORDER BY num_memb DESC;

SELECT group_name, count(event_id) AS number_of_events
FROM grp
JOIN event on event.group_id = grp.group_id
GROUP BY group_name
ORDER BY number_of_events DESC;




