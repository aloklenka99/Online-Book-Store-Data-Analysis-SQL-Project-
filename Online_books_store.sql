create database Online_Book_store

use Online_Book_store

select*from books
select*from Orders
select*from Customers


--checking null value in tables
select*from Books
where Book_ID is null
	or Title is null
	or Author is null
	or Genre is null
	or Published_Year is null
	or Price is null
	or Stock is null

--checking duplicate across all columns in order table
select Order_ID,Customer_ID,Book_ID,Order_Date,Quantity,Total_Amount,
  count(*) from Orders
  group by Order_ID,Customer_ID,Book_ID,Order_Date,Quantity,Total_Amount
  having count(*)>1

****************************************************************************************************************

-- 1) Retrieve all books in the "Fiction" genre:

select * from Books
where Genre='fiction'

-- 2) Find books published after the year 1950:
select * from Books
where Published_Year>= 1950

-- 3) List all customers from the Canada:
select * from Customers
where Country='Canada'

-- 4) Show orders placed in November 2023:
select*from Orders
where Order_Date between '2023-11-01' and '2023-11-30' --method 1

SELECT *
FROM Orders
WHERE DATEPART(YEAR, Order_Date) = 2023 --method 2
  AND DATEPART(MONTH, Order_Date) = 11;

-- 5) Retrieve the total stock of books available:
select SUM(stock) as total_stock from Books

-- 6) Find the details of the Top 3 expensive book:

select top 3 * from Books
order by Price desc  --method 1

select *from(
select top 3 *,
ROW_NUMBER() over(order by price desc) as rnk from Books
) books
where rnk<=3  --method 2 (use only if your price have duplicates )

-- 7) Show all customers who ordered more than 1 quantity of a book:

select customer_id, sum(Quantity) as total_qnt from Orders
group by Customer_ID
having  sum(Quantity) >1

-- 8) Retrieve all orders where the total amount exceeds $20:

select Order_ID,Customer_ID,Quantity,Total_Amount from Orders
where Total_Amount>=20

-- 9) List all genres available in the Books table:
select genre from Books
group by Genre

-- 10) Find the book with the lowest stock:

select  Book_ID,Genre,Stock from Books
order by Stock  asc --method 1

SELECT Book_ID, Genre, Stock
FROM Books
WHERE Stock = (
    SELECT MIN(Stock) FROM Books) -- method 2

-- 11) Calculate the total revenue generated from all orders:

select SUM(Total_Amount) as total_amount from Orders
***********************************************************************************************************************

-- Advance Questions : 

-- 1) Retrieve the total number of books sold for each genre:

select Genre, SUM(quantity) as total_num_books from Orders O 
inner join books b on b.book_id = o.book_id
group by Genre

-- 2) Find the average price of books in the "Fantasy" genre:

select Genre,AVG(price)as avg_price from Books
where Genre='Fantasy'
group by Genre

-- 3) List customers who have placed at least 2 orders:
select c.Name,o.Customer_ID,COUNT(quantity) as total_qnt from Orders O
inner join Customers c on c.Customer_ID=O.Customer_ID
group by o.Customer_ID,c.Name
having COUNT(quantity) >=2

-- 4) Find the most frequently ordered book:

select o.Book_ID,b.Title,count(order_id)from Orders o
	inner join Books b on b.Book_ID=o.Book_ID
group by o.Book_ID,b.title
order by COUNT(order_id) desc

-- 5) Show the top 3 most expensive books of 'Fantasy' Genre :
select top 3 
 Book_ID,Title,Genre,MAX(price)as Most_exp_book  from Books
 where Genre='Fantasy'
 group by  Book_ID,Title,Genre
 order by MAX(price) desc

-- 6) Retrieve the total quantity of books sold by each author:
select b.Author,o.book_id,SUM(o.Quantity) as total_sold_qnt from Orders o
inner join Books b on b.Book_ID=o.Book_ID 
group by b.Author,o.Book_ID
order by b.Author asc

-- 7) List the cities where customers who spent over $30 are located:

select C.City,O.Customer_ID,sum(o.Total_Amount) as total_spent from Customers C
inner join Orders O on O.Customer_ID=C.Customer_ID
group by c.City,o.Customer_ID
having sum(o.Total_Amount) >30

select distinct C.City,O.Customer_ID from Customers C
inner join Orders O on O.Customer_ID=C.Customer_ID
	group by c.City,o.Customer_ID
	having sum(o.Total_Amount) >30

-- 8) Find the customer who spent the most on orders:

select top 1 
	Customer_ID,SUM(Total_Amount) as total_spent from Orders
	group by Customer_ID
	order by total_spent desc

