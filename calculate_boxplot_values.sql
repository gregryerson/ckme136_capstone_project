-- calculate boxplot values by ward

CREATE TYPE boxplot_values AS (
  min       numeric,
  q1        numeric,
  median    numeric,
  q3        numeric,
  max       numeric
);

CREATE OR REPLACE FUNCTION _final_boxplot(a numeric[])
   RETURNS boxplot_values AS
$$
    a.sort()
    i = len(a)
    return ( a[0], a[i/4], a[i/2], a[i*3/4], a[-1] )
$$
LANGUAGE 'plpythonu' IMMUTABLE;

CREATE AGGREGATE boxplot(numeric) (
  SFUNC=array_append,
  STYPE=numeric[],
  FINALFUNC=_final_boxplot,
  INITCOND='{}'
);

SELECT ward_id, ward_name, STDDEV(parking_tickets) as std_dev_parking_tickets, (boxplot(parking_tickets)).*
INTO address_monthly_boxplot_range
FROM address_monthly
GROUP BY ward_id, ward_name;
