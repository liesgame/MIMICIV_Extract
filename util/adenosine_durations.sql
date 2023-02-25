SET search_path TO mimiciv_derived, mimiciv_hosp, mimiciv_icu, mimiciv_ed;
-- THIS SCRIPT IS AUTOMATICALLY GENERATED. DO NOT EDIT IT DIRECTLY.
DROP TABLE IF EXISTS adenosine_durations; CREATE TABLE adenosine_durations AS 
-- This query extracts durations of adenosine administration
-- Consecutive administrations are numbered 1, 2, ...
-- Total time on the drug can be calculated from this table by grouping using ICUSTAY_ID

-- *** COULD NOT FIND ADENOSINE IN THE INPUTEVENTS_MV TABLE ***
-- This drug is rarely used - it could just be that it was never used in MetaVision.
-- If using this code, ensure the durations make sense for carevue patients first

with
-- now we extract the associated data for metavision patients
 vasomv as
(
  select
    stay_id as icustay_id, linkorderid
    , min(starttime) as starttime, max(endtime) as endtime
  FROM mimiciv_icu.inputevents
  where itemid = 221282 -- adenosine
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
