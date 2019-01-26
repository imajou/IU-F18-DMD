/* 3.10 */
select coalesce(t1.car_id, t2.car_id) as car_id,
       (coalesce(t1.sum1, 0) + coalesce(t2.sum2, 0)) /
       (select date_part('day', age(now(), date_from))
        from orders
        where car_id = coalesce(t1.car_id, t2.car_id)
        order by date_from asc
        limit 1)                      as total_cost
from (
    (select car_id, sum(transactions.amount) as sum1
     from transactions
            join workshop_calendar c2 on transactions.transaction_id = c2.transaction_id
     where type = 'Workshop'
     group by car_id) as t1 full join
        (select car_id, sum(transactions.amount) as sum2
         from transactions
                join charging_stations_usage u on transactions.transaction_id = u.transaction_id
         where type = 'Charge'
         group by car_id) as t2 on t1.car_id = t2.car_id)
order by total_cost desc
limit 1;