Select* from athlete_events
Select * from noc_regions

--Q1 How many Olympic games have been held ?

Select Count(distinct games)as total_game
from athlete_events

-- Q2 List down all Olympic games held so far?
  
Select Distinct year,season,games as list_game
from athlete_events
order by year

-- Q3.Mention the total number of nations who participated in each olympics game?

Select a.games, count( distinct region) as total_region_participated
from athlete_events a
join noc_regions n
on a.noc=n.noc
group by a.games

-- Q4.Which year saw the highest and lowest no of countries participating in olympics?

with games_count as(Select a.games, count(distinct n.region)as region_participated
from athlete_events a
join noc_regions n
on a.noc=n.noc
group by a.games)

, ranking as(
Select games, region_participated, rank()over(order by region_participated desc)as highest_rank,
	rank()over(order by region_participated asc) as lowest_rank
from games_count
)

Select 
max(Case when lowest_rank =1 then games ||' - '|| region_participated end)as lowest_countries,
max(Case when highest_rank =1 then games ||' - ' ||region_participated end)as highest_countries
from ranking

 -- Q.5 Which nation has participated in all of the olympic games

with total_games as(
select count(distinct games)as total_games_held
from athlete_events)

, countries_participating as(
Select n.region ,count(distinct games)as games_participated
from noc_regions n
join athlete_events a
ON n.noc =a.noc
group by n.region)

Select c.region ,c.games_participated
from total_games t
join countries_participating c
on t.total_games_held=c.games_participated


-- Q6.Identify the sport which was played in all summer olympics.

With total_summer_games as(
Select count(distinct games)as game_count
from athlete_events
where season ='Summer')

, Sport_games as(
Select sport,count(distinct games) as no_of_games
from athlete_events
where season ='Summer'
group by sport)

Select sg.sport,no_of_games
from total_summer_games tg
join sport_games sg
on tg.game_count =sg.no_of_games


-- Q7.Which Sports were just played only once in the olympics.

Select sport, count(distinct games)no_of_games
from athlete_events
group by sport
having count(distinct games)=1
order by sport 

-- Q8. Fetch the total no of sports played in each olympic games.

Select games,count (distinct sport)as sport_cnt
from athlete_events
group by games
order by sport_cnt desc

-- Q9. Fetch oldest athletes to win a gold medal
with age_raNKING AS(
Select name,sex,age,rank()over(order by age desc) as rn
from athlete_events
where medal='Gold')

Select name,sex,age
from age_ranking
where rn =1

-- Q10. Find the Ratio of male and female athletes participated in all olympic games.

Select '1 '+cast(round(male_count/female_count,2)as varchar(10))
from (

Select count(  distinct case when Sex ='M' then name end )as male_count,
	count( distinct case when Sex ='F' then name end )as female_count
from athlete_events
) a


-- Q11. Fetch the top 5 athletes who have won the most gold medals.

Select  top 5 name, COunt(medal) as total_medal_count
from athlete_events
where medal ='Gold'
group by name
order by total_medal_count desc

-- Q12. Fetch the top 5 athletes who have won the most medals(gold/silver/bronze)
  
 Select  top 5 name,count(medal)as total_medal
 from athlete_events
 where Medal in ('Gold','Silver','Bronze')
 group by name
 order by total_medal desc

 --Q13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

 Select  top 5 region,count(medal) as total_medals
 from athlete_events a
 join noc_regions n
 on a.NOC =n.noc
 where Medal in ('Gold','Silver','Bronze')
 group by region
 order by total_medals desc

 -- Q14.List down total gold, silver and bronze medals won by each country.

 Select n.region,
		coalesce(Sum(Case when medal ='gold' then 1 end),0)as Gold_medal,
		coalesce(Sum(Case when medal ='Silver' then 1 end),0) as Silver_medal,
		coalesce(Sum(Case when medal ='Bronze' then 1 end),0) as Bronze_medal
 from athlete_events a
 join noc_regions n
 on a.NOC=n.noc
 where medal <>'NA'
 group by n.region
 order by Gold_medal desc,silver_medal desc,bronze_medal desc

 -- Q15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

 Select games, region,
 Sum(Case when medal ='Gold' then 1 else 0 end )as gold,
 Sum(case when medal= 'Silver' then 1 else 0 end ) as silver,
 Sum(Case when medal ='Bronze' then 1 else 0 end)as Bronze
 from athlete_events  a
 join noc_regions n
 on a.noc =n.NOC
 group by games,region 
 order by games

 -- Q16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.


 with medal_count as(

 Select a.Games,n.region,
 Sum(Case when Medal ='Gold' then 1 else 0 end)as Gold,
 Sum(Case when Medal ='Silver' then 1 else 0 end)as Silver,
 Sum(Case when Medal ='Bronze' then 1 else 0 end)as Bronze
 from athlete_events a
 join noc_regions n
 on a.NOC =n.noc
 where a.Medal is not null
 group by a.Games,n.region
)

