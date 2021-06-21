/*5. Find the average number of strikeouts per game by decade since 1920. 
	 Round the numbers you report to 2 decimal places. 
	 Do the same for home runs per game. 
	 Do you see any trends?

WITH decade AS (SELECT DISTINCT(concat(decade, '-', decade + 9)) as year
				yearid
	  		    FROM (select floor(yearid / 10) * 10 as decade
      		    FROM pitchingpost) AS Decade 
	  		    WHERE decade > '1919')
	
WITH year_group AS (select yearid, 
				
	 CASE WHEN yearid BETWEEN '1920' AND '1929' THEN '1920s'
		  WHEN yearid BETWEEN '1930' AND '1939' THEN '1930s'	
		  WHEN yearid BETWEEN '1940' AND '1949' THEN '1940s'
		  WHEN yearid BETWEEN '1950' AND '1959' THEN '1950s'
		  WHEN yearid BETWEEN '1960' AND '1969' THEN '1960s'
		  WHEN yearid BETWEEN '1970' AND '1979' THEN '1970s'
		  WHEN yearid BETWEEN '1980' AND '1989' THEN '1980s'
		  WHEN yearid BETWEEN '1990' AND '1999' THEN '1990s'
		  WHEN yearid BETWEEN '2000' AND '2009' THEN '2000s'
		  WHEN yearid BETWEEN '2010' AND '2019' THEN '2010s'
			ELSE 'NULL' END AS decade
from pitching)

SELECT DISTINCT yg.decade,
	   ROUND(AVG(p.so/p.g) OVER(PARTITION BY yg.decade),2) AS avg_so_per_game
	  -- ROUND(AVG(hr/g) OVER(PARTITION BY yg.decade),2) AS avg_hr_per_game
from pitching AS p INNER JOIN year_group AS yg ON p.yearid=yg.yearid
WHERE decade IS NOT NULL
ORDER BY decade ASC
LIMIT 10;

WITH year_group AS (select *,
				
	 CASE WHEN yearid BETWEEN '1920' AND '1929' THEN '1920s'
		  WHEN yearid BETWEEN '1930' AND '1939' THEN '1930s'	
		  WHEN yearid BETWEEN '1940' AND '1949' THEN '1940s'
		  WHEN yearid BETWEEN '1950' AND '1959' THEN '1950s'
		  WHEN yearid BETWEEN '1960' AND '1969' THEN '1960s'
		  WHEN yearid BETWEEN '1970' AND '1979' THEN '1970s'
		  WHEN yearid BETWEEN '1980' AND '1989' THEN '1980s'
		  WHEN yearid BETWEEN '1990' AND '1999' THEN '1990s'
		  WHEN yearid BETWEEN '2000' AND '2009' THEN '2000s'
		  WHEN yearid BETWEEN '2010' AND '2019' THEN '2010s'
			ELSE 'NULL' END AS decade
from batting)

SELECT DISTINCT yg.decade,
	   --ROUND(AVG(p.so/p.g) OVER(PARTITION BY yg.decade),2) AS avg_so_per_game
	   ROUND(AVG(hr/bg) OVER(PARTITION BY yg.decade),2) AS avg_hr_per_game
FROM year_group
WHERE decade IS NOT NULL
ORDER BY decade ASC
LIMIT 10;

*/