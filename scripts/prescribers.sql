-- 1a. Which prescriber had the highest total number of claims (totaled over all drugs)?
-- Report the npi and the total number of claims.
SELECT npi, COUNT(total_claim_count)
FROM prescription
GROUP BY npi
ORDER BY COUNT(total_claim_count) DESC;
-- 1b. Repeat the above, but this time report the nppes_provider_first_name,
-- nppes_provider_last_org_name, specialty_description, and the total number of claims.
SELECT pn.npi, pr.nppes_provider_first_name, pr.nppes_provider_last_org_name, pr.specialty_description, COUNT(pn.total_claim_count)
FROM prescription AS pn
INNER JOIN prescriber AS pr
USING (npi)
GROUP BY pn.npi, pr.nppes_provider_first_name, pr.nppes_provider_last_org_name, pr.specialty_description
ORDER BY COUNT(pn.total_claim_count) DESC;
-- 2a. Which specialty had the most total number of claims (totaled over all drugs)?
SELECT pr.specialty_description, COUNT(pn.total_claim_count)
FROM prescription AS pn
INNER JOIN prescriber AS pr
USING (npi)
GROUP BY pr.specialty_description
ORDER BY COUNT(pn.total_claim_count) DESC;
-- 2b. Which specialty had the most total number of claims for opioids?
SELECT pr.specialty_description, COUNT(pn.total_claim_count)
FROM prescription AS pn
LEFT JOIN prescriber AS pr
USING (npi)
LEFT JOIN drug AS dg
ON (pn.drug_name = dg.drug_name)
WHERE dg.opioid_drug_flag = 'Y'
GROUP BY pr.specialty_description
ORDER BY COUNT(pn.total_claim_count) DESC;
-- 2c. Challenge Question: Are there any specialties that appear in the prescriber table
-- that have no associated prescriptions in the prescription table

SELECT DISTINCT pr.specialty_description
FROM prescriber AS pr
LEFT JOIN prescription AS pn
USING (npi)
WHERE drug_name IS NULL;

SELECT DISTINCT pr.specialty_description
FROM prescriber AS pr
	WHERE pr.npi NOT IN
	(SELECT DISTINCT pn.npi
	FROM prescription AS pn);
	
SELECT DISTINCT pr.specialty_description
FROM prescriber AS pr
	WHERE pr.specialty_description NOT IN
	(SELECT DISTINCT specialty_description
	FROM prescription AS pn
	INNER JOIN prescriber
	USING (npi));


-- 3a. Which drug (generic_name) had the highest total drug cost?
SELECT dg.generic_name, SUM(pn.total_drug_cost)
FROM prescription AS pn
LEFT JOIN drug AS dg
USING (drug_name)
GROUP BY dg.generic_name
ORDER BY SUM(pn.total_drug_cost) DESC;
-- 3b. Which drug (generic_name) has the hightest total cost per day?
-- Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.
SELECT dg.generic_name, ROUND(sum(pn.total_drug_cost)/sum(pn.total_day_supply),2) AS total_cost_per_day
FROM prescription AS pn
LEFT JOIN drug AS dg
USING (drug_name)
GROUP BY dg.generic_name
ORDER BY total_cost_per_day DESC;
-- 4a. For each drug in the drug table, return the drug name and then a column named
-- 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says
-- 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither'
-- for all other drugs. Hint: You may want to use a CASE expression for this. 
SELECT drug_name,
CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
END AS drug_type
FROM drug;
-- 4b. Building off of the query you wrote for part a, determine whether more was spent
-- (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY
-- for easier comparision.
SELECT
CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
END AS drug_type, SUM(pr.total_drug_cost) AS money
FROM drug
LEFT JOIN prescription AS pr
USING (drug_name)
GROUP BY drug_type
ORDER BY money DESC;

-- 5a. How many CBSAs are in Tennessee?
SELECT COUNT(cbsaname)
FROM cbsa
WHERE cbsaname LIKE '%TN';
-- 5b. Which cbsa has the largest combined population? Which has the smallest? (Largest: Nashville-Davidson-Murfeesboro-Franklin, Smallest: Morristown, TN)
-- Report the CBSA name and total population.
SELECT cb.cbsaname, SUM(pop.population)
FROM cbsa AS cb
INNER JOIN population AS pop
USING (fipscounty)
GROUP BY cb.cbsaname
ORDER BY SUM(pop.population) desc;
-- 5c. What is the largest (in terms of population) county which is not included in a CBSA? (Sevier)
-- Report the county name and population.
SELECT fips.county, SUM(pop.population)
FROM fips_county AS fips
INNER JOIN population AS pop
USING (fipscounty)
	WHERE fips.fipscounty NOT IN
	(SELECT fipscounty
	FROM cbsa)
GROUP BY fips.county
ORDER BY SUM(pop.population) DESC;
-- 6a. Find all rows in the prescription table where total_claims is at least 3000.
-- Report the drug_name and the total_claim_count.
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;
-- 6b. For each instance that you found in part a, add a column that indicates whether
-- the drug is an opioid.
SELECT drug_name, total_claim_count, opioid_drug_flag
FROM prescription
INNER JOIN drug
USING (drug_name)
WHERE total_claim_count >= 3000;
-- 6c. Add another column to you answer from the previous part which gives the prescriber first
-- and last name associated with each row.
SELECT dg.drug_name, pn.total_claim_count, dg.opioid_drug_flag,pr.nppes_provider_first_name,pr.nppes_provider_last_org_name
FROM prescription AS pn
INNER JOIN drug AS dg
USING (drug_name)
INNER JOIN prescriber AS pr
USING (npi)
WHERE pn.total_claim_count >= 3000;
-- 7. The goal of this exercise is to generate a full list of all pain management specialists in
-- Nashville and the number of claims they had for each opioid. Hint: The results from all 3
-- parts will have 637 rows. [cross join]

-- 7a. First, create a list of all npi/drug_name combinations for pain management specialists
-- (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'),
--  where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it.
--  You will only need to use the prescriber and drug tables since you don't need the claims numbers yet. 

SELECT pr.npi, dg.drug_name
FROM prescriber AS pr
CROSS JOIN drug AS dg
WHERE specialty_description iLIKE 'Pain Management' AND nppes_provider_city iLIKE 'NASHVILLE' AND dg.opioid_drug_flag = 'Y';

-- 7b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations,
-- whether or not the prescriber had any claims. You should report the npi,
-- the drug name, and the number of claims (total_claim_count). [use same filters as above, XJ and LJ]

SELECT pr.npi, dg.drug_name, pn.total_claim_count
FROM prescriber AS pr
CROSS JOIN drug AS dg
LEFT JOIN prescription AS pn
USING (npi, drug_name) 
WHERE specialty_description iLIKE 'Pain Management' AND nppes_provider_city iLIKE 'NASHVILLE' AND dg.opioid_drug_flag = 'Y'
ORDER BY pr.npi ASC;

-- 7c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0.
-- Hint - Google the COALESCE function.

SELECT pr.npi, dg.drug_name, COALESCE(pn.total_claim_count,'0')
FROM prescriber AS pr
CROSS JOIN drug AS dg
LEFT JOIN prescription AS pn
USING (npi, drug_name) 
WHERE specialty_description = 'Pain Management' AND nppes_provider_city = 'NASHVILLE' AND dg.opioid_drug_flag = 'Y';
