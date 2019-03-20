SET search_path TO parlgov;

DROP TABLE IF EXISTS q1 CASCADE;
DROP VIEW IF EXISTS alliancePairs CASCADE;
DROP VIEW IF EXISTS numElections CASCADE;
DROP VIEW IF EXISTS numPairs CASCADE;

CREATE TABLE q1(
	countryId INT,
	alliedPartyId1 INT,
	alliedPartyId2 INT
);

/*Get total of number of elections for each country*/
CREATE VIEW numElections AS
SELECT 	country_id AS cid, count(id) AS total
FROM election
GROUP BY country_id;

/*Get all Pair of Allies that have happened in a country*/
CREATE VIEW alliancePairs AS
SELECT E1.election_id AS eid, election.country_id AS cid, E1.party_id AS pid1, E2.party_id AS pid2
FROM election, election_result E1, election_result E2
WHERE (E1.id = E2.alliance_id OR E1.alliance_id = E2.alliance_id OR E2.id = E1.alliance_id)
	AND E1.party_id < E2.party_id AND E1.election_id = election.id;

/*Get the number of elections the allies paired in each country*/
CREATE VIEW numPairs AS
SELECT pid1, pid2, cid, count(*) AS total
FROM alliancePairs
GROUP BY pid1 , pid2, cid;

/*Final Answer*/
insert into q1
SELECT numPairs.cid, numPairs.pid1, numPairs.pid2
FROM numPairs, numElections
WHERE numPairs.cid = numElections.cid 
	AND numPairs.total >= numElections.total*0.3;
