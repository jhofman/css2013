articles = LOAD '$INPUT' AS (id, url, text);

STORE articles INTO '$OUTPUT';