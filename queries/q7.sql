/* 3.7 */
select car_id, count(car_id) as orders_count
from orders
where (date_from >= (now() - interval '3 months'))
group by car_id
order by orders_count asc
limit (select (count(car_id) / 10) + 1 from orders);