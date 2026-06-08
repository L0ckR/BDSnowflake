DO $$
DECLARE
    source_count bigint;
    fact_count bigint;
BEGIN
    SELECT count(*) INTO source_count FROM mock_data;
    SELECT count(*) INTO fact_count FROM analytics.fact_sales;

    IF source_count <> 10000 THEN
        RAISE EXCEPTION 'Expected 10000 source rows, got %', source_count;
    END IF;

    IF fact_count <> source_count THEN
        RAISE EXCEPTION 'Fact row count (%) does not match source row count (%)', fact_count, source_count;
    END IF;
END $$;
