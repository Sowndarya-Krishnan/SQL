create database SQL_FINAL_PROJECT;
use SQL_FINAL_PROJECT;

-- 1 To view all table  
call View_All_Table();

-- 2 to call a Specific table name 
call Specific_Table("users_role");

-- user_id primary & foreing key
alter table users_csv add primary key (user_id);
alter table favorite_property add primary key (favorite_id);
alter table favorite_property add foreign key (user_id) references users_csv(user_id);
alter table users_role add foreign key (user_id) references users_csv(user_id);
alter table appointment_csv add primary key (appointment_id);
alter table appointment_csv add foreign key (user_id) references users_csv(user_id);
alter table transactions1 add primary key(transaction_id);
alter table transactions1 add foreign key (buyer_id) references users_csv(user_id);

-- property_id primary & foreing key 
alter table properties add primary key (property_id);
alter table property_additional_details1 add primary key (detail_id);
alter table property_additional_details1 add foreign key (property_id) 
references properties(property_id);
alter table favorite_property add foreign key (property_id) 
references properties(property_id);
alter table transactions1 add foreign key (property_id) references properties(property_id);
alter table owners add primary key (owner_id);
alter table transactions1 add foreign key(seller_id) references owners(owner_id);
alter table owners add foreign key (property_id) references properties(property_id);

-- agent_id primary & foreing key 
alter table agent add primary key (agent_id);
alter table appointment_csv add foreign key (agent_id) references agent(agent_id);
alter table transactions1 add foreign key (agent_id) references agent(agent_id);
-- ALTER TABLE transactions1 MODIFY agent_id INT;

-- 3 Join 4 table and find who have more than one appointments

select 
	users_csv.user_id,
    appointment_csv.appointment_id, 
    users_csv.first_name, 
    users_csv.last_name,
    users_csv.email,
	properties.property_id, 
    property_additional_details1.property_type,
	property_additional_details1.amenity_name,appointment_csv.appointment_date
from users_csv
inner join appointment_csv on appointment_csv.user_id = users_csv.user_id
inner join properties on appointment_csv.property_id = properties.property_id
inner join property_additional_details1 on properties.property_id = property_additional_details1.property_id
WHERE users_csv.user_id IN (
    SELECT user_id
    FROM appointment_csv
    GROUP BY user_id
    HAVING COUNT(appointment_id) > 1
)
order by users_csv.user_id;

-- 4 Join 4 table and find who have added more than one property to favorite property

select
    users_csv.user_id,
    users_csv.first_name, 
    users_csv.last_name,
    users_csv.email,
    COUNT(favorite_property.property_id) as total_favorite_properties,
    GROUP_CONCAT(distinct properties.property_id order by properties.property_id asc) 
    as property_ids,
    GROUP_CONCAT(distinct property_additional_details1.year_built
    order by property_additional_details1.year_built asc) as year_built
from users_csv 
inner join favorite_property on users_csv.user_id = favorite_property.user_id
inner join properties on favorite_property.property_id = properties.property_id
inner join property_additional_details1 on properties.property_id = property_additional_details1.property_id
where users_csv.user_id in (
    select user_id
    from favorite_property
    group by user_id
    having COUNT(favorite_id) > 1
)
group by users_csv.user_id, users_csv.first_name, users_csv.last_name, users_csv.email
order by users_csv.user_id asc;

-- 5 Join 4 table and find document verified = yes and ownership type = sole

select distinct
	favorite_property.favorite_id,
    properties.property_id, 
    owners.owner_id, 
    owners.first_name, 
    owners.last_name,
    owners.ownership_type,
    properties.location, 
    property_additional_details1.property_type,
    owners.document_verified
from favorite_property
inner join properties on favorite_property.property_id = properties.property_id
inner join owners on owners.property_id = favorite_property.property_id
inner join property_additional_details1 on 
favorite_property.property_id = property_additional_details1.property_id
WHERE owners.document_verified = "yes" and owners.ownership_type = "sole"
order by favorite_property.favorite_id;

