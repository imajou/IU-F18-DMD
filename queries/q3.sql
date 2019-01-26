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