create database iTUNESmusic;
use iTUNESmusic;
CREATE TABLE artist (
    artist_id INT PRIMARY KEY,
    name VARCHAR(255)
);
CREATE TABLE album (
    album_id INT PRIMARY KEY,
    title VARCHAR(255),
    artist_id INT,
    FOREIGN KEY (artist_id) REFERENCES artist(artist_id)
);
CREATE TABLE genre (
    genre_id INT PRIMARY KEY,
    name VARCHAR(100)
);
CREATE TABLE media_type (
    media_type_id INT PRIMARY KEY,
    name VARCHAR(100)
);
CREATE TABLE track (
    track_id INT PRIMARY KEY,
    name VARCHAR(255),
    album_id INT,
    media_type_id INT,
    genre_id INT,
    composer VARCHAR(255),
    milliseconds INT,
    bytes INT,
    unit_price DECIMAL(5,2),

    FOREIGN KEY (album_id) REFERENCES album(album_id),
    FOREIGN KEY (media_type_id) REFERENCES media_type(media_type_id),
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);
CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    last_name VARCHAR(100),
    first_name VARCHAR(100),
    title VARCHAR(100),
    reports_to INT,
    levels VARCHAR(50),
    birthdate DATE,
    hire_date DATE,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(100),

    FOREIGN KEY (reports_to) REFERENCES employee(employee_id)
);
CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    company VARCHAR(255),
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    phone VARCHAR(50),
    fax VARCHAR(50),
    email VARCHAR(100),
    support_rep_id INT,

    FOREIGN KEY (support_rep_id) REFERENCES employee(employee_id)
);
CREATE TABLE invoice (
    invoice_id INT PRIMARY KEY,
    customer_id INT,
    invoice_date DATETIME,
    billing_address VARCHAR(255),
    billing_city VARCHAR(100),
    billing_state VARCHAR(100),
    billing_country VARCHAR(100),
    billing_postal_code VARCHAR(20),
    total DECIMAL(10,2),

    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
);
CREATE TABLE invoice_line (
    invoice_line_id INT PRIMARY KEY,
    invoice_id INT,
    track_id INT,
    unit_price DECIMAL(5,2),
    quantity INT,

    FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id),
    FOREIGN KEY (track_id) REFERENCES track(track_id)
);
CREATE TABLE playlist (
    playlist_id INT PRIMARY KEY,
    name VARCHAR(255)
);
CREATE TABLE playlist_track (
    playlist_id INT,
    track_id INT,
    PRIMARY KEY (playlist_id, track_id),

    FOREIGN KEY (playlist_id) REFERENCES playlist(playlist_id),
    FOREIGN KEY (track_id) REFERENCES track(track_id)
);
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 
'C:/Users/Public/Uploads/album.csv'
INTO TABLE album
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 
'C:/Users/Public/Uploads/genre.csv'
INTO TABLE genre
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 
'C:/Users/Public/Uploads/media_type.csv'
INTO TABLE media_type
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 
'C:/Users/Public/Uploads/track.csv'
INTO TABLE track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET FOREIGN_KEY_CHECKS = 0;

SET FOREIGN_KEY_CHECKS = 0;

LOAD DATA INFILE 
'C:/Users/Public/Uploads/employee.csv'
INTO TABLE employee
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(@employee_id,@last_name,@first_name,@title,@reports_to,@levels,
 @birthdate,@hire_date,@address,@city,@state,@country,@postal_code,
 @phone,@fax,@email)
SET
employee_id=@employee_id,
last_name=@last_name,
first_name=@first_name,
title=@title,
reports_to=NULLIF(@reports_to,''),
levels=@levels,
birthdate=STR_TO_DATE(@birthdate,'%d-%m-%Y %H:%i'),
hire_date=STR_TO_DATE(@hire_date,'%d-%m-%Y %H:%i'),
address=@address,
city=@city,
state=@state,
country=@country,
postal_code=@postal_code,
phone=@phone,
fax=@fax,
email=@email;

SET FOREIGN_KEY_CHECKS = 1;

