select * from insurance_claims;

--> Checking NULL Values
select COUNT(*) 
from insurance_claims
WHERE claim_amount IS NULL;

-->  Check duplicate claims
select claim_id,
COUNT(claim_id) as Duplicates
from insurance_claims
GROUP BY claim_id
HAVING COUNT(claim_id) > 1;

--> Validate negative claim amounts
SELECT *
FROM insurance_claims
WHERE claim_amount < 0;

--> Check Approved Amount > Claim Amount
select *
from insurance_claims
WHERE approved_amount > claim_amount;

--> Total Claimed Amount
select SUM(claim_amount) as Total_Claim_Amount 
from insurance_claims;

--> Total Approved Amount 
select SUM(approved_amount) as Total_Approved_Amount
from insurance_claims;

--> Checking Pending Claims of patients
select 
    COUNT(*) as Pending_claims
from insurance_claims
WHERE claim_status = 'Pending';

--> Claim Status Distribution
select
    claim_status,
	COUNT(*) as total_cliams,
	ROUND(COUNT(*) * 100.0
	/(select COUNT(*) from insurance_claims)
	,2) as percantage
from insurance_claims
GROUP BY claim_status;

--> Claim Approval Rate
select ROUND( 100.0 *
SUM(CASE
      WHEN claim_status = 'Approved'
      THEN 1
      ELSE 0
      END)
 /NULLIF(COUNT(*), 0),2
) as approval_rate
from insurance_claims;

--> Claim Rejection Rate 
select ROUND( 100.0 *
SUM(CASE
      WHEN claim_status = 'Rejected'
      THEN 1
      ELSE 0
      END)
 /COUNT(*),2
) as rejection_rate
from insurance_claims;

--> Claims By Region
select region,
   COUNT(*) as Total_claims
from insurance_claims
GROUP BY region
ORDER BY Total_claims DESC;

--> Region with High Claim Amount
select region,
   SUM(claim_amount) as Amount
from insurance_claims
GROUP BY region 
ORDER BY Amount DESC;

--> Most Expensive Diagnoses
select Diagnosis,
   SUM(claim_amount) as Amount
from insurance_claims
GROUP BY Diagnosis
ORDER BY Amount DESC;

--> Approval Rate Based on Policy Type
SELECT
policy_type,
ROUND(
100.0 *
SUM(CASE
        WHEN claim_status='Approved'
        THEN 1
        ELSE 0
    END)
/ COUNT(*),
2
) AS approval_rate
FROM insurance_claims
GROUP BY policy_type;

--> policy wise Patient count
select policy_type,
COUNT(patient_id) as patients
from insurance_claims
GROUP BY policy_type;

--> patients with claim rejection
select COUNT(*) as claim_rejected_patients
from insurance_claims
WHERE claim_status = 'Rejected';

--> Month wise Claims 
select 
TO_CHAR(claim_date,'YYYY-MM') as month,
COUNT(*) as claim_counts,
SUM(claim_amount) as Amount
from insurance_claims
GROUP BY month
ORDER BY month;

--> Region Wise approved claim
select region,
SUM(approved_amount) as Approved_amount
from insurance_claims
GROUP BY region;

--> TOP 10 Hospitals 
select hospital_id,
SUM(claim_amount) as Amount
from insurance_claims
GROUP BY hospital_id
ORDER BY Amount DESC
LIMIT 10;

--> Region with High Rejections
select region,
COUNT(*) as Rejections
from insurance_claims
WHERE claim_status = 'Rejected'
GROUP BY region;

--> Region Wise Approval Rate
select
region,
ROUND(
100.0 *
SUM(CASE
        WHEN claim_status='Approved'
        THEN 1
        ELSE 0
    END)
/ NULLIF(COUNT(*), 0),
2
) AS approval_rate
FROM insurance_claims
GROUP BY region
ORDER BY approval_rate DESC;

--> Average Claims By diagnosis
select diagnosis,
ROUND(AVG(claim_amount),2)as average_claim_amount
from insurance_claims
GROUP BY diagnosis;

--> Claims Above Average
SELECT *
FROM insurance_claims
WHERE claim_amount > (SELECT AVG(claim_amount) FROM insurance_claims);

--> Ranking of Hospitals By Claim_Amount
select 
      hospital_id,
      SUM(claim_amount) as Amount,
DENSE_RANK() 
     OVER(ORDER BY SUM(claim_amount) DESC) 
as claim_rnk
from insurance_claims
GROUP BY hospital_id;

--> Hospital With High Approval Rate
select hospital_id,
ROUND(
100.0 * 
SUM(CASE
       WHEN claim_status = 'Approved'
	   THEN 1
	   ELSE 0
	 END)
/ COUNT(*),2
) as Approval_rate
from insurance_claims
GROUP BY hospital_id
ORDER BY Approval_rate DESC
LIMIT 3;

--> Rank of Region Based on Approved Amount
select 
      region,
      SUM(approved_amount) as Total_approved_amt,
RANK() OVER(
       ORDER BY SUM(approved_amount) DESC
) as region_rnk
from insurance_claims
GROUP BY region;

