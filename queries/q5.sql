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
      where c.car_id = o.car_id
        and date_from::date >= (%s)) as distance,
     (select age(date_to, date_from) as average_trip_duration
      from orders
      where date_from::date >= (%s)
        and date_to is not null
      limit 1) as duration;