LOAD DATA INFILE 
'C:/Users/Public/Uploads/customer.csv'
INTO TABLE customer
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 
'C:/Users/Public/Uploads/invoice.csv'
INTO TABLE invoice
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 
'C:/Users/Public/Uploads/invoice_line.csv'
INTO TABLE invoice_line
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 
'C:/Users/Public/Uploads/playlist.csv'
INTO TABLE playlist
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 
'C:/Users/Public/Uploads/playlist_track.csv'
INTO TABLE playlist_track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM customer;
SELECT COUNT(*) FROM invoice;
SELECT COUNT(*) FROM track;
SELECT COUNT(*) FROM artist;
SELECT COUNT(*) FROM invoice_line;

/*1. Customer Analytics*/
/*Customers Who Spent Most*/
SELECT CONCAT(c.first_name,' ',c.last_name) customer,
       SUM(i.total) spent
FROM customer c
JOIN invoice i ON c.customer_id=i.customer_id
GROUP BY c.customer_id
ORDER BY spent DESC;

/*Average Customer Lifetime Value*/
SELECT AVG(total_spent) avg_ltv
FROM(
SELECT customer_id, SUM(total) total_spent
FROM invoice
GROUP BY customer_id
)
/*79.820847*/

/* 2.Sales & Revenue Analysis
Monthly Revenue Trend (Last 2 Years)*/
SELECT DATE_FORMAT(invoice_date,'%Y-%m') AS month,
       SUM(total) AS revenue
FROM invoice
WHERE invoice_date >= (
      SELECT DATE_SUB(MAX(invoice_date), INTERVAL 2 YEAR)
      FROM invoice
)
GROUP BY month
ORDER BY month

SELECT CONCAT(e.first_name,' ',e.last_name) rep,
       SUM(i.total) revenue
FROM employee e
JOIN customer c ON e.employee_id=c.support_rep_id
JOIN invoice i ON c.customer_id=i.customer_id
GROUP BY rep
ORDER BY revenue DESC;
/*Jane Peacock	1731.51
Margaret Park	1584.00
Steve Johnson	1393.92*/

/*Peak Sales Months*/
SELECT MONTHNAME(invoice_date) month,
       SUM(total) revenue
FROM invoice
GROUP BY month
ORDER BY revenue DESC;

/*3. Product Analysis*/
/*Tracks Generating Most Revenue*/
SELECT t.name,
       SUM(il.unit_price*il.quantity) revenue
FROM track t
JOIN invoice_line il ON t.track_id=il.track_id
GROUP BY t.name
ORDER BY revenue DESC;

/*Albums Most Purchased*/
SELECT al.title,
       COUNT(*) purchases
FROM album al
JOIN track t ON al.album_id=t.album_id
JOIN invoice_line il ON t.track_id=il.track_id
GROUP BY al.title
ORDER BY purchases DESC;

/*Tracks Never Purchased*/
SELECT name
FROM track
WHERE track_id NOT IN
(SELECT DISTINCT track_id FROM invoice_line);

/*Track Count vs Sales per Genre*/
SELECT g.name,
       COUNT(DISTINCT t.track_id) tracks,
       SUM(il.quantity) sold
FROM genre g
JOIN track t ON g.genre_id=t.genre_id
LEFT JOIN invoice_line il ON t.track_id=il.track_id
GROUP BY g.name;

/*4. Artist & Genre Performance
Top 5 Artists by Revenue*/
SELECT ar.name,
       SUM(il.unit_price*il.quantity) revenue
FROM artist ar
JOIN album al ON ar.artist_id=al.artist_id
JOIN track t ON al.album_id=t.album_id
JOIN invoice_line il ON t.track_id=il.track_id
GROUP BY ar.name
ORDER BY revenue DESC
LIMIT 5;

/*Genre Popularity*/
SELECT g.name,
       SUM(il.quantity) sold,
       SUM(il.unit_price*il.quantity) revenue
FROM genre g
JOIN track t ON g.genre_id=t.genre_id
JOIN invoice_line il ON t.track_id=il.track_id
GROUP BY g.name
ORDER BY revenue DESC;

/*Genre Popularity by Country*/
SELECT c.country, g.name genre,
       SUM(il.quantity) sold
FROM invoice_line il
JOIN invoice i ON il.invoice_id=i.invoice_id
JOIN customer c ON i.customer_id=c.customer_id
JOIN track t ON il.track_id=t.track_id
JOIN genre g ON t.genre_id=g.genre_id
GROUP BY c.country, g.name
ORDER BY c.country, sold DESC;

