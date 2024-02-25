--Вывести распределение (количество) клиентов по сферам деятельности, 
--отсортировав результат по убыванию количества
select job_industry_category, count(customer_id) as cnt_cust
from customer c 
group by job_industry_category
order by cnt_cust desc;


--Найти сумму транзакций за каждый месяц по сферам деятельности, 
--отсортировав по месяцам и по сфере деятельности
select date_trunc('month', to_date(t.transaction_date, 'DD.MM.YYYY')) as t_month, 
       c.job_industry_category,
       sum(t.list_price)
from "transaction" t inner join customer c 
     on t.customer_id = c.customer_id 
group by t_month, c.job_industry_category 
order by t_month asc, c.job_industry_category asc;


--Вывести количество онлайн-заказов для всех брендов в рамках 
--подтвержденных заказов клиентов из сферы IT. 
select t.brand, count(t.transaction_id)
from "transaction" t inner join customer c
     on t.customer_id = c.customer_id 
where t.online_order = true and t.order_status = 'Approved'
      and c.job_industry_category = 'IT'
group by t.brand;


--Найти по всем клиентам сумму всех транзакций (list_price), максимум, минимум и 
--количество транзакций, отсортировав результат по убыванию суммы транзакций 
--и количества клиентов, используя только group by.
select customer_id,
       sum(list_price) as sum_price,
       max(list_price) as max_price,
       min(list_price) as min_price,
       count(transaction_id) as transaction_num
from "transaction" t 
group by customer_id
order by sum_price desc, transaction_num desc; 
-- количество строк = количество уникальных значений customer_id


--Найти по всем клиентам сумму всех транзакций (list_price), максимум, минимум и 
--количество транзакций, отсортировав результат по убыванию суммы транзакций 
--и количества клиентов, используя только оконные функции.
select customer_id, transaction_id,
       sum(list_price) over(partition by customer_id) as sum_price,
       max(list_price) over(partition by customer_id) as max_price,
       min(list_price) over(partition by customer_id) as min_price,
       count(transaction_id) over(partition by customer_id) as transaction_num
from "transaction" t 
order by sum_price desc, transaction_num desc;
-- количество строк = количество уникальных значений transaction_id


--Найти имена и фамилии клиентов с минимальной суммой транзакций за весь 
--период (сумма транзакций не может быть null).
with cust_sum_price as (
    select customer_id, sum(t.list_price) as sum_price
    from "transaction" t 
    group by customer_id 
)
select c.first_name, c.last_name
from customer c inner join cust_sum_price cs
     on c.customer_id = cs.customer_id
where cs.sum_price = (select min(sum_price) from cust_sum_price);


--Найти имена и фамилии клиентов с максимальной суммой транзакций за весь 
--период (сумма транзакций не может быть null).
with cust_sum_price as (
    select customer_id, sum(t.list_price) as sum_price
    from "transaction" t 
    group by customer_id 
)
select c.first_name, c.last_name
from customer c inner join cust_sum_price cs
     on c.customer_id = cs.customer_id
where cs.sum_price = (select max(sum_price) from cust_sum_price);


--Вывести только самые первые транзакции клиентов. Решить с помощью оконных функций. 
select distinct customer_id, 
       first_value(transaction_id) over (partition by customer_id
                                   order by to_date(transaction_date, 'DD.MM.YYYY')) as first_transaction
from "transaction" t;

--Вывести имена, фамилии и профессии клиентов, между транзакциями которых 
--был максимальный интервал (интервал вычисляется в днях)

