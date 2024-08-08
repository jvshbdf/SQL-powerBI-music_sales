1. who is the highest authority employee in the company?

select * from employee
order by levels desc
limit 1

2. which country has the most invoices?

select billing_country,count(*) as number from invoice
group by billing_country
order by number desc

3. what are the top 3 invoice values?

select total from invoice
order by total desc
limit 3

4. which city has the most contribution in the invoice list?

select billing_city,sum(total) as tot_inv from invoice
group by billing_city
order by tot_inv desc
limit 1

5. name of the person that has spent the most amount of money?

select c.customer_id,c.first_name, c.last_name,sum(total) from customer c
join invoice i on c.customer_id=i.customer_id
group by c.customer_id
order by sum(total) desc limit 1

6. write the first name, last name, emails and genre of all rock music listeners sorted alphabetically?

select DISTINCT c.email, c.first_name, c.last_name from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line il on i.invoice_id=il.invoice_id
join track t on il.track_id=t.track_id
join genre g on t.genre_id=g.genre_id
where g.name LIKE 'Rock'
order by c.email

7. find the artist who has written the most rock music?

select a.name,count(*)as number_of_songs from artist a
join album al on al.artist_id=a.artist_id
join track t on al.album_id=t.album_id
join genre g on t.genre_id=g.genre_id
where g.name like 'Rock'
group by a.name
order by number_of_songs desc limit 10

8. list all the track names that have a song length longer than the average song length, return the name and milliseconds for each track

select * from track
select t.name, t.milliseconds from track t
where milliseconds >(
	select avg(milliseconds) from track
)
order by t.milliseconds desc


9. find how much amount is spent by each customer on a artist, list customer name, artist name and amount?

select * from customer
select * from genre
select * from invoice
select * from invoice_line
select * from playlist
select * from playlist_track
select * from track
select * from album
select * from artist
select * from employee
select * from media_type

with best_selling_artist as(
	select a.artist_id, a.name, 
	sum(il.unit_price*il.quantity) as total_sales
	from invoice_line il
	join track t on t.track_id =il.track_id
	join album al on al.album_id=t.album_id
	join artist a on a.artist_id=al.artist_id
	group by 1
	order by total_sales desc
	limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id =il.track_id
join album al on al.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=al.artist_id
group by 1,2,3,4
order by 5 desc

10. we want to find out the most popular music genre for each country
the genre with the highest amount purchase, in case of a tie return all genres

with popular_genre as
(
	select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
	row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as rowno
	from invoice_line
	join invoice on invoice.invoice_id=invoice_line.invoice_id
	join customer on customer.customer_id=invoice.customer_id
	join track on track.track_id=invoice_line.track_id
	join genre on genre.genre_id=track.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where rowno<=1

11.  write a query to return the customer that has spent the most money
from each country, write a query to return the country along with the top customer
and how much have they spent, in case of a tie return all the customers that have spent that amount

with customer_with_country as(
	select customer.customer_id, first_name, last_name, billing_country,
	sum(total) as total_spending,
	row_number() over (partition by billing_country order by sum(total) desc) as rowno
	from invoice
	join customer on customer.customer_id=invoice.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc
)
select * from customer_with_country where rowno<=1

alternate solution

with recursive
	customer_with_country as(
		select customer.customer_id, first_name, last_name, billing_country
		,sum(total) as total_spending
		from invoice 
		join customer on customer.customer_id=invoice.customer_id
		group by 1,2,3,4
		order by 2,3 desc),
	
	country_max_spending as(
		select billing_country, max(total_spending) as max_spending
		from customer_with_country
		group by billing_country)

select cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
from customer_with_country cc
join country_max_spending ms
on cc.billing_country=ms.billing_country
where cc.total_spending=ms.max_spending
order by 1;





