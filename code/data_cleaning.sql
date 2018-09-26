-- Drop the table if it exists
DROP TABLE IF EXISTS working_data;
-- Create the working data table
CREATE TABLE working_data AS
SELECT id, "HOUSEID", "PERSONID", "R_AGE", "TIMETOWK", "EDUC", "WKFTPT", "NWALKTRP", "NBIKETRP", "BIKESHARE", "PTUSED", "CARSHARE", "RIDESHARE", "WKFMHMXX", "DRVRCNT", "YEARMILE", "HOMEOWN", "HHVEHCNT","LIF_CYC", "URBANSIZE"
	FROM public.perpub;

-- Delete records from working data where people are young and retired
DELETE from public.working_data
WHERE "R_AGE" < 2 AND "LIF_CYC" > 8;

-- Add and calculate a vehicle ownership rate variable
ALTER TABLE working_data
ADD COLUMN "VEH_PER_DRIVE" double precision;

UPDATE working_data
SET "VEH_PER_DRIVE" = ("HHVEHCNT" ::float / "DRVRCNT" ::float) WHERE "DRVRCNT" > 0;

-- Make binary own/don't own
UPDATE working_data
SET "HOMEOWN" = 0 WHERE "HOMEOWN" <>  1;

-- Update urban size variable
UPDATE working_data
SET "URBANSIZE" = 0 WHERE "URBANSIZE" = -9;

UPDATE working_data
SET "URBANSIZE" = 0 WHERE "URBANSIZE" = 6;

-- Replace negative codings with 0
UPDATE working_data
SET "R_AGE" = 0 WHERE "R_AGE" <= 0;

UPDATE working_data
SET "TIMETOWK" = 0 WHERE "TIMETOWK" <= 0;

UPDATE working_data
SET "EDUC" = 0 WHERE "EDUC" <= 0;

UPDATE working_data
SET "WKFTPT" = 0 WHERE "WKFTPT" <= 0;

UPDATE working_data
SET "NWALKTRP" = 0 WHERE "NWALKTRP" <= 0;

UPDATE working_data
SET "NBIKETRP" = 0 WHERE "NBIKETRP" <= 0;

UPDATE working_data
SET "PTUSED" = 0 WHERE "PTUSED" <= 0;

UPDATE working_data
SET "BIKESHARE" = 0 WHERE "BIKESHARE" <= 0;

UPDATE working_data
SET "CARSHARE" = 0 WHERE "CARSHARE" <= 0;

UPDATE working_data
SET "RIDESHARE" = 0 WHERE "RIDESHARE" <= 0;

UPDATE working_data
SET "WKFMHMXX" = 0 WHERE "WKFMHMXX" <= 0;

UPDATE working_data
SET "YEARMILE" = 0 WHERE "YEARMILE" <= 0;

UPDATE working_data
SET "HOMEOWN" = 0 WHERE "HOMEOWN" <= 0;

UPDATE working_data
SET "LIF_CYC" = 0 WHERE "LIF_CYC" <= 0;

UPDATE working_data
SET "URBANSIZE" = 0 WHERE "URBANSIZE" <= 0;