-- =============================================================================
-- NYC Hydrant Density Analysis. analysis.sql
-- Portfolio Project 2, Modern GIS Accelerator
--
-- Five progressive PostGIS queries that build up to a normalized density
-- analysis and a 100-meter coverage analysis.
--
-- Assumes:
--   - Database "nyc" with PostGIS extension enabled
--   - Tables loaded:
--       nyc_neighborhoods (polygon, EPSG:4326, geom column called "geom",
--                          attributes including "neighborhood" and "borough")
--       nyc_hydrants      (point,   EPSG:4326, geom column called "geom",
--                          attributes including "hydrant_id")
--   - Spatial indexes on both geom columns (CREATE INDEX ... USING GIST (geom))
--
-- Run all queries:
--   psql -h localhost -U gisuser -d nyc -f analysis.sql
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Query 1: Filter
--
-- Goal: Sanity check that the data loaded. Pull all neighborhoods in Manhattan.
-- Expected output: ~37 rows (Manhattan neighborhoods).
-- -----------------------------------------------------------------------------

SELECT neighborhood, borough
FROM nyc_neighborhoods
WHERE borough = 'Manhattan'
ORDER BY neighborhood;


-- -----------------------------------------------------------------------------
-- Query 2: Spatial join
--
-- Goal: Match each hydrant to the neighborhood that contains it, using
-- ST_Contains.
-- Expected output: one row per hydrant (~109,725) with the neighborhood name.
-- -----------------------------------------------------------------------------

-- [TODO] Write a query that selects h.hydrant_id, n.neighborhood, n.borough
-- by joining nyc_hydrants h to nyc_neighborhoods n using
-- ST_Contains(n.geom, h.geom).
-- Use LIMIT 10 for a first peek so you don't print the whole result set.


-- -----------------------------------------------------------------------------
-- Query 3: Aggregate
--
-- Goal: Count hydrants per neighborhood.
-- Expected output: 262 rows (one per neighborhood) with a hydrant_count.
-- -----------------------------------------------------------------------------

-- [TODO] Take Query 2 and wrap it in a GROUP BY. Use COUNT(h.*) to count
-- hydrants per neighborhood. ORDER BY hydrant_count DESC.


-- -----------------------------------------------------------------------------
-- Query 4: Normalize (this is your headline result)
--
-- Goal: Compute density per square kilometer. Reproject to EPSG:2263
-- (NY State Plane Long Island, feet) before computing area, then convert
-- square feet to square kilometers.
-- Expected output: 262 rows with hydrant_count, area_km2, density_per_km2.
-- -----------------------------------------------------------------------------

-- [TODO] Extend Query 3 with:
--   - ST_Area(ST_Transform(n.geom, 2263)) / 10763910.42  AS area_km2
--     (10,763,910.42 square feet = 1 square kilometer)
--   - hydrant_count / area_km2  AS density_per_km2
-- ORDER BY density_per_km2 DESC.


-- -----------------------------------------------------------------------------
-- Query 5: Buffer + Union + Intersection (coverage analysis)
--
-- Goal: For each neighborhood, what percent of its area is within 100 meters
-- of a hydrant? This is the deeper finding.
-- Expected output: 262 rows with neighborhood, area_km2, covered_pct.
-- -----------------------------------------------------------------------------

-- [TODO] Build this in two CTEs:
--   1. hydrant_coverage: ST_Union(ST_Buffer(ST_Transform(geom, 2263), 100))
--      across ALL hydrants. (One big multipolygon of 100m buffers.)
--   2. The main SELECT: for each neighborhood, compute
--        ST_Area(ST_Intersection(ST_Transform(n.geom, 2263), hc.coverage_geom))
--        divided by ST_Area(ST_Transform(n.geom, 2263))
--      to get the percent of each neighborhood within 100m of a hydrant.
-- ORDER BY covered_pct DESC.


-- =============================================================================
-- Notes for your README
--
-- - Query 1 is your sanity check. Don't skip it.
-- - Query 4 is your headline. Identify the top 5 and bottom 5 neighborhoods.
-- - Query 5 is the deeper insight. Look at the median covered_pct. That number
--   is your case-study finding.
-- =============================================================================
