SET SEARCH_PATH TO parlgov;

DROP TABLE IF EXISTS q5 CASCADE;
DROP VIEW IF EXISTS pRatios CASCADE;
DROP VIEW IF EXISTS decreasing  CASCADE;
DROP VIEW IF EXISTS nonDecreasing  CASCADE;

CREATE TABLE q5(
	countryName VARCHAR(100),
	year INT,
	participationRatio REAL);

/*Get the participation ratio in all elections between 2001 and 2016 */
CREATE VIEW pRatios AS
SELECT country_id AS cId, EXTRACT(YEAR FROM e_date) AS eYear, avg(votes_cast::float/electorate::float) as pRatio
FROM election
WHERE electorate IS NOT NULL AND votes_cast IS NOT NULL
	AND EXTRACT(YEAR FROM e_date) >= 2001 AND EXTRACT(YEAR FROM e_date) <= 2016
GROUP BY country_id, eYear;

/* Get countries whose participation ratios do decrease */
CREATE VIEW decreasing AS
SELECT P1.cId, P1.eYear, P1.pRatio
FROM pRatios AS P1, pRatios AS P2
WHERE P1.cId = P2.cId AND P1.eYear < P2.eYear
	and P1.pRatio > P2.pRatio;

/* Get countries whose participation ratios are non-decreasing */
CREATE VIEW nonDecreasing AS
SELECT * 
FROM pRatios AS P
WHERE P.cId NOT IN(SELECT dP.cId
			FROM decreasing AS dP);

/* Final answer */
INSERT INTO q5
SELECT country.name, eYear, pRatio
FROM nonDecreasing, country
WHERE nonDecreasing.cId = country.id; 
