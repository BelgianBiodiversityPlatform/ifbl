-- Drop all that is not checklist data

DELETE FROM inbo_dwca WHERE occurrencedetails NOT ILIKE '%streeplijst%';
 
