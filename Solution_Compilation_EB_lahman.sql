--Q2

SELECT namefirst, namelast, SUM(COALESCE(salary,0))::int::money AS earnings
FROM people
LEFT JOIN salaries
USING (playerid)
WHERE playerid IN (SELECT playerid FROM collegeplaying WHERE schoolid = 'vandy')
GROUP BY playerid
ORDER BY earnings DESC;

--Q2 (incorrect)

SELECT DISTINCT collegeplaying.playerid,
	people.namefirst,
	people.namelast,
	SUM(salaries.salary)::numeric::money
FROM collegeplaying
LEFT JOIN people
ON collegeplaying.playerid = people.playerid
LEFT JOIN salaries
ON collegeplaying.playerid = salaries.playerid
WHERE collegeplaying.schoolid = 'vandy'
AND salaries.salary IS NOT NULL
GROUP BY collegeplaying.playerid, people.namefirst, people.namelast
ORDER BY SUM(salaries.salary)::numeric::money DESC;

--Q3 JOSH SOLUTION

SELECT p.namefirst,
		p.namelast,
		SUM(COALESCE(s.salary,0))::text::money AS total_salary
FROM people AS p
INNER JOIN (SELECT DISTINCT playerid, schoolid
			FROM collegeplaying) AS cp
	USING (playerid)
INNER JOIN schools AS sch
	USING (schoolid)
INNER JOIN salaries AS s
	USING (playerid)
WHERE sch.schoolname = 'Vanderbilt University'
GROUP BY p.namefirst, p.namelast
ORDER BY total_salary DESC;

--Q3 CHRIS SOLUTION

WITH vandy_players AS (SELECT DISTINCT(playerid)
FROM collegeplaying
WHERE schoolid ILIKE 'vandy'),
vandy_majors AS (SELECT people.playerid, CONCAT(namefirst, ' ', namelast) AS full_name
FROM people INNER JOIN vandy_players ON people.playerid = vandy_players.playerid)
SELECT vandy_majors.playerid, full_name, SUM(salary)::text::money AS total_salary
FROM salaries INNER JOIN vandy_majors ON salaries.playerid = vandy_majors.playerid
GROUP BY full_name, vandy_majors.playerid
ORDER BY total_salary DESC

--Q4 SCOTT MOORE

Select sum(po),
case when pos = 'OF' then 'Outfield'
when pos IN ('SS', '1B', '2B', '3B') then 'Infield'
when pos IN ('P', 'C') then 'Battery'
end as position
from fielding
group by position;

--Q4 DARCY MACK

WITH grouped_positions as (SELECT *, CASE WHEN pos = 'OF' THEN 'Outfield'
									   	  WHEN pos = 'SS'
						   					OR pos = '1B'
						   					OR pos = '2B'
						   					OR pos = '3B'
						   					THEN 'Infield'
			                           	  WHEN pos = 'P'
						   					OR pos = 'C'
						   					THEN 'Battery' END as pos_group
						   FROM fielding)
SELECT pos_group, SUM(po) as putouts
FROM grouped_positions
WHERE yearid = '2016'
GROUP BY pos_group;

--Q4 ZENON

WITH grouped_fielding AS (SELECT DISTINCT pos, SUM(PO) AS total_po, fielding.yearid,
		CASE WHEN pos = 'OF' then 'Outfield'
			WHEN pos = 'SS' THEN 'Infield'
			WHEN pos = '1B' THEN 'Infield'
			WHEN pos = '2B' THEN 'Infield'
			WHEN pos = '3B' THEN 'Infield'
			WHEN pos = 'P' THEN 'Battery'
			WHEN pos = 'C' THEN 'Battery' END AS fielding_grouped
	FROM fielding
	WHERE yearid = (2016)
	GROUP BY fielding_grouped, fielding.pos, fielding.yearid
	ORDER BY yearid)
SELECT SUM(total_po), fielding_grouped
FROM grouped_fielding
GROUP BY fielding_grouped

--Q5 SCOTT

SELECT (yearid/10)*10 as decade, Round((SUM(so)::DECIMAL / SUM(ghome)::DECIMAL),2) AS so_per_game, Round((SUM(hr)::DECIMAL / SUM(ghome)::DECIMAL),2) AS hr_per_game
FROM teams
WHERE yearid >=1920
GROUP BY decade
ORDER BY decade;

--Q5 PATRICK

