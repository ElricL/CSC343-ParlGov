SET SEARCH_PATH TO parlgov;

DROP TABLE IF EXISTS q6 CASCADE;
DROP VIEW IF EXISTS allPositions CASCADE;
DROP VIEW IF EXISTS noPositions CASCADE;
DROP VIEW IF EXISTS r02 CASCADE;
DROP VIEW IF EXISTS r24 CASCADE;
DROP VIEW IF EXISTS r46 CASCADE;
DROP VIEW IF EXISTS r68 CASCADE;
DROP VIEW IF EXISTS r810 CASCADE;

CREATE TABLE q6(
	countryName VARCHAR(100),
	r0_2 INT,
	r2_4 INT,
	r4_6 INT,
	r6_8 INT,
	r8_10 INT);

/* Getting all country,party,party position triplets */
CREATE VIEW allPositions AS
SELECT C.name AS cName, PP.left_right AS leftRight
FROM country AS C, party AS P, party_position AS PP
WHERE C.id = P.country_id AND P.id = PP.party_id;

/* ALL countries who don't have party postion info */
CREATE VIEW noPosition AS
SELECT country.name as cName, 0 AS pos02, 0 AS pos24, 0 AS pos46, 0 AS pos68, 0 AS pos810
FROM country
WHERE country.name NOT IN (SELECT cName FROM allPositions);

/* Gets number of positions between 0 and 2 or NULL (0 or greater)*/
CREATE VIEW r02 AS
(SELECT cName AS cName, count(cName) AS pos02
FROM allPositions
WHERE (leftRight >= 0 AND leftRight < 2) OR leftRight IS NULL
GROUP BY cName);

/* Gets number of positions between 2 and 4 */
CREATE VIEW r24 AS
(SELECT cName, count(leftRight) AS pos24
FROM allPositions
WHERE leftRight >= 2 AND leftRight < 4
GROUP BY cName);
			
/* Gets number of positions between 4 and 6 */
CREATE VIEW r46 AS
(SELECT cName, count(leftRight) AS pos46
FROM allPositions
WHERE leftRight >= 4 AND leftRight < 6
GROUP BY cName);

/* Gets number of positions between 6 and 8 */
CREATE VIEW r68 AS
(SELECT cName, count(leftRight) AS pos68
FROM allPositions
WHERE leftRight >= 6 AND leftRight < 8
GROUP BY cName);

/* Gets number of positions between 8 and 10 */
CREATE VIEW r810 AS
(SELECT cName, count(leftRight) AS pos810
FROM allPositions
WHERE leftRight >= 8 AND leftRight < 10
GROUP BY cName);

-- the answer to the query 
INSERT INTO q6
(SELECT r02.cName, pos02, pos24, pos46, pos68, pos810
FROM r02 NATURAL JOIN r24 
NATURAL JOIN r46 NATURAL JOIN r68
NATURAL JOIN r810)
UNION
(SELECT * FROM noPosition);