--> TOP 10 patients claim Amount
select * 
from(
select 
    patient_id,
     SUM(claim_amount) as Claim_Amount,
RANK() OVER(
    ORDER BY SUM(claim_amount) DESC
) as patient_rnk
from insurance_claims
GROUP BY patient_id
) 
WHERE patient_rnk <= 10;

--> CURRENT Running Claims
select
     claim_date,
     claim_amount,
      SUM(claim_amount)
OVER(
ORDER BY claim_date
) as running_total
from insurance_claims;

--> Patients Filing Excessive Claims
SELECT
     patient_id,
     COUNT(*) total_claims
FROM insurance_claims
GROUP BY patient_id
HAVING COUNT(*) > 5;

--> Hospital With High Rejection Rate
select hospital_id,
ROUND(
100.0 * 
SUM(CASE
       WHEN claim_status = 'Rejected'
	   THEN 1
	   ELSE 0
	 END)
/ COUNT(*),2
) as rejection_rate
from insurance_claims
GROUP BY hospital_id
ORDER BY rejection_rate DESC
LIMIT 5;

--> Average Plolicy calim amount
select  
     policy_type,
     ROUND(AVG(claim_amount),2) as Average_amt
from insurance_claims
GROUP BY policy_type;

--> Fraud Detection : Patients with unusually high claims
WITH claim_stats AS (
    SELECT
        AVG(claim_amount) avg_claim,
        STDDEV(claim_amount) std_claim
    FROM insurance_claims
)
SELECT *
FROM insurance_claims c
CROSS JOIN claim_stats s
WHERE c.claim_amount >
      s.avg_claim + 2 * s.std_claim;

--> Approval Claim Efficiency
select 
    ROUND(SUM(approved_amount) * 100.0
	/ SUM(claim_amount),2) as Approval_claim_efficiency
from insurance_claims;

--> Region Wise Approval Calim Efficiency
select 
    region,
    ROUND(SUM(approved_amount) * 100.0
	/ SUM(claim_amount),2) as Approval_claim_efficiency
from insurance_claims
GROUP BY region;

--> Hospital-wise Approval Claim Efficiency
select 
     hospital_id,
	 COUNT(*) as total_claims,
	 ROUND(SUM(approved_amount)*100.0
	 /SUM(claim_amount)
	 , 2) as approval_claim_efficiency
from insurance_claims
GROUP BY hospital_id
HAVING COUNT(*) > 5
ORDER BY approval_claim_efficiency DESC;

--> policy Wise Approval Calim Efficiency
select 
    policy_type,
    ROUND(SUM(approved_amount) * 100.0
	/ SUM(claim_amount),2) as Approval_claim_efficiency
from insurance_claims
GROUP BY policy_type;

--> Total Deduction Analysis
select 
    SUM(claim_amount - approved_amount) as Total_deduction_amount
from insurance_claims;

--> Deduction Percentage
select 
    ROUND(SUM(claim_amount - approved_amount) * 100.0
	/ SUM(claim_amount),
	2) as Percentage
from insurance_claims;

--> Policy Wise Deduction percentage
select 
    policy_type,
    ROUND(SUM(claim_amount - approved_amount) * 100.0
	/ SUM(claim_amount),
	2) as Percentage
from insurance_claims
GROUP BY policy_type;

--> Region Contribution
SELECT
region,
SUM(claim_amount) amount,
ROUND(
100.0 *
SUM(claim_amount)
/
SUM(SUM(claim_amount)) OVER(),
2
) contribution_pct
FROM insurance_claims
GROUP BY region;

--> TOP diagnosis with in each region
select *
from(
select 
     region,
	 diagnosis,
	 SUM(claim_amount) as claim_amount,
	 RANK()
OVER( PARTITION BY region
ORDER BY SUM(claim_amount) DESC
) as rnk
from insurance_claims
GROUP BY region,diagnosis
) 
WHERE rnk = 1;

--> Top Hospital in Each Region
select *
from(
select 
     region,
	 hospital_id,
	 SUM(claim_amount) as claim_amount,
	 RANK()
OVER( PARTITION BY region
ORDER BY SUM(claim_amount) DESC
) as rnk
from insurance_claims
GROUP BY region,hospital_id
) 
WHERE rnk <= 3;

--> Top Policy Type in Each Region
select *
from(
select 
     region,
	 policy_type,
	 SUM(claim_amount) as claim_amount,
	 RANK()
OVER( PARTITION BY region
ORDER BY SUM(claim_amount) DESC
) as rnk
from insurance_claims
GROUP BY region,policy_type
) 
WHERE rnk = 1;

--> Policy Wise Deduction Amount
select 
    policy_type,
    SUM(claim_amount - approved_amount)
as Deduction_Amount
from insurance_claims
GROUP BY policy_type;

--> Monthly Growth Rate
WITH monthly_claims AS (
    SELECT
        TO_CHAR(claim_date,'YYYY-MM') month_name,
        SUM(claim_amount) as amount
    FROM insurance_claims
    GROUP BY month_name
)
SELECT
month_name,
amount,
LAG(amount) OVER(ORDER BY month_name) as prev_month,
ROUND(
(amount -
LAG(amount) OVER(ORDER BY month_name))
*100.0
/
LAG(amount) OVER(ORDER BY month_name),
2
) growth_pct
FROM monthly_claims;




   






