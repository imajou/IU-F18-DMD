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