--9) Calculate the stock remaining after fulfilling all orders:

with total_orders as (select Book_ID,sum(quantity) as total_order_qnty from Orders
						group by Book_ID)
 select b.Book_ID,b.Stock,
 isnull(t.total_order_qnty,0) as toyal_qnty,
 b.stock - isnull(t.total_order_qnty,0) as remain_qnty      --Method 1 using CTE
 from books b left join total_orders t
 on b.book_id = t.Book_ID

 OR

SELECT b.book_id, b.stock, isnull(SUM(o.quantity),0) AS Order_quantity,   -- Method 2
	b.stock- isnull(SUM(o.quantity),0) AS Remaining_Quantity
FROM books b
LEFT JOIN orders o ON b.book_id=o.book_id
GROUP BY b.book_id ,b.stock
ORDER BY b.book_id

--10)Find customers who placed orders in 2023 OR 2024

select customer_id,order_date from orders
where datepart (year,order_date)=2023 or datepart(year,order_date)=2024 -- Method 1
group by customer_id,order_date

select o.customer_id,C.Name,o.order_date from Orders o
inner join customers c on c.customer_id= o.customer_id  -- Method 2
where year(order_date) in ('2023','2024')

--11) Find customers who made purchases in 2023 but did not place any orders in 2024.
--method 1
select Customer_id from orders
where year(order_date)= 2023
group by Customer_id
Except  
select Customer_id from orders
where year(order_date)= 2024
group by Customer_id

--Method 2
select c.name, c.customer_id from customers c
where c.customer_id  in(
SELECT DISTINCT customer_id  
FROM orders
WHERE YEAR(order_date) = 2023
EXCEPT   
SELECT DISTINCT customer_id
FROM orders
WHERE YEAR(order_date) = 2024)

--12 Identify customers who placed orders in both 2023 and 2024.
select c.customer_id,c.name from customers c  --method 1
where c.customer_id  in(
SELECT DISTINCT customer_id  
FROM orders
WHERE YEAR(order_date) = 2023
intersect 
SELECT DISTINCT customer_id
FROM orders
WHERE YEAR(order_date) = 2024)

SELECT c.customer_id, c.name  --method 2
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE YEAR(o.order_date) IN (2023, 2024)
GROUP BY c.customer_id, c.name
HAVING COUNT(DISTINCT YEAR(o.order_date)) = 2;

--12) find books that have never been sold.
select book_id from books --method 1
except
select book_id from orders
order by book_id asc

SELECT b.book_id, b.title --method 2
FROM books b
LEFT JOIN orders o
    ON b.book_id = o.book_id
WHERE o.book_id IS NULL;

--13) Find cities where customers exist but no orders have ever been placed.
--method 1 using Left Join
select distinct c.city from customers c
left join orders o on o.customer_id = c.customer_id
where o.order_id is null

--Method 2 using except opreator
select distinct city from customers 
where customer_id in
(select customer_id from customers 
except
select customer_id from orders 
)

--14)calculate total spending per customer and return the top spender in each country.
with country_by_exp as(
Select o.Customer_id, c.country, sum(o.Total_amount) as total_exp from Orders o
inner join customers c on c.customer_id = o.customer_id
group by o.customer_id, c.country),

Country_rnk as (
select *,
rank () over (partition by country order by total_exp desc) as rnk
from country_by_exp)

select
customer_id, country,total_exp from Country_rnk
where rnk=1

--15)calculate monthly total sales and month-over-month growth.
with month_wise_total_sale as(
select format(order_date,'yyyy-MM') months, sum(total_amount) monthly_total_sales
from orders 
group by format(order_date,'yyyy-MM')
)

select months, monthly_total_sales,
case
when lag(monthly_total_sales) over(order by months)  is null then null
else
concat(round((monthly_total_sales - lag(monthly_total_sales) over(order by months)) * 100.0 /
lag(monthly_total_sales) over(order by months),2),'%') end
as m_o_m_growth from month_wise_total_sale
order by months

--16)calculate yearly total sales and year-over-year growth.
with sales_by_yearly as(
select year(order_date) as years, sum(total_amount) as yearly_sales from orders
group by year(order_date) )

select years,yearly_sales ,
case 
  when lag(yearly_sales) over(order by years ) is null then null
  else round((yearly_sales - lag(yearly_sales) over(order by years )) * 100.0 
  / lag(yearly_sales) over(order by years ),2)end
  as y_o_y_growth_sales
  from sales_by_yearly 
    order by years
--16)find orders where Total_Amount is greater than the average order value.

