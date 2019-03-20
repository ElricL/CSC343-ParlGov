SET SEARCH_PATH TO parlgov;

DROP TABLE IF EXISTS q4 CASCADE;
DROP VIEW IF EXISTS partyElectResults CASCADE;
DROP VIEW IF EXISTS resultsRange CASCADE;

CREATE TABLE q4(
	year INT,
	countryName VARCHAR(100),
	voteRange VARCHAR(100),
	partyName VARCHAR(100));

/* Get all parties and their vote results from election */
CREATE VIEW partyElectResults AS
SELECT EXTRACT(YEAR FROM e_date) AS eYear, party.country_id AS cid, country.name AS cName,
	party.name_short as pShort, (votes::float / (votes_valid::float)) as votePercent
FROM election_result, election, party, country
WHERE (election_result.election_id = election.id AND election_result.party_id = party.id
	AND country.id = party.country_id) AND EXTRACT(YEAR FROM e_date) >= 1996
	AND  EXTRACT(YEAR FROM e_date) <= 2016 AND votes IS NOT NULL AND votes_valid IS NOT NULL;

/* Get the range of votes */
CREATE VIEW resultsRange AS
SELECT eYear , cName, avg(votePercent) as voteRange, pShort
FROM partyElectResults
GROUP BY eyear, cname, pShort;

insert into q4
SELECT eYear, cName, '(0-5]' AS voteRange, pShort
FROM resultsRange
WHERE voteRange > 0 and voteRange <= 0.05;

insert into q4
SELECT eYear, cName, '(5-10]' AS voteRange, pShort
FROM resultsRange
WHERE voteRange > 0.05 and voteRange <= 0.1;

insert into q4
SELECT eYear, cName, '(10-20]' AS voteRange, pShort
FROM resultsRange
WHERE voteRange > 0.1 and voteRange <= 0.2;

insert into q4
SELECT eYear, cName, '(20-30]' AS voteRange, pShort
FROM resultsRange
WHERE voteRange > 0.2 and voteRange <= 0.3;

insert into q4
SELECT eYear, cName, '(30-40]' AS voteRange, pShort
FROM resultsRange
WHERE voteRange > 0.3 and voteRange <= 0.4;

insert into q4
SELECT eYear, cName, '(40-100]' AS voteRange, pShort
FROM resultsRange
WHERE voteRange > 0.4 and voteRange <= 1;