/*Revenue by Employee Region*/
SELECT e.country,
       SUM(i.total) revenue
FROM employee e
JOIN customer c ON e.employee_id=c.support_rep_id
JOIN invoice i ON c.customer_id=i.customer_id
GROUP BY e.country;

/*6. Geographic Trends
Countries with Most Customers*/
SELECT country, COUNT(*) customers
FROM customer
GROUP BY country
ORDER BY customers DESC;

/*Revenue by Region*/
SELECT billing_country,
       SUM(total) revenue
FROM invoice
GROUP BY billing_country
ORDER BY revenue DESC;

/*7. Customer Retention
Purchase Frequency Distribution*/
SELECT purchase_count,
       COUNT(*) customers
FROM(
SELECT customer_id,
       COUNT(*) purchase_count
FROM invoice
GROUP BY customer_id
)x
GROUP BY purchase_count;

/*8. Operational Optimization
Track Combinations Bought Together*/
SELECT a.track_id track1,
       b.track_id track2,
       COUNT(*) times
FROM invoice_line a
JOIN invoice_line b
ON a.invoice_id=b.invoice_id
AND a.track_id<b.track_id
GROUP BY track1,track2
ORDER BY times DESC
LIMIT 10;

/*Media Type Trend*/
SELECT mt.name,
       SUM(il.quantity) usage_count
FROM media_type mt
JOIN track t ON mt.media_type_id=t.media_type_id
JOIN invoice_line il ON t.track_id=il.track_id
GROUP BY mt.name
ORDER BY usage_count DESC;

/*Q1. Senior Most Employee */
SELECT employee_id,
       first_name,
       last_name,
       title,
       levels
FROM employee
ORDER BY levels DESC
LIMIT 1;

/*Q2. Countries With Most Invoices*/
SELECT billing_country,
       COUNT(invoice_id) AS total_invoices
FROM invoice
GROUP BY billing_country
ORDER BY total_invoices DESC;

/*Q3. Top 3 Invoice Totals*/
SELECT invoice_id,
       total
FROM invoice
ORDER BY total DESC
LIMIT 3;

/*Q4. City With Highest Revenue*/
SELECT billing_city,
       SUM(total) AS total_revenue
FROM invoice
GROUP BY billing_city
ORDER BY total_revenue DESC
LIMIT 1;

/*Q5. Best Customer (Highest Spending)*/
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       SUM(i.total) AS total_spent
FROM customer c
JOIN invoice i 
     ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 1;

/*Q6 — Rock Music Listeners*/
SELECT DISTINCT
       c.email,
       c.first_name,
       c.last_name
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
LEFT JOIN invoice_line il ON i.invoice_id = il.invoice_id
LEFT JOIN track t ON il.track_id = t.track_id
LEFT JOIN genre g ON t.genre_id = g.genre_id
WHERE LOWER(g.name) LIKE '%rock%';

/*Q7 — Top 10 Rock Artists by Track Count*/
SELECT ar.name AS artist_name,
       COUNT(t.track_id) AS track_count
FROM artist ar
JOIN album al   ON ar.artist_id = al.artist_id
JOIN track t    ON al.album_id = t.album_id
JOIN genre g    ON t.genre_id = g.genre_id
WHERE LOWER(g.name) LIKE '%rock%'
GROUP BY ar.artist_id, ar.name
ORDER BY track_count DESC
LIMIT 10;

/*Q8 — Tracks Longer Than Average Length*/
SELECT name,
       milliseconds
FROM track
WHERE milliseconds > (
        SELECT AVG(milliseconds)
        FROM track
     )
ORDER BY milliseconds DESC;

/*Q9 — Amount Spent by Each Customer on Artists*/
SELECT 
       c.first_name,
       c.last_name,
       ar.name AS artist_name,
       SUM(il.unit_price * il.quantity) AS total_spent
FROM customer c
JOIN invoice i        ON c.customer_id = i.customer_id
JOIN invoice_line il  ON i.invoice_id = il.invoice_id
JOIN track t          ON il.track_id = t.track_id
JOIN album al         ON t.album_id = al.album_id
JOIN artist ar        ON al.artist_id = ar.artist_id
GROUP BY c.customer_id, ar.artist_id
ORDER BY total_spent DESC;