select order_id, Total_amount from orders
where total_amount >(
select avg(total_amount) as avg_total 
from Orders)

--17)identify customers contributing to 80% of total revenue.
with customer_revenue as(
select customer_id, round(sum(total_amount),2)cust_wise_total_revenue
from orders
group by customer_id),

Revenue_Rank as(
   Select customer_id,cust_wise_total_revenue,
   sum(cust_wise_total_revenue) over () as total_revenue ,
    round(sum(cust_wise_total_revenue) over (order by cust_wise_total_revenue desc
	rows between unbounded preceding and current row),2) as cumulative_revenue
	from customer_revenue )

	select customer_id,cust_wise_total_revenue,cumulative_revenue,
	round((cumulative_revenue*100.0/ total_revenue ),2) cumulative_rank
	from Revenue_Rank
	where (cumulative_revenue*100.0/ total_revenue ) <=80
	order by cust_wise_total_revenue desc

--18)Create a VIEW that shows Order_ID, Customer Name, Book Title, Genre, Quantity, and Total_Amount.

Create view book_store_view
As
select o.Order_id,name,title,genre,o.Quantity,o.Total_amount from Orders O
left join books b on b.book_id=o.book_id
left join customers c on c.customer_id = o.customer_id
go

select * from book_store_view

--19)Create a view that stores each customer’s total orders and total spending.   
create view customer_wise_orders_spending
As
select customer_id,sum(quantity) as total_qnt, round(sum(Total_amount),2)as total_exp
from orders
group by customer_id
go

select * from customer_wise_orders_spending

--20)Create a view showing books with stock less than 10 and total units sold.
create view Book_stocks
As
with Sold_book as(
select  book_id, SUM(quantity) as total_book_sold 
from Orders
Group by  Book_ID)

select b.Book_id,
b.Stock as current_stock,
s.total_book_sold ,
 (b.stock - s.total_book_sold ) as Remain_stock
	from  books b inner join Sold_book s
	on b.book_id = s.book_id
	where (b.stock - s.total_book_sold )<=10	
Go

select*from Book_stocks

--21)Find customers who placed more than one order but never ordered the same book twice.

select o.Customer_ID,c.Name,count(o.Order_ID) as total_order
from Orders o inner join Customers c
on c.Customer_ID = o.Customer_ID
group by o.Customer_ID,c.Name
having 
		count(distinct o.Order_ID) > 1  and
		count(o.book_id) = count(distinct o.book_id)

--22) Identify orders where Total_Amount does not match Book.Price × Quantity.
with final_price as(
select o.order_id, b.Price,o.quantity ,
(b.Price * o.Quantity) as total_price
from Books b
inner join Orders o on o.Book_ID = b.Book_ID
group by o.order_id,b.Price,o.quantity )

select o.order_id,f.total_price from Orders o
inner join final_price f on f.Order_ID = o.Order_ID
where o.Total_Amount<>  f.total_price

select*from books
select*from Orders
select*from Customers

--23)Find the top-selling book (by quantity) in each genre.

with top_genre as(
select b.Book_ID,b.Title,b.Genre,sum(o.quantity)total_qnt,
rank() over( partition by b.genre order by sum(o.quantity) desc) as rnk
from Books b
inner join Orders o 
on o.Book_ID = b.Book_ID
group by b.Book_ID,b.Title,b.Genre)

select book_id, Title,Genre,
total_qnt as top_selling_books
from top_genre
where rnk =1

--24)Calculate average order value per country and compare it with global average.
with country_aov as(
select c.country ,COUNT(distinct O.order_id) as total_order,round(SUM(o.total_amount),2) as Total_sales, 
round(SUM(o.total_amount) / COUNT(distinct O.order_id) ,2) as country_avg_order_value
from Orders O inner join Customers c
on c.Customer_ID =  O.Customer_ID 
group by c.country),

global_aov as(
select round(SUM(total_amount) / COUNT(distinct order_id),2) as global_avg_order_value
from Orders )


select ca.country,
ca.total_order,
ca.Total_sales,
ca.country_avg_order_value,
ga.global_avg_order_value,

case 
when country_avg_order_value > global_avg_order_value then 'Above global Avg'
when country_avg_order_value < global_avg_order_value then 'Below global Avg'
else 'Equal Global Avg'
end as global_wise_avg_comparison

from country_aov ca cross join global_aov ga





Pro tip - INTERVIEW TIP (VERY IMPORTANT)

If asked:

“Which SQL concepts did you use in your project?”

You can confidently say:

“I used CTEs for complex transformations, Views for reporting layers, 
Set Operators for customer segmentation, and Window Functions for ranking and trend analysis.” */