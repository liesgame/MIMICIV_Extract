-- in mimiciv, they only use metavsion dataset

-- received colloid before admission
-- 226365  --  OR Colloid Intake
-- 226376  --  PACU Colloid Intake
SET search_path TO mimiciv_derived, mimiciv_hosp, mimiciv_icu, mimiciv_ed;
DROP TABLE IF EXISTS colloid_bolus; 
CREATE TABLE colloid_bolus AS
with t1 as
(
  select
    mv.stay_id
  , mv.starttime as charttime
  -- standardize the units to millilitres
  -- also metavision has floating point precision.. but we only care down to the mL
  , round(case
      when mv.amountuom = 'L'
        then mv.amount * 1000.0
      when mv.amountuom = 'ml'
        then mv.amount
    else null end) as amount
  from mimiciv_icu.inputevents mv
  where mv.itemid in
  (
    220864, --	Albumin 5%	7466 132 7466
    220862, --	Albumin 25%	9851 174 9851
    225174, --	Hetastarch (Hespan) 6%	82 1 82
    225795, --	Dextran 40	38 3 38
    225796  --  Dextran 70
    -- below ITEMIDs not in use
   -- 220861 | Albumin (Human) 20%
   -- 220863 | Albumin (Human) 4%
  )
  and mv.statusdescription != 'Rewritten'
  and
  -- in MetaVision, these ITEMIDs never appear with a null rate
  -- so it is sufficient to check the rate is > 100
    (
      (mv.rateuom = 'mL/hour' and mv.rate > 100)
      OR (mv.rateuom = 'mL/min' and mv.rate > (100/60.0))
      OR (mv.rateuom = 'mL/kg/hour' and (mv.rate*mv.patientweight) > 100)
    )
)
select
    stay_id
  , charttime
  , sum(amount) as colloid_bolus
from t1
-- just because the rate was high enough, does *not* mean the final amount was
where amount > 100
group by t1.stay_id, t1.charttime
order by stay_id, charttime;