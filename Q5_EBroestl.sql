SELECT (yearid/10)*10 as decade,
		ROUND((SUM(so)::DECIMAL / SUM(ghome)::DECIMAL),2) AS so_per_game,
		ROUND((SUM(hr)::DECIMAL / SUM(ghome)::DECIMAL),2) AS hr_per_game
FROM teams
WHERE yearid >=1920
GROUP BY decade
ORDER BY decade;