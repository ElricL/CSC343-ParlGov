SET SEARCH_PATH TO parlgov;

DROP TABLE IF EXISTS q2 CASCADE;
DROP VIEW IF EXISTS cabinet1996 CASCADE;
DROP VIEW IF EXISTS numCabinetsP CASCADE;
DROP VIEW IF EXISTS numCabinetsC CASCADE;
DROP VIEW IF EXISTS committeds CASCADE;

CREATE TABLE q2(
        countryName VARCHAR(100),
        partyName VARCHAR(100),
        partyFamily VARCHAR(100),
        stateMarket REAL);

/* Get all cabinets that start after 1996*/
CREATE VIEW cabinet1996 AS
SELECT id, country_id AS cid
FROM cabinet
WHERE EXTRACT(YEAR FROM start_date) > 1996;

SELECT * FROM cabinet1996;

/* Get the number of cabinets each parties have */
CREATE VIEW numCabinetsP AS
SELECT CP.party_id AS pid, PF.family AS fname, C1996.cid AS cid, count(cabinet_id) AS numCab
FROM cabinet1996 AS C1996, cabinet_party AS CP, party_family AS PF
WHERE CP.party_id = PF.party_id AND C1996.id = CP.cabinet_id
GROUP BY CP.party_id, PF.family, C1996.cid;

/* Get the number of cabinets each countries have */
CREATE VIEW numCabinetsC AS
SELECT C1996.cid AS cid, country.name, count(C1996.id) AS numCab
FROM cabinet1996 AS C1996, country
WHERE C1996.cid = country.id
GROUP BY C1996.cid, country.name;

/* Get all committed parties */
CREATE VIEW committeds AS
SELECT pid, fname
FROM numCabinetsP, numCabinetsC
WHERE numCabinetsP.numCab = numCabinetsC.numCab
	AND numCabinetsP.cid = numCabinetsC.cid;

/*Final Answer*/
INSERT INTO q2
SELECT country.name, party.name, committeds.fname, state_market 
FROM country, party, committeds, party_position
WHERE committeds.pid = party.id AND party.country_id = country.id 
	AND committeds.pid = party_position.party_id;
