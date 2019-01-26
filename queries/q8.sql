/* 3.8 */
select c.customer_id, count(t.transaction_id)
from customers as c,
     transactions as t
where c.customer_id = t.customer_id
  and t.type = 'Charge'
  and t.date :: date = (%s)
group by c.customer_id;