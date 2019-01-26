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