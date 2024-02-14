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
-- SELECT pr.npi, pr.specialty_description
-- FROM prescriber AS pr
-- WHERE pr.npi NOT IN
-- 	(SELECT pn.npi
-- 	FROM prescription AS pn);
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
-- 4. For each drug in the drug table, return the drug name and then a column named
-- 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says
-- 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither'
-- for all other drugs. Hint: You may want to use a CASE expression for this. 