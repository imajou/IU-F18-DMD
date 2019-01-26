/* 3.1 */
select car.car_id
from cars as car,
     orders as o,
     transactions as t,
     customers as c
where c.name = 'Joo Lee'
  AND c.customer_id = t.customer_id
  AND t.transaction_id = o.transaction_id
  AND car.car_id = o.car_id
  AND car.color = 'white'
  AND car.plate_number like '%AA%';


/* 3.2 */
select extract(hour from date_from)                     as hour_from,
       extract(hour from date_from + interval '1 hour') as hour_to,
       count(transaction_id)
from charging_stations_usage as csu
where csu.date_from :: date = '2018-11-21'
group by extract(hour from date_from), extract(hour from date_from + interval '1 hour');


/* 3.3 */
select count_morning, count_afternoon, count_evening
from (select count(car_id) as count_morning
      from orders
      where date_to >= ((now() - '7 days' :: interval) :: date)
        AND date_from :: time >= '07:00:00'
        AND date_from :: time < '10:00:00') as morning,
     (select count(car_id) as count_afternoon
      from orders
      where date_to >= ((now() - '7 days' :: interval) :: date)
        AND date_from :: time >= '12:00:00'
        AND date_from :: time < '14:00:00') as afternoon,
     (select count(car_id) as count_evening
      from orders
      where date_to >= ((now() - '7 days' :: interval) :: date)
        AND date_from :: time >= '17:00:00'
        AND date_from :: time < '19:00:00') as evening;


/* 3.4 */
select t.date
from transactions as t,
     customers as c
where name = 'Manuel Mazzara'
  AND t.type = 'Charge'
  AND c.customer_id = t.customer_id;


/* 3.5*/
select average_distance, average_trip_duration
from (select avg(sqrt(
      pow((cast(LEFT(location_pickup, 9) as double precision) -
           cast(LEFT(location_cur, 9) as double precision)),
          2)
      + pow((cast(RIGHT(location_pickup, 9) as double precision) -
             cast(RIGHT(location_cur, 9) as double precision)), 2))) as average_distance
      from orders as o,
           cars as c
      where date_from::date >= '2018-11-20'
        and c.car_id = o.car_id) as distance,
     (select age(date_to, date_from) as average_trip_duration
      from orders
      where date_from::date >= '2018-11-20'
        and date_to is not null
      limit 1) as duration;


/* 3.6 */
/* Morning */
select count(street) as count, street
from orders as o,
     locations as l
where o.location_pickup = l.gps
  and date_from :: time >= '07:00:00'
  AND date_from :: time < '10:00:00'
group by l.street
order by count desc
limit 3;
/* Afternoon */
select count(street) as count, street
from orders as o,
     locations as l
where o.location_pickup = l.gps
  and date_from :: time >= '12:00:00'
  AND date_from :: time < '14:00:00'
group by l.street
order by count desc
limit 3;
/* Evening */
select count(street) as count, street
from orders as o,
     locations as l
where o.location_pickup = l.gps
  and date_from :: time >= '17:00:00'
  AND date_from :: time < '19:00:00'
group by l.street
order by count desc
limit 3;


/* 3.7 */
select car_id, count(car_id) as orders_count
from orders
where (date_from >= (now() - interval '3 months'))
group by car_id
order by orders_count asc
limit (select (count(car_id) / 10) + 1 from orders);


/* 3.8 */
select c.customer_id, count(t.transaction_id)
from customers as c,
     transactions as t
where c.customer_id = t.customer_id
  and t.type = 'Charge'
  and t.date :: date = '2018-11-21'
group by c.customer_id;


/* 3.9 */
select name, workshop_id, part_request_count
from parts
       inner join (select part_id,
                          workshop_id,
                          sum(amount)                                                      as part_request_count,
                          rank() over (partition by workshop_id order by sum(amount) desc) as rank
                   from parts_requests
                   where (date_of_arrival >= (now() - interval '1 year'))
                   group by part_id, workshop_id) as t on t.part_id = parts.part_id
where t.rank = 1;


/* 3.10 */
select coalesce(t1.car_id, t2.car_id) as car_id,
       (coalesce(t1.sum1, 0) + coalesce(t2.sum2, 0)) /
       (select date_part('day', age(now(), date_from))
        from orders
        where car_id = coalesce(t1.car_id, t2.car_id)
        order by date_from asc
        limit 1)                      as average_cost
from (
      (select car_id, sum(transactions.amount) as sum1
       from transactions
              join workshop_calendar c2 on transactions.transaction_id = c2.transaction_id
       where type = 'Workshop'
       group by car_id) as t1
       full join
       (select car_id, sum(transactions.amount) as sum2
        from transactions
               join charging_stations_usage u on transactions.transaction_id = u.transaction_id
        where type = 'Charge'
        group by car_id) as t2 on t1.car_id = t2.car_id)
order by average_cost desc
limit 1;

