with t1 as (select subject_id, hadm_id, string_agg(icd_code, ';') as diagnosis_at_admission from mimiciv_hosp.diagnoses_icd group by subject_id, hadm_id order by subject_id, hadm_id)
select distinct
    i.subject_id,
    i.hadm_id,
    i.stay_id as icustay_id,
    i.gender,
    i.admission_age as age,
    i.race as ethnicity,
    i.hospital_expire_flag,
    i.hospstay_seq,
    i.los_icu,
    i.admittime,
    i.dischtime,
    i.icu_intime as intime,
    i.icu_outtime as outtime,
    t1.diagnosis_at_admission,
    a.admission_type,
    a.insurance,
    a.deathtime,
    a.discharge_location,
    CASE when a.deathtime between i.icu_intime and i.icu_outtime THEN 1 ELSE 0 END AS mort_icu,
    CASE when a.deathtime between i.admittime and i.dischtime THEN 1 ELSE 0 END AS mort_hosp,
    s.first_careunit,
    c.fullcode_first,
    c.dnr_first,
    c.fullcode,
    c.dnr,
    c.dnr_first_charttime,
    c.cmo_first,
    c.cmo_last,
    c.cmo,
    c.timecmo_chart,
    sapsii.sapsii,
    sapsii.sapsii_prob,
    oasis.oasis,
    oasis.oasis_prob,
    COALESCE(f.readmission_30, 0) AS readmission_30

from mimiciv_derived.icustay_detail i
     INNER JOIN mimiciv_hosp.admissions a ON i.hadm_id = a.hadm_id
     INNER JOIN t1 ON i.hadm_id = t1.hadm_id
     INNER JOIN mimiciv_icu.icustays s ON i.stay_id = s.stay_id
     INNER JOIN mimiciv_derived.code_status c ON i.stay_id = c.stay_id
     LEFT OUTER JOIN (SELECT d.stay_id, 1 as readmission_30
         FROM mimiciv_icu.icustays c, mimiciv_icu.icustays d
         where c.subject_id = d.subject_id
         AND c.stay_id > d.stay_id
         AND c.intime - d.outtime <= interval '30 days'
         AND c.outtime = (SELECT MIN(e.outtime) FROM mimiciv_icu.icustays e
                            WHERE e.subject_id = c.subject_id
                            AND e.intime > d.outtime)) f
        ON i.stay_id = f.stay_id
    LEFT OUTER JOIN (SELECT stay_id, sapsii.sapsii, sapsii_prob FROM mimiciv_derived.sapsii) sapsii
        ON i.stay_id = sapsii.stay_id
    LEFT OUTER JOIN (SELECT stay_id, oasis.oasis, oasis_prob FROM mimiciv_derived.oasis) oasis
        ON i.stay_id = oasis.stay_id
        
WHERE i.hadm_id is not null and i.stay_id is not null
    -- only consider the first record in hospital and icu
    and i.hospstay_seq = 1
    and i.icustay_seq = 1
    and i.admission_age >= {min_age}
    and i.los_icu >= {min_day}
    and (i.icu_outtime >= (i.icu_intime + interval '{min_dur} hours'))
    and (i.icu_outtime <= (i.icu_intime + interval '{max_dur} hours'))
ORDER BY i.subject_id
{limit}
