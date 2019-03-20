SET SEARCH_PATH TO parlgov;

DROP TABLE IF EXISTS q3 CASCADE;
DROP VIEW IF EXISTS winners CASCADE;
DROP VIEW IF EXISTS highest_vote CASCADE;
DROP VIEW IF EXISTS numWon CASCADE;

CREATE TABLE q3(
	countryName VARCHAR(100),
	partyName VARCHAR(100),
	partyFamily VARCHAR(100),
	wonElections INT,
	mostRecentlyWonElectionId INT,
	mostRecentlyWonElectionYear INT);

/*Get highest vote for each election*/
CREATE VIEW highest_vote AS
SELECT election_id, max(votes) AS max
FROM election_result
GROUP BY election_id;

/* Get the winning party for each election's highest vote */
CREATE VIEW winners AS
SELECT E.election_id AS eid, P.id AS pid, P.country_id AS cid
FROM election_result AS E, highest_vote AS V, party AS P
WHERE E.election_id = V.election_id AND V.max = E.votes
	AND E.party_id = P.id;

/* Get each parties' total number of wins */
CREATE VIEW numWon AS
(SELECT pid, cid, count(pid) AS numWins
FROM winners
GROUP BY pid, cid)
UNION
(SELECT party.id AS pid, party.country_id, 0 AS numWins
FROM party
WHERE party.id NOT IN(SELECT pid FROM winners ORDER BY pid));

/* Get average wins for each country */
CREATE VIEW countryAvgwin AS
SELECT cid, (sum(numWins)/count(cid)) AS avg
FROM numWon
GROUP BY cid;

/*Get the party that has won more than three times the average */
CREATE VIEW finalParties AS
SELECT	pid, numWon.cid, numWins
FROM numWon, countryAvgWin
WHERE numWon.cid = countryAvgWin.cid
	AND numWon.numWins > 3*(countryAvgWin.avg);

/* Get recently won election info */
CREATE VIEW recentWon AS
SELECT P.pid, max(E.e_date) AS recentDate
FROM election AS E, winners AS W, finalParties AS P
WHERE p.pid = W.pid AND E.id = W.eid
GROUP BY p.pid;

CREATE VIEW recentWon2 AS
SELECT recentWon.pid, E.id AS recentID, EXTRACT(YEAR from recentDate) AS recentYear
FROM recentWon, winners, election AS E
WHERE E.id = eid AND E.e_date = recentDate
	AND recentWon.pid = winners.pid;

CREATE VIEW final AS
SELECT FP.pid, C.name AS cName, P.name AS pName, numWins, recentID, recentYear
FROM recentWon2 AS R, finalParties AS FP, party AS P, country AS c
WHERE R.pid = FP.pid AND FP.cid = C.id AND FP.pid = P.id;

CREATE VIEW final2 AS
(SELECT cName, pName, NULL AS fName, numWins, recentID, recentYear
FROM final
WHERE pid NOT IN (SELECT F.party_id FROM party_family AS F))
UNION
SELECT cName, pName, family AS fName, numWins, recentID, recentYear
FROM final, party_family
WHERE pid = party_id;

INSERT INTO q3
SELECT * FROM final2;
