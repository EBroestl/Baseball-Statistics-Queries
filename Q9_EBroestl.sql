/*9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
Give their full name and the teams that they were managing when they won the award.

WITH award_winners AS (select aw1.playerid AS p_id,
	   aw1.awardid AS aw1,
	   aw2.awardid AS aw2,
	   aw1.lgid AS lgid1,
	   aw1.yearid AS y1,			   
	   aw2.lgid AS lgid2,
	   aw2.yearid AS y2,
	   aw1.playerid AS pid
from awardsmanagers AS aw1 INNER JOIN awardsmanagers AS aw2
USING (playerid)
WHERE aw2.awardid ILIKE'%tsn%'
AND aw1.awardid ILIKE'%tsn%'
AND aw1.lgid ='AL'
AND aw2.lgid ='NL')

SELECT  
		aw.pid,
		aw.aw1,
		p.namefirst,
	    p.namelast,
	    t.name,
	    aw.aw1,
		aw.lgid1,
		aw.lgid2,
		aw.y1,
		aw.y2,
		t.yearid
		
from award_winners AS aw 
INNER JOIN people AS p ON aw.p_id=p.playerid
INNER JOIN appearances AS a on p.playerid=a.playerid
INNER JOIN teams AS t on a.teamid=t.teamid
WHERE aw.pid = a.playerid
and aw.y1=t.yearid
and aw.pid=p.playerid;*/


WITH aw AS (SELECT DISTINCT
				p.namefirst AS first,
				p.namelast AS last,
				aw1.playerid AS pid,
				aw1.yearid AS alyear,
				aw2.yearid AS nlyear,
				aw1.lgid AS nl,
				aw2.lgid AS al
	FROM awardsmanagers AS aw1 
	INNER JOIN awardsmanagers AS aw2
	USING (playerid)
	INNER JOIN people AS p
	USING (playerid)
	WHERE aw1.awardid = 'TSN Manager of the Year'
	AND aw2.awardid = 'TSN Manager of the Year'
	AND aw1.lgid <>'ML'
	AND aw2.lgid <>'ML'
	AND aw1.lgid = 'NL' 
	AND aw2.lgid = 'AL'),

mt1 AS (SELECT DISTINCT
	   			t.teamid AS tid1,
				m.yearid AS myearid1,
				t.name AS tname1,
	   			m.playerid AS pid1
	FROM teams AS t
	INNER JOIN managers as m
	using (teamid)
	INNER JOIN awardsmanagers as ap
	ON m.playerid=ap.playerid AND m.yearid=t.yearid),

mt2 AS (SELECT DISTINCT
	   			t.teamid AS tid2,
				m.yearid AS myearid2,
				t.name AS tname2,
	   			m.playerid AS pid2
	FROM teams AS t
	INNER JOIN managers as m
	using (teamid)
	INNER JOIN awardsmanagers as ap
	ON m.playerid=ap.playerid AND m.yearid=t.yearid)

SELECT 
	aw.first,
	aw.last,
	aw.nlyear,
	mt1.tname1 AS nlteam,
	aw.alyear,
	mt2.tname2 AS alteam
		
 	FROM aw JOIN mt2
	ON aw.pid = mt2.pid2 AND mt2.myearid2=aw.alyear
	JOIN mt1
	ON aw.pid=mt1.pid1 AND mt1.myearid1=aw.nlyear;
	
			
	