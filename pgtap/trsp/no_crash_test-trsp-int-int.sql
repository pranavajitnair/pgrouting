\i setup.sql

UPDATE edge_table SET cost = sign(cost), reverse_cost = sign(reverse_cost);
SELECT CASE WHEN min_version('4.0.0') THEN plan(38) ELSE plan(23) END;

PREPARE edges AS
SELECT id, source, target, cost, reverse_cost FROM edge_table;

PREPARE null_ret AS
SELECT id FROM edge_table_vertices_pgr  WHERE id IN (-1);

CREATE OR REPLACE FUNCTION test(params TEXT[], subs TEXT[])
RETURNS SETOF TEXT AS
$BODY$
DECLARE
mp TEXT[];
q1 TEXT;
q TEXT;
BEGIN
    FOR i IN 0..array_length(params, 1) LOOP
        mp := params;
        IF i != 0 THEN
            mp[i] = subs[i];
        END IF;

        q1 := format($$
            SELECT * FROM pgr_trsp(
                %1$L, %2$s, %3$s, %4$s, %5$s
            )
            $$,
            mp[1], mp[2], mp[3], mp[4], mp[5]
        );

        if i IN (1) THEN
            RETURN query SELECT * FROM throws_ok(q1);
        ELSE
            RETURN query SELECT * FROM lives_ok(q1, 'should live i ' || i);
            IF i IN (0,5) THEN
                RETURN query SELECT * FROM isnt_empty(q1, 'should not be empty i' || i);
            ELSE
                RETURN query SELECT * FROM is_empty(q1,  'should be empty i' || i);
            END IF;
        END IF;
    END LOOP;

END
$BODY$
LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION test_function()
RETURNS SETOF TEXT AS
$BODY$
DECLARE
params TEXT[];
subs TEXT[];
BEGIN
  IF min_version('4.0.0') THEN

    RETURN QUERY SELECT isnt_empty('edges', 'Should not be empty to tests be meaningful');
    RETURN QUERY SELECT is_empty('null_ret', 'Should be empty to tests be meaningful');

    params = ARRAY['$$SELECT id::INTEGER, source::INTEGER, target::INTEGER, cost, reverse_cost  FROM edge_table$$',
    '1',
    '2',
    'true',
    'true'
    ]::TEXT[];
    subs = ARRAY[
    'NULL',
    '(SELECT id::INTEGER FROM edge_table_vertices_pgr  WHERE id IN (-1))',
    '(SELECT id::INTEGER FROM edge_table_vertices_pgr  WHERE id IN (-1))',
    'NULL',
    'NULL'
    ]::TEXT[];

    RETURN query SELECT * FROM no_crash_test('pgr_trsp', params, subs);

    subs = ARRAY[
    'NULL',
    'NULL',
    'NULL',
    'NULL',
    'NULL'
    ]::TEXT[];
    RETURN query SELECT * FROM no_crash_test('pgr_trsp', params, subs);

    params = ARRAY['$$edges$$',
    '1',
    '2',
    'true',
    'true'
    ]::TEXT[];
    RETURN query SELECT no_crash_test('pgr_trsp', params, subs);

  ELSE

    params = ARRAY['SELECT id::INTEGER, source::INTEGER, target::INTEGER, cost::FLOAT, reverse_cost::FLOAT  FROM edge_table',
    '1',
    '2',
    'true',
    'true'
    ]::TEXT[];
    subs = ARRAY[
    NULL,
    '(SELECT id::INTEGER FROM edge_table_vertices_pgr  WHERE id IN (-1))',
    '(SELECT id::INTEGER FROM edge_table_vertices_pgr  WHERE id IN (-1))',
    'NULL',
    'NULL'
    ]::TEXT[];

    RETURN query SELECT test(params, subs);

    subs = ARRAY[
    NULL,
    'NULL',
    'NULL',
    'NULL',
    'NULL'
    ]::TEXT[];
    RETURN query SELECT test(params, subs);

    RETURN QUERY SELECT skip(1, 'pgr_trsp Has some crashes');

  END IF;

END
$BODY$
LANGUAGE plpgsql VOLATILE;


SELECT * FROM test_function();

ROLLBACK;
