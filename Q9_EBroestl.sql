/*9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
Give their full name and the teams that they were managing when they won the award. */


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
	
			
	