WITH so_hr_by_decade AS (SELECT
						CONCAT(LEFT(yearid::text, 3), '0s') AS decade,
						SUM(so)::numeric AS total_so_batting,
						SUM(soa)::numeric AS total_so_pitching,
						SUM(hr)::numeric AS total_hr_batting,
						SUM(hra)::numeric AS total_hra_pitching,
						(SUM(g)/2)::numeric AS total_games_played
					FROM teams
					 WHERE yearid>1919
					GROUP BY decade
					ORDER BY decade)
SELECT decade,
ROUND((total_so_batting/total_games_played),2) AS avg_so_game_bat,
ROUND((total_so_pitching/total_games_played),2) AS avg_so_game_pit,
ROUND((total_hr_batting/total_games_played),2) AS avg_hr_game_bat,
ROUND((total_hra_pitching/total_games_played),2) AS avg_hra_game_pit
FROM so_hr_by_decade

--Q6 DARCY

SELECT namegiven, sb, cs,
	   ROUND(((sb::numeric/(sb::numeric + cs::numeric))*100),2) AS percent_successful_steal
FROM people FULL JOIN batting
	ON people.playerid = batting.playerid
WHERE (sb::numeric+cs::numeric) >= 20
AND yearid = 2016
ORDER BY percent_successful_steal DESC;

--Q6 JULIEN

SELECT B.PLAYERID,
	PL.NAMEFIRST,
	PL.NAMELAST,
	B.SB::decimal,
	B.CS::decimal,
	ROUND((B.SB::decimal / (B.SB::decimal + B.CS::decimal)),2) AS SB_SUCCESS
FROM BATTING AS B
LEFT JOIN PEOPLE AS PL ON B.PLAYERID = PL.PLAYERID
WHERE B.YEARID = '2016'
	AND B.SB + B.CS >= 20
ORDER BY SB_SUCCESS DESC


--Q6 TONI

WITH ps as (SELECT yearid,playerid,
			       SUM(sb) as post_sb,
			       SUM(cs) as post_cs
		           FROM battingpost
		     WHERE yearid = 2016
		     GROUP BY yearid,playerid
		     ORDER BY SUM(sb) DESC)
SELECT p.namefirst,
       p.namelast,
       b.yearid,
       sb::decimal,
	   cs::decimal,
	   post_sb,
	   post_cs,
	   CASE WHEN post_sb IS NULL THEN sb+cs
	        WHEN post_sb IS NOT NULL THEN sb+cs+post_sb+post_cs
			END AS total_attempt,
		CASE WHEN post_sb IS NULL THEN (sb::decimal/(sb+cs)::decimal)
		     WHEN post_sb IS NOT NULL THEN ROUND(((sb+post_sb)::decimal/(sb+cs+post_sb+post_cs)::decimal),4)
	         END AS success_rate
	  
	
	  
FROM batting as b
LEFT JOIN people as p
ON b.playerid = p.playerid
LEFT JOIN ps
ON b.playerid = ps.playerid
WHERE b.yearid = 2016
AND sb+cs+post_sb+post_cs >20
ORDER BY success_rate DESC

--Q7 ROBERT

SELECT w, name, yearid, wswin
FROM teams
WHERE wswin = 'N'
AND yearid BETWEEN 1970 AND 2016
GROUP BY w, name, yearid, wswin
ORDER BY w DESC
LIMIT 1;

--Q7 PRESTON

WITH winworld AS (
	SELECT yearID, name, (CASE WHEN W = MAX(W) OVER(PARTITION BY yearID) AND WSwin = 'Y' THEN 1 ELSE 0 END) AS max_wins, WSwin
	FROM teams
	WHERE yearid >= 1970 AND yearid <> 1981
	)
SELECT ROUND(SUM(max_wins)::DECIMAL / COUNT(WSwin) * 100,1) as max_win_percent
FROM winworld
WHERE WSwin = 'Y'

--Q7 JOSH

WITH max_wins AS (
	SELECT yearid,
			MAX(w) AS max_w
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016
	GROUP BY yearid
	ORDER BY yearid
	)
SELECT SUM(CASE WHEN wswin = 'Y' THEN 1 ELSE 0 END) AS ct_max_is_champ,
		ROUND(100*AVG(CASE WHEN wswin = 'Y' THEN 1 ELSE 0 END), 2) AS perc_max_is_champ
FROM max_wins AS m
INNER JOIN teams AS t
	ON m.yearid = t.yearid AND m.max_w = t.w
	
--Q8 JONATHAN

(SELECT park_name,
       t.name AS team_name,
       ROUND((AVG(h.attendance)/h.games),0) AS avg_attendance,
       'TOP 5' AS ranking
FROM homegames AS h
INNER JOIN parks AS p
USING (park)
	LEFT JOIN teams AS t
	ON t.park =p.park_name
WHERE year= '2016'
AND games >'10'
AND t.yearid = '2016'
GROUP BY park_name,t.name,games
ORDER BY avg_attendance DESC
LIMIT 5)
UNION
(SELECT park_name,
       t.name AS team_name,
       ROUND((AVG(h.attendance)/h.games),0) AS avg_attendance,
       'BOTTOM 5' AS ranking
FROM homegames AS h
INNER JOIN parks AS p
USING (park)
	LEFT JOIN teams AS t
	ON t.park =p.park_name
WHERE year= '2016'
AND games >'10'
AND t.yearid = '2016'
GROUP BY park_name,t.name,games
ORDER BY avg_attendance ASC
LIMIT 5)
ORDER BY Avg_attendance DESC;

--Q8 JOSH

SELECT team,
			name,
			park_name,
			ROUND(hg.attendance::numeric/ hg.games) AS avg_att
	FROM homegames AS hg
	LEFT JOIN parks
	USING (park)
	LEFT JOIN teams AS t
	ON hg.team = t.teamid AND hg.year = t.yearid
	WHERE year = 2016 AND games >= 10
	ORDER BY hg.attendance/hg.games DESC
	LIMIT 5;
	
--Q9 SCOTT

Select people.namefirst, people.namelast, teams.name, awardsmanagers.lgid, awardsmanagers.yearid
from awardsmanagers
left join people
on awardsmanagers.playerid = people.playerid
left join managers
on managers.playerid = awardsmanagers.playerid
and managers.yearid = awardsmanagers.yearid
left join teams
on managers.yearid = teams.yearid
and managers.teamid = teams.teamid
WHERE awardsmanagers.playerid in (
			SELECT playerid
			FROM awardsmanagers
			WHERE awardid ILIKE 'TSN%'
			AND lgid = 'AL'
			INTERSECT
			SELECT playerid
			FROM awardsmanagers
			WHERE awardid ILIKE 'TSN%'
			AND lgid = 'NL')
and awardsmanagers.awardid ILIKE 'TSN%';

--Q9 HOLLY

WITH qualifying_managers AS (SELECT playerid,
									yearid,
									awardid,
									lgid
							FROM awardsmanagers
							WHERE awardid = 'TSN Manager of the Year'
							AND lgid IN ('NL','AL')
							AND playerid IN (	SELECT 	playerid
											FROM awardsmanagers
											WHERE awardid = 'TSN Manager of the Year'
											AND lgid IN ('NL','AL')
											GROUP BY playerid
											HAVING COUNT(DISTINCT(lgid))=2)
							 ),
							
qm_with_names AS (	SELECT 	namefirst,
				  			namelast,
				  			qm.*
				  	FROM qualifying_managers AS qm
				  	LEFT JOIN people AS p
				  	USING(playerid)
				 ),
					
qm_with_teamid AS (	SELECT 	DISTINCT q.*,
							m.teamid
					FROM qm_with_names AS q
					LEFT JOIN managers AS m
					USING(playerid)
					LEFT JOIN teams AS t
					USING(teamid)
					WHERE m.yearid=q.yearid
					AND m.lgid IN (SELECT lgid
								   FROM qm_with_names))
								  
SELECT 	qmt.namefirst || ' ' || qmt.namelast AS full_name,
		t.name,
		qmt.yearid,
		awardid,
		qmt.lgid
FROM qm_with_teamid AS qmt
LEFT JOIN teams AS t
USING(teamid)
WHERE qmt.yearid = t.yearid
ORDER BY namefirst, yearid;

--Q9 PRESTON

SELECT CONCAT(namefirst,' ', namelast) AS fullname, teams.name, awardid, awardsmanagers.lgid, awardsmanagers.yearid
FROM awardsmanagers
LEFT JOIN people
	ON awardsmanagers.playerid = people.playerid
LEFT JOIN managers
	ON managers.playerid = awardsmanagers.playerid
	AND managers.yearid = awardsmanagers.yearid
LEFT JOIN teams
	ON managers.teamid = teams.teamid
	AND managers.yearid = teams.yearid