-- 6 join 2 table and retrive data where role_id = 2

select 
	users_csv.user_id, 
    users_csv.first_name,
    users_csv.last_name,
    users_csv.email,
    users_csv.phone,
    users_role.role_name,
    users_role.permissions
from Users_csv
inner join users_role on users_role.user_id = Users_csv.user_id
where users_role.role_id = 2;

-- 7 join 2 table to find no. of bedrooms = 3

select
	properties.property_id,
    properties.property_name,
    property_additional_details1.property_type,
    property_additional_details1.number_of_bedrooms,
    property_additional_details1.number_of_bathrooms,
    property_additional_details1.parking_spaces,
    properties.size_sqft,
    properties.price
from properties
inner join property_additional_details1 on 
property_additional_details1.property_id = properties.property_id
where property_additional_details1.number_of_bedrooms = 3
order by properties.property_id;

-- 8 join 2 table and retrive data where agent rating greater than 4.5

select
	appointment_csv.appointment_id,
    users_csv.user_id,
	users_csv.first_name,
    properties.property_id,
    agent.agent_id,
    agent.first_name,
    agent.license_number,
    agent.rating
from appointment_csv
inner join agent on appointment_csv.agent_id = agent.agent_id
inner join users_csv on users_csv.user_id = appointment_csv.user_id
inner join properties on properties.property_id = appointment_csv.property_id
where agent.rating > 4.5
order by appointment_csv.appointment_id;

-- 9 join 5 table and retrive data who have successfully completed transaction using bank transfer payment method

select
	transactions1.transaction_id,
    properties.property_id,
    properties.property_name,
	users_csv.user_id, 
    owners.owner_id,
    owners.first_name,
    owners.last_name,
    transactions1.amount,
    transactions1.payment_method,
    property_additional_details1.amenity_name,
    properties.location, 
    transactions1.statuses
from users_csv
inner join transactions1 on transactions1.buyer_id = users_csv.user_id
inner join properties on transactions1.property_id = properties.property_id
inner join owners on owners.owner_id = transactions1.seller_id
inner join property_additional_details1 on 
property_additional_details1.property_id = properties.property_id
where transactions1.statuses = "completed" and 
transactions1.payment_method = "bank transfer";

-- 10 Retrieve all users and their favorite properties. 
-- Include users even if they haven't favorited any property.(left Join)

select
	users_csv.user_id, 
    users_csv.first_name,
    users_csv.last_name,
    favorite_property.favorite_id
from users_csv
left join favorite_property on favorite_property.user_id = users_csv.user_id;

-- 11 Retrieve all users and their respective transactions. 
-- If an user has no transactions, still display the user's details.(right Join)

select distinct
	transactions1.transaction_id,
    group_concat(distinct users_csv.user_id order by users_csv.user_id) as user_ids,
    transactions1.amount
from transactions1
right join users_csv on users_csv.user_id = transactions1.buyer_id
group by transactions1.transaction_id,transactions1.amount;

-- 12  Generate all possible combinations of agents and owners.(cross Join)

select 
	owners.owner_id, 
    owners.first_name,
    owners.last_name,
    agent.agent_id,
    agent.first_name,
    agent.last_name
from agent
cross join owners;

-- 13 Get a combined list of agent names and owner names.(union all)

select agent.first_name from agent
union all
select owners.first_name from owners;

-- 14 union all querry 6 and 7

SELECT  
    users_csv.user_id,  
    users_csv.first_name,  
    users_csv.last_name,  
    users_csv.email,  
    users_csv.phone,
    users_role.role_name,  
    users_role.permissions,
    null as property_type,  
    null as number_of_bedrooms
FROM users_csv  
INNER JOIN users_role ON users_role.user_id = users_csv.user_id  
WHERE users_role.role_id = 2  
UNION ALL  
SELECT  
    properties.property_id,  
    properties.property_name,  
    null as last_name,  
    null as email,  
    null as phone, 
    null as role_name,
    null as permissions,
    property_additional_details1.property_type,  
    property_additional_details1.number_of_bedrooms  