, ranked as(
Select *, 
Dense_rank() over (partition by games order by gold desc)as gold_rank,
Dense_rank() over (partition by games order by Silver desc)as Silver_rank,
Dense_rank() over (partition by games order by bronze desc)as bronze_rank
from medal_count

)

SELECT
    Games,
    MAX(CASE WHEN gold_rank = 1 THEN region END) AS Most_Gold,
    MAX(CASE WHEN gold_rank = 1 THEN Gold END) AS Gold_Medals,
    MAX(CASE WHEN silver_rank = 1 THEN region END) AS Most_Silver,
    MAX(CASE WHEN silver_rank = 1 THEN Silver END) AS Silver_Medals,
    MAX(CASE WHEN bronze_rank = 1 THEN region END) AS Most_Bronze,
    MAX(CASE WHEN bronze_rank = 1 THEN Bronze END) AS Bronze_Medals
FROM ranked
GROUP BY Games
ORDER BY Games


--  Q17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.


    with medal_count as(

     Select a.Games,n.region,
     Sum(Case when Medal ='Gold' then 1 else 0 end)as Gold,
     Sum(Case when Medal ='Silver' then 1 else 0 end)as Silver,
     Sum(Case when Medal ='Bronze' then 1 else 0 end)as Bronze
     from athlete_events a
     join noc_regions n
     on a.NOC =n.noc
     where a.Medal is not null
     group by a.Games,n.region
    )

    , ranked as(
    Select *, 
    Dense_rank() over (partition by games order by gold desc)as gold_rank,
    Dense_rank() over (partition by games order by Silver desc)as Silver_rank,
    Dense_rank() over (partition by games order by bronze desc)as bronze_rank,
    Dense_rank() over (partition by games order by (gold + silver + bronze) desc)as total_rank
    from medal_count

    )

    SELECT
        Games,
        MAX(CASE WHEN gold_rank = 1 THEN region END) AS Most_Gold,
        MAX(CASE WHEN gold_rank = 1 THEN Gold END) AS Gold_Medals,
        MAX(CASE WHEN silver_rank = 1 THEN region END) AS Most_Silver,
        MAX(CASE WHEN silver_rank = 1 THEN Silver END) AS Silver_Medals,
        MAX(CASE WHEN bronze_rank = 1 THEN region END) AS Most_Bronze,
        MAX(CASE WHEN bronze_rank = 1 THEN Bronze END) AS Bronze_Medals,
         MAX(CASE WHEN total_rank = 1 THEN region END) AS Most_Medals,
        MAX(CASE WHEN total_rank = 1 
                 THEN (Gold + Silver + Bronze) END) AS Total_Medals
    FROM ranked
    GROUP BY Games
    ORDER BY Games

    -- Q18. Which countries have never won gold medal but have won silver/bronze medals?

   
   with medal_count as(
   Select n.region ,
     Sum(Case when Medal ='Gold' then 1 else 0 end)as Gold,
     Sum(Case when Medal ='Silver' then 1 else 0 end)as Silver,
     Sum(Case when Medal ='Bronze' then 1 else 0 end)as Bronze
    from athlete_events a
    join noc_regions n
    on a.NOC = n.noc
    group by n.region
    )

    Select *
    from medal_count
    where gold =0 and (silver >0 or bronze >0)
    order by silver, bronze desc

    -- Q19. in which Sport/event, India has won highest medals

    Select  top 1 sport,count(medal)as total_medal
    from athlete_events a
    join noc_regions N
    ON a.NOC=n.NOC
    where n.region ='India'
    group by sport
    order by total_medal desc


    --  Q20. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games

    Select region as team, sport , games,count(medal)as total_medal
    from athlete_events a
    join noc_regions n
    on a.NOC =n.noc
    where region ='India'
    and sport ='hockey'
    group by region ,sport,games
    order by total_medal desc
     