WHERE awardsmanagers.playerid IN (
			SELECT playerid
			FROM awardsmanagers
			WHERE awardid ILIKE 'TSN%'
			AND lgid = 'AL'
			INTERSECT
			SELECT playerid
			FROM awardsmanagers
			WHERE awardid ILIKE 'TSN%'
			AND lgid = 'NL'
			)
AND awardid ILIKE 'TSN%'

--Q10 

with removeyear as (
select distinct playerid, schoolid
	from collegeplaying
)
select  schoolname, count(distinct playerid) as player_count,
 sum(g_all) as total_games, avg(salary)::numeric::money as avg_salary,
 count(case when wswin='Y' then 'asdfdafdsa' end)
 as players_ws_wins
--select distinct appearances.teamid,teams.yearid, wswin
from appearances
left join removeyear
	using(playerid)
	
left join salaries
using (playerid, yearid)
	
left join schools
	using (schoolid)
left join teams
on(appearances.teamid = teams.teamid and appearances.yearid = teams.yearid)
where schoolstate = 'TN'
 group by schoolname
 order by players_ws_wins desc
 
--Q11 DARCY

WITH team_wins_salaries as (SELECT s.teamid, s.yearid as year, SUM(s.salary) as team_salary, (t.w) as wins
							FROM salaries AS s LEFT JOIN teams AS t
								ON s.teamid=t.teamid
								AND s.yearid=t.yearid
							WHERE s.yearid >= 2000
							GROUP BY s.teamid, s.yearid, t.w
							ORDER BY s.teamid, s.yearid)
SELECT DISTINCT year, CORR(wins, team_salary) OVER(PARTITION BY year) as correlation
FROM team_wins_salaries
ORDER BY year;

--Q11 PRESTON

WITH teamwinper AS (
	SELECT DISTINCT s.yearid, s.teamid,
		(ROUND((w::DECIMAL/g::DECIMAL)*100,0)::INT)/5*5 AS winper,
		sum(salary) OVER(PARTITION BY (s.yearid, s.teamid)) AS teamsal
	FROM salaries AS s
	LEFT JOIN teams
	ON s.yearid = teams.yearid
		AND s.teamid = teams.teamid
	WHERE s.yearid >= 2000
	ORDER BY teamsal
	)
SELECT yearid, winper, avg(teamsal)::DECIMAL::MONEY, COUNT(teamid)
FROM teamwinper
GROUP BY yearid, ROLLUP (winper)
ORDER BY yearid, winper

--Q12 JOSH

WITH w_att_rk AS (
SELECT yearid,
		teamid,
		w,
		attendance / ghome AS avg_h_att,
		RANK() OVER(PARTITION BY yearid ORDER BY w) AS w_rk,
		RANK() OVER(PARTITION BY yearid ORDER BY attendance / ghome) AS avg_h_att_rk
FROM teams
WHERE attendance / ghome IS NOT NULL
AND yearid >= 1961 						--MLB institutes 162 game season
ORDER BY yearid, teamid
)
SELECT avg_h_att_rk,
		ROUND(AVG(w_rk), 1) AS avg_w_rk,
		CORR(avg_h_att_rk, AVG(w_rk)) OVER() as correlation
FROM w_att_rk
GROUP BY avg_h_att_rk
ORDER BY avg_h_att_rk

--Q12 JOSH Attendance question?

--After World Series Win
WITH att_comp AS (
SELECT yearid,
		name,
		attendance / ghome AS att_g,
		lead(attendance / ghome) OVER(PARTITION BY name ORDER BY yearid) AS att_g_next_year,
		lead(attendance / ghome) OVER(PARTITION BY name ORDER BY yearid) - (attendance/ghome) AS difference
FROM teams AS t
)
SELECT ROUND(AVG(difference), 1) AS avg_att_dif
FROM att_comp
INNER JOIN teams AS t
USING (yearid, name)
WHERE wswin = 'Y'
--Attendance improves, on average, by 267.1 people per home game.

--After Playoff Berth
WITH att_comp AS (
SELECT yearid,
		name,
		attendance / ghome AS att_g,
		lead(attendance / ghome) OVER(PARTITION BY name ORDER BY yearid) AS att_g_next_year,
		lead(attendance / ghome) OVER(PARTITION BY name ORDER BY yearid) - (attendance/ghome) AS difference
FROM teams AS t
)
SELECT ROUND(AVG(difference), 1) AS avg_att_dif
FROM att_comp
INNER JOIN teams AS t
USING (yearid, name)
WHERE wcwin = 'Y' OR divwin = 'Y'
--Attendance improves, on average, by 561.9 people per home game.

--Q13

