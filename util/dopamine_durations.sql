SET search_path TO mimiciv_derived, mimiciv_hosp, mimiciv_icu, mimiciv_ed;
-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS dopamine_durations; CREATE TABLE dopamine_durations AS 
-- This query extracts durations of dopamine administration
-- Consecutive administrations are numbered 1, 2, ...
-- Total time on the drug can be calculated from this table by grouping using ICUSTAY_ID

-- Get drug administration data from CareVue first
with
-- now we extract the associated data for metavision patients
 vasomv as
(
  select
    stay_id as icustay_id, linkorderid
    , min(starttime) as starttime, max(endtime) as endtime
  FROM mimiciv_icu.inputevents
  where itemid = 221662 -- dopamine
  and statusdescription != 'Rewritten' -- only valid orders
  group by stay_id, linkorderid
)
select
  icustay_id
  , ROW_NUMBER() over (partition by icustay_id order by starttime) as vasonum
  , starttime, endtime
  , mimiciv_derived.DATETIME_DIFF(endtime, starttime, 'HOUR') AS duration_hours
  -- add durations
from
  vasomv

order by icustay_id, vasonum;

