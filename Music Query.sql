/*Easy */
/* Đơn hàng ở mỗi quốc gia */
select billing_country, count(*) as Don_hang
from invoice
group by billing_country
order by count(*) ASC;
/* Top 3 mã khách hàng có tổng hóa đơn cao nhất  */
select customer_id, round(sum(total),2) as invoice_total
from invoice
group by customer_id
order by invoice_total ASC
limit 3;
/*Intermediate */
/* Khách hàng chi tiêu nhiều nhất ở NewYork */
Select cus.customer_id, CONCAT(cus.first_name,' ',cus.last_name) as full_name, round(sum(total),2) as invoice_total
from customer cus 
JOIN invoice inv ON cus.customer_id = inv.customer_id
where inv.billing_city = "New York"
group by cus.customer_id
order by invoice_total
LIMIT 1;

/*Nghệ sĩ có doanh thu bán nhạc cao nhất*/
Select art.name, round(sum(inv.total),2) as revenue
From artist art 
JOIN album alb ON art.artist_id=alb.artist_id
JOIN track tra ON tra.album_id = alb.album_id
JOIN invoice_line inl ON inl.track_id=tra.track_id
JOIN invoice inv ON inv.invoice_id = inl.invoice_id
group by art.name,alb.title
order by revenue DESC
Limit 1;

/* Liệt kê các nhân viên và số lượng hóa đơn họ đã tạo */
Select emp.employee_id, 
CONCAT ( emp.first_name, ' ', emp.last_name) as full_name, 
count(inv.invoice_id) as Count_Invoice
From employee emp
JOIN customer cus ON emp.employee_id = cus.support_rep_id
JOIN invoice inv ON cus.customer_id = inv.customer_id 
GROUP BY emp.employee_id;
select * from invoice;

/* Advanced */
/* Mỗi khách hàng đã chi trả bao nhiêu cho các nghệ sĩ */
WITH revenue_artist AS
(SELECT art.artist_id, 
art.name, 
SUM(inl.unit_price * inl.quantity)as total_revenue
FROM invoice_line inl
JOIN track tra ON tra.track_id = inl.track_id
JOIN album alb ON alb.album_id = tra.album_id
JOIN artist art ON art.artist_id = alb.artist_id
GROUP BY art.artist_id , art.name
)
SELECT cus.customer_id, 
CONCAT(cus.first_name,' ',cus.last_name) as full_name, 
rev.artist_id, rev.name, 
SUM(inl.unit_price * inl.quantity)as total_revenue
FROM invoice inc
JOIN customer cus ON cus.customer_id = inc.customer_id
JOIN invoice_line inl ON inl.invoice_id = inc.invoice_id
JOIN track tra ON tra.track_id = inl.track_id
JOIN album alb ON alb.album_id = tra.album_id
JOIN revenue_artist rev ON rev.artist_id = alb.artist_id
GROUP BY cus.customer_id, full_name, rev.artist_id,rev.name
ORDER BY total_revenue DESC;

/*Tính tổng số lượng track được bán theo thời gian */

WITH SalesByDate AS (
    SELECT 
        DATE_FORMAT(inv.invoice_date, '%Y-%m-01') AS month,
        COUNT(inl.invoice_line_id) AS total_sales
    FROM 
        invoice inv
    JOIN 
        invoice_line inl ON inv.invoice_id = inl.invoice_id
    GROUP BY 
        DATE_FORMAT(inv.invoice_date, '%Y-%m-01')
)
SELECT 
    month,
    total_sales
FROM 
    SalesByDate
ORDER BY 
    month;

/*Liệt kê top 5 album có doanh thu cao nhất*/
/*method 1*/
WITH AlbumRevenue AS (
    SELECT 
        alb.album_id,
        alb.title,
        SUM(inc.total) as total_revenue,
        RANK() OVER (ORDER BY SUM(inc.total) DESC) AS revenue_rank
    FROM 
        album alb
    JOIN 
        track tra ON tra.album_id = alb.album_id
	JOIN
	    invoice_line inl ON inl.track_id = tra.track_id
    JOIN 
        invoice inc ON inc.invoice_id = inl.invoice_id
    GROUP BY 
       alb.album_id,
        alb.title
)
SELECT 
    album_id,
	title,
    total_revenue
FROM 
    AlbumRevenue
WHERE 
    revenue_rank <= 5
ORDER BY 
    total_revenue DESC;
/*method 2*/
    SELECT 
        alb.album_id,
        alb.title,
        SUM(inc.total) as total_revenue
    FROM 
        album alb
    JOIN 
        track tra ON tra.album_id = alb.album_id
	JOIN
	    invoice_line inl ON inl.track_id = tra.track_id
    JOIN 
        invoice inc ON inc.invoice_id = inl.invoice_id
    GROUP BY 
       alb.album_id,
        alb.title
    ORDER BY 
    total_revenue DESC
    LIMIT 5;
    /* Doanh thu của từng album và phần trăm đóng góp doanh thu */
WITH AlbumSales AS (
    SELECT 
        alb.album_id,
        alb.title,
        round(SUM(inl.unit_price * inl.quantity),2) AS album_revenue,
        round(SUM(SUM(inl.unit_price * inl.quantity)) OVER (),2) AS total_revenue_all_albums
    FROM 
        album alb
    JOIN 
        track tra ON tra.album_id = alb.album_id
    JOIN 
        invoice_line inl ON inl.track_id = tra.track_id
    GROUP BY 
        alb.album_id, alb.title
)
SELECT 
    album_id,
    title,
    album_revenue,
    total_revenue_all_albums,
    (album_revenue / total_revenue_all_albums) * 100 AS contribution_percentage
FROM 
    AlbumSales;



