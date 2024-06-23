# Music store data analysis SQL project
create database music_db
use music_db;


/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

select top 1 first_name, last_name from employee order by levels desc 



/* Q2: Which countries have the most Invoices? */

select billing_country,count(*) c from invoice group by billing_country order by c desc



/* Q3: What are top 3 values of total invoice? */ 

select top 3 total from invoice order by total desc 



/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select top 1 billing_city,sum(total) invoice_total 
from invoice 
group by billing_city 
order by invoice_total desc



/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select top 1 c.customer_id,first_name,last_name,sum(total) inv_total from invoice i 
join customer c on i.customer_id=c.customer_id 
group by c.customer_id,first_name,last_name
order by inv_total desc
---------------------------


/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct email,first_name,last_name from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track t on il.track_id=t.track_id
join genre g on t.genre_id=g.genre_id
where g.name='Rock'
order by c.email




/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select top 10 ar.name,count(track_id) track_count from artist ar
join album2 al on ar.artist_id=al.artist_id
join track t on al.album_id=t.album_id
join genre g on t.genre_id=g.genre_id
where g.name like 'Rock'
group by ar.name
order by track_count desc




/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name,milliseconds from track
where milliseconds> (select avg(milliseconds) from track)
order by milliseconds desc

-------------------------------------



/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

select c.first_name,c.last_name,ar.name,sum(il.unit_price*il.quantity) total
from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track t on il.track_id=t.track_id
join album2 al on t.album_id=al.album_id
join artist ar on al.artist_id=ar.artist_id
group by c.first_name,c.last_name,ar.name
order by total desc



/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

with popular_genre as(
	select count(il.quantity) purchases,c.country,g.name ,
	rank() over(partition by c.country order by count(il.quantity) desc) rowno
	from invoice_line il 
	join invoice i on i.invoice_id=il.invoice_id
	join customer c on c.customer_id=i.customer_id
	join track t on il.track_id=t.track_id
	join genre g on t.genre_id=g.genre_id
	group by c.country,g.name)

select * from popular_genre where rowno=1




/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with customer_with_country as( 
select c.first_name,c.last_name,c.country,sum(i.total) total_spending,
rank() over(partition by c.country order by sum(i.total) desc) top_cust
from customer c
join invoice i on c.customer_id=i.customer_id
group by c.first_name,c.last_name,c.country
)

select * from customer_with_country where top_cust =1
