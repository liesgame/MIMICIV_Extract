SET SEARCH_PATH TO mimiciv_derived, mimiciv_hosp, mimiciv_icu, mimiciv_ed;
SELECT
    i.stay_id as icustay_id, d.subject_id, d.hadm_id,
    array_agg(d.icd_code ORDER BY seq_num ASC) AS icd9_codes
FROM mimiciv_hosp.diagnoses_icd d 
    LEFT OUTER JOIN (SELECT ccs_matched_id, icd9_code from mimiciv_derived.ccs_dx) c
    ON c.icd9_code = d.icd_code
    INNER JOIN mimiciv_icu.icustays i
    ON i.hadm_id = d.hadm_id AND i.subject_id = d.subject_id
WHERE d.hadm_id IN ('{hadm_id}') AND d.icd_version = 9 AND seq_num IS NOT NULL
GROUP BY i.stay_id, d.subject_id, d.hadm_id;