FROM properties  
INNER JOIN property_additional_details1  
    ON property_additional_details1.property_id = properties.property_id  
WHERE property_additional_details1.number_of_bedrooms = 3  
ORDER BY 1;

-- 15 Write a query to find pairs of users who have the same last name. (Self Join)

select 
    u1.user_id as user1_id, 
    u1.first_name as user1_first_name, 
    u2.user_id as user2_id, 
    u2.first_name as user2_first_name, 
    u1.last_name
from users_csv u1
inner join users_csv u2 on u1.last_name = u2.last_name and u1.user_id <> u2.user_id;

-- 16 create view table

create view users_view as
select 
	users_csv.user_id, 
    users_csv.first_name,
    users_csv.last_name,
    favorite_property.favorite_id
from users_csv
left join favorite_property on favorite_property.user_id = users_csv.user_id;
select * from users_view; 

-- 17 is null, is not null, ifnull

select * from users_view where favorite_id is null;
select * from users_view where favorite_id is not null;
select user_id,first_name, last_name,ifnull(favorite_id,"hi") as up_fav 
from users_view;

-- 18 create view table

create view top_rated_agents_view as 
select agent_id, first_name, last_name, location, rating  
from agent where rating > 4.5;
select * from top_rated_agents_view;

-- 19 create another view table

create view city_agents_view as  
select agent_id, first_name, last_name, location, rating  
from agent where location = "Allisont";
select * from city_agents_view;

-- 20 single row sub querry

select * from properties
where property_id = (select property_id from property_additional_details1 
where (year_built = 2022 and current_status = "rented"));

-- 21 multy row sub querry

select * from users_csv
where user_id in (select user_id from users_role where role_name = "buyer");
-- using any
select * from appointment_csv
where status = "completed" and 
agent_id = any( select agent_id from agent where rating > 4.7);

-- 22 in and all sub querry

select user_id, first_name, last_name, email  
from users_csv  
where user_id in (  
    select buyer_id  
    from transactions1
    where amount > all (  
        select amount from transactions1 where buyer_id != transactions1.buyer_id  
    )  
);

-- 23 querry using like 

select * from properties where property_name like "d% %a";

-- 24 control flow using case

select 
	agent.agent_id,
    agent.first_name,
    agent.last_name,
    agent.license_number,
    agent.rating,
    case
		when agent.rating > 4 then "good"
        when agent.rating < 3 then "bad"
        when agent.rating between 3 and 4 then "Moderate"
	end as rating_trust
from agent;

-- 25 control flow using if

select user_id,first_name,last_name,if(role = "seller","owner","user" ) as owner_alone 
from users_csv;

-- 26 Find properties that have been favorited by more than one user

select property_id, COUNT(user_id) as favorite_count 
from favorite_property
group by property_id 
having count(user_id) > 1;

-- 27 Find the total number of transactions for each buyer

 select buyer_id, COUNT(transaction_id) as total_transactions 
from transactions1 
group by buyer_id;

-- 28 Find the details of owners who own the property as solo

select owner_id, first_name, last_name,ownership_type
from owners
group by owner_id, first_name, last_name, ownership_type
having ownership_type = 'sole';

-- 29 List all buyers who have made transactions greater than the average transaction amount
select buyer_id, amount 
from transactions1
where amount > (select avg(amount) from transactions1);
select avg(amount) from transactions1;
-- 30 Find the users who have scheduled an appointment but haven't made any transactions

select distinct users_csv.user_id, users_csv.first_name, users_csv.last_name 
from users_csv
inner join appointment_csv on users_csv.user_id = appointment_csv.user_id 
where users_csv.user_id not in (select buyer_id from transactions1);

-- 31 Find all appointments scheduled for a specific date and time

select * from appointment_csv
where appointment_date = '2025-01-22 06:45:56';
