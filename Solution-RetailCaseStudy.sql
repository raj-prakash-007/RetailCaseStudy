create database retail_data_analysis
-----------------------------------------------DATA PREPARATION AND UNDERSTANDING-----------------------------------------------
--Q.1--STARTS
select count(customer_id)as No_of_rows from Customer as a
union all 
select count(prod_cat_code) as No_of_rows  from prod_cat_info as b
union all
select count(transaction_id) as No_of_rows from transactions as c
--Q.1--ENDS

--Q.2--STARTS
select count(qty) as Return_count from transactions
where qty<0
--Q.2--ENDS

--Q.3--STARTS
SELECT CONVERT(varchar , tran_date ,105) AS CONVERTED_DATE  From  TRANSACTIONS 
order by CONVERTED_DATE asc
--Q.3--ENDS

--Q.4--STARTS
 select datediff(day,min(tran_date),max(tran_date)) as no_of_days,
		datediff(month,min(tran_date),max(tran_date)) as no_of_months ,
		datediff(year,min(tran_date),max(tran_date))  as no_of_years
		from transactions
--Q.4--ENDS

--Q.5--STARTS
select prod_cat 
from prod_cat_info
where prod_subcat='diy'
--Q.5--ENDS

-----------------------------------------------------DATA ANALYSIS----------------------------------------------------------------------------
 
 --Q.1--STARTS
select  top 1 channel, no_of_transactions from(
select  Store_type as Channel,count(transaction_id) as no_of_transactions  from Transactions
group by Store_type
) as x
order by no_of_transactions desc
--Q.1--ENDS

--Q.2--STARTS
Select Gender,count(Gender) as customer_count from Customer
group by Gender
having Gender ='M' or gender= 'F'
--Q.2--ENDS

--Q.3--STARTS
select top 1 city_code,count(customer_Id) as no_of_customers from Customer
group by city_code
order by no_of_customers desc
--Q.3--ENDS

--Q.4--STARTS
select count(prod_subcat)as no_of_sub_category from prod_cat_info
where prod_cat='books'
group by prod_cat 
--Q.4--ENDS

--Q.5--STARTS
select max(qty) as Max_Qty from Transactions
--Q.5--ENDS

--Q.6--STARTS
select prod_cat, round(sum(total_amt),2) as net_revenue from  prod_cat_info as a
inner join Transactions as b
on a.prod_cat_code=b.prod_cat_code and
a.prod_sub_cat_code=b.prod_subcat_code
where prod_cat in ('electronics','books')
and total_amt>0
group by prod_cat
--Q.6--ENDS

--Q.7--STARTS
select count(cust_id)as no_of_customers from (
select cust_id,count(transaction_id)as no_of_transactions from Transactions
where Qty>0
group by cust_id
having count(transaction_id)>10
)as x
--Q.7--ENDS

--Q.8--STARTS
select round(sum(total_amt),2) as combined_revenue from Transactions as a
inner join prod_cat_info as b
on a.prod_cat_code=b.prod_cat_code and
a.prod_subcat_code=b.prod_sub_cat_code
where prod_cat in ('electronics', 'clothing')
and Store_type='flagship store'
and total_amt>0
--Q.8--ENDS

--Q.9--STARTS
select prod_subcat,sum(total_amt) as total_revenue from Customer as a 
inner join Transactions AS	b
on a.customer_Id=b.cust_id
inner join prod_cat_info as c
on c.prod_sub_cat_code=b.prod_subcat_code
and b.prod_cat_code=c.prod_cat_code
where Gender='m'
and
prod_cat='electronics'
group by prod_subcat
--Q.9--ENDS

--Q.10--STARTS
Select top 5 prod_category, (revenue * 100.0) / sum(revenue) over() as percentage_of_revenue
FROM (
    select prod_subcat as prod_category, sum(total_amt) as revenue
    from Transactions AS T
    left join prod_cat_info AS P on T.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code = P.prod_sub_cat_code
    WHERE total_amt > 0
    group by prod_subcat
) AS X
order by percentage_of_revenue desc
--Q.10--ENDS

--Q.11--STARTS
select DOB,Age,Total_revenue 
from(
select DOB,datediff(year,DOB,getdate())as Age,max(cast(tran_date as date))as Latest_transaction_date,round(sum(total_amt),2)as Total_revenue from Transactions as a
left join Customer as b
on a.cust_id=b.customer_Id
where datediff(year,DOB,getdate()) between 25 and 35
and tran_date>= dateadd(day,-30,(SELECT MAX(tran_date )FROM Transactions))
and total_amt>0
group by dob) as x
order by Age asc
--Q.11--ENDS


--Q.12--STARTS
select top 1 prod_cat,return_value from(
select prod_cat,max(total_amt) as return_value from Transactions as t
inner join prod_cat_info as p
on t.prod_cat_code=p.prod_cat_code
where total_amt<0 and 
tran_date >=DATEADD(month,-3,(SELECT MAX(TRAN_DATE )FROM Transactions))
group by prod_cat )as x
--having sum(total_amt)<=0 
order by return_value asc
--Q.12--ENDS

--Q.13--STARTS

select top 1 Store_type,sum(Qty) as total_quantity, round(sum(total_amt),2) as tot_sales from Transactions
where Qty>0
and total_amt>0
group by Store_type
order by tot_sales desc,total_quantity desc 
--Q.13--ENDS

--Q.14--STARTS
select prod_cat,avg_sales from(
select prod_cat,avg(total_amt)as avg_sales from Transactions as a left join 
prod_cat_info as b on a.prod_cat_code=b.prod_cat_code
and a.prod_subcat_code=b.prod_sub_cat_code
where qty>0
and total_amt>0
group by prod_cat) 
as x
where avg_sales>(select avg(avg_sales) from (
select prod_cat,avg(total_amt) as avg_sales
from Transactions as a left join prod_cat_info as b
on a.prod_cat_code=b.prod_cat_code and a.prod_subcat_code=b.prod_sub_cat_code
group by prod_cat )as y)
--Q.14--ENDS

--Q.15--STARTS
select top 5 prod_subcat, avg_revenue,total_revenue 
from(
select  prod_subcat,avg(total_amt)as avg_revenue,round(sum(total_amt),2) as total_revenue,sum(Qty) as qty from Transactions as a
inner join prod_cat_info as b
on a.prod_cat_code=b.prod_cat_code
and 
a.prod_subcat_code=b.prod_sub_cat_code
where Qty>0 and total_amt>0
group by prod_subcat) as x
order by Qty desc ,avg_revenue desc,total_revenue desc
--Q.15--ENDS







