SELECT * FROM athletes
SELECT * FROM athlete_events


--1) which team has won the maximum gold medals over the years.??
SELECT TOP 1 A.team, COUNT(distinct event) AS total_medals
FROM athletes AS A
INNER JOIN athlete_events AS AE
ON a.id = AE.athlete_id
WHERE AE.medal = 'GOLD'
GROUP BY A.team
ORDER BY total_medals desc


--2) for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver
SELECT A.team,
COUNT(CASE WHEN AE.medal='silver' THEN medal END) AS total_silver_medals,
MAX(AE.year) AS year_of_max_silver
FROM athletes AS A
LEFT JOIN athlete_events AS AE
ON a.id = AE.athlete_id
WHERE AE.medal = 'Silver'
GROUP BY A.team 
ORDER BY total_silver_medals desc


--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years?
with cte as (
select name,medal
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id)
select top 1 name , count(1) as no_of_gold_medals
from cte 
where name not in (select distinct name from cte where medal in ('Silver','Bronze'))
and medal='Gold'
group by name
order by no_of_gold_medals desc


--4) in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.
with cte as (
select ae.year,a.name,count(1) as no_of_gold
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='Gold'
group by ae.year,a.name)
select year,no_of_gold,STRING_AGG(name,',') as players from (
select *,
rank() over(partition by year order by no_of_gold desc) as rn
from cte) a where rn=1
group by year,no_of_gold
Order By no_of_gold desc


--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport
SELECT * FROM
(SELECT medal, year, sport,team,
ROW_NUMBER() OVER(partition by medal order by year) AS dr
FROM
(SELECT AE.*, A.*
FROM athlete_events AS AE
INNER JOIN athletes AS A
ON AE.athlete_id = A.id
WHERE A.team = 'India') AS A) AS B
WHERE dr = 1


--6 find players who won gold medal in summer and winter olympics both.?
select a.name  
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='Gold'
group by a.name 
having count(distinct season)=2


--7)find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
select year,name
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal != 'NA'
group by year,name having count(distinct medal)=3


--8) find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
SELECT name,event FROM
(SELECT * , 
LAG(year) OVER(partition by name,event Order by year) AS Prev_year,
LEAD(year) OVER(partition by name,event Order by year) AS next_year
FROM
(SELECT name,year,event
FROM athletes AS A
INNER JOIN athlete_events AS AE
ON A.id = AE.athlete_id
WHERE medal = 'GOLD' 
AND year >= 2000
AND season = 'SUMMER'
GROUP BY name,year,event) AS A) AS B
WHERE year = prev_year+4 AND year = next_year-4





