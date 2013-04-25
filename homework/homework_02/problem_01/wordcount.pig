-- Pig script to count words in wikipedia
-- Run using the run_wordcount.sh

-- Load tab-separated articles
articles = LOAD '$INPUT' USING PigStorage('\t') AS (id, url, text);

-- Fill in code here to count words across all article text

-- Write tab-separate output
STORE articles INTO '$OUTPUT';