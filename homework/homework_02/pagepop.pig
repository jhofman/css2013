-- Pig script to count words in wikipedia
-- Run using the run_wordcount.sh

-- Load tab-separated articles
edges = LOAD '$INPUT' AS (source_id, source_url, target);

-- Fill in code here to compute page popularity

-- Write tab-separate output
STORE edges INTO '$OUTPUT';