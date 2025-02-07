/*PGR-GNU*****************************************************************
File: edgeColoring.sql

Generated with Template by:
Copyright (c) 2021 pgRouting developers
Mail: project@pgrouting.org

Function's developer:
Copyright (c) 2021 Veenit Kumar
Mail: 123sveenit@gmail.com

------

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

 ********************************************************************PGR-GNU*/
---------------
-- pgr_edgeColoring
---------------

--v3.3
CREATE FUNCTION pgr_edgeColoring(
    TEXT, -- edges_sql (required)

    OUT edge_id BIGINT,
    OUT color_id BIGINT)
RETURNS SETOF RECORD AS
$BODY$
BEGIN
    RETURN QUERY
    SELECT *
    FROM _pgr_edgeColoring(_pgr_get_statement($1));
END;
$BODY$
LANGUAGE plpgsql VOLATILE STRICT;

-- COMMENTS

COMMENT ON FUNCTION pgr_edgeColoring(TEXT)
IS 'pgr_edgeColoring
- Parameters:
    - Edges SQL with columns: id, source, target, cost [,reverse_cost]
- Documentation:
    - ${PROJECT_DOC_LINK}/pgr_edgeColoring.html
';
