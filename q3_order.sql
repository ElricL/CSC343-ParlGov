SET SEARCH_PATH TO parlgov;

SELECT *
FROM q3
ORDER BY countryName ASC, 
	wonElections ASC, 
	partyName DESC;
