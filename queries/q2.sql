/* 3.2 */
select extract(hour from date_from), extract(hour from date_from + interval '1 hour'), count(transaction_id)
from charging_stations_usage as csu
where csu.date_from :: date = (%s)
group by extract(hour from date_from), extract(hour from date_from + interval '1 hour');