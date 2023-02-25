SET search_path TO mimiciv_derived, mimiciv_hosp, mimiciv_icu, mimiciv_ed;
-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS dobutamine_dose; CREATE TABLE dobutamine_dose AS 
-- This query extracts dose+durations of dopamine administration

-- Get drug administration data from CareVue first
with
-- collapse these start/stop times down if the rate doesn't change

-- now we extract the associated data for metavision patients
vasomv as
(
  select
    stay_id as icustay_id, linkorderid
    , rate as vaso_rate
    , amount as vaso_amount
    , starttime
    , endtime
  from mimiciv_icu.inputevents
  where itemid = 221653 -- dobutamine
  and statusdescription != 'Rewritten' -- only valid orders
)
-- now assign this data to every hour of the patient's stay
-- vaso_amount for carevue is not accurate
SELECT icustay_id
  , starttime, endtime
  , vaso_rate, vaso_amount
from vasomv
order by icustay_id, starttime;

