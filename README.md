# Postprocessing
## Target
This script emulates a webservice for the postprocessing.  It can be called with a parameter lotname,  and will return a YAML body with the result.

## The results
The results of the postprocessing are put in a YAML body.  Currently it contains the following fields:

- lotname
- converted_at
- wafermaps
   - wafer number / th01 body

