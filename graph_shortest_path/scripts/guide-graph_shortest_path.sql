/* ------------------------------------------------------------------------ */
/* Workbook: Shortest Path - Guide                                          */
/* This workbook shows you how to use the shortest path solver in Kinetica. */
/* ------------------------------------------------------------------------ */

/* ------------------------ */
/* Worksheet: Load the data */
/* ------------------------ */

/*
Create the data source
The data for this guide is store in a publicly accessible AWS S3 bucket. Our first task is to create a data source that points to this bucket.
*/


CREATE OR REPLACE DATA SOURCE guides_data
LOCATION = 'S3'
WITH OPTIONS (
    ANONYMOUS = 'true',
    BUCKET NAME = 'guidesdatapublic',
    REGION = 'us-east-1'
);

/*
Load road weights data into Kinetica
Once a data source is defined we can start loading data from it into Kinetica.
We will be using the seattle_roads file for this guide. The road weights data provides information on the time taken to travel different road segments in Seattle. We will use this information to compute the shortest path between different points in terms of travel time.
*/


LOAD DATA INTO seattle_roads
FROM FILE PATHS 'seattle_roads.csv'
FORMAT TEXT 
WITH OPTIONS(
    DATA SOURCE = 'guides_data'
);

/* --------------------------- */
/* Worksheet: Explore the data */
/* --------------------------- */

SELECT * 
FROM ki_home.seattle_roads
LIMIT 5;

/*
A closer look at the data
Run the code above to see the first 5 rows of the road_weights data. The road weights data is a geo spatial dataset with data on the Seattle Road Network. The network is broken into small road segments with the following information for each segment.
1. OriginalEdgeID - Unique identifier for each road segment
2. TwoWay - 0 indicates one way and 1 indicates a two way edge
3. WKTLINE - The WKT Linestring that represents each road segment geo spatially.
4. time - This is the time that it would take to traverse each segment.
*/


/*
The map slice below shows the WKT Linestrings on a map for a visual representation of the same data.
*/


/* --------------------------- */
/* Worksheet: Create the graph */
/* --------------------------- */

/*
In this sheet we will convert the road network data into a graph. Each road segment in the data will be represented as an edge on the graph. Each road segment has an associated direction and a weight. So we end up with a weighted directed graph of the Seattle road network.
*/


/*
Creating graphs in Kinetica
Graphs in Kinetica can have 4 components - nodes, edges, weights and restrictions. The primary task when creating a graph is to use the data at hand to accurately identify the required components for creating the graph.
The two videos below give a quick introduction to creating graphs in Kinetica
- https://youtu.be/ouZb00xEzh8
- https://youtu.be/oLYIPBRteEM
*/


/*
Picking the identifier combination for creating the graph
Based on the data that we have, we can create a weighted graph with direction.
- the edges are represented using WKT LINESTRINGs in the WKTLINE column of the seattle_road_network table (EDGE_WKTLINE). The road segments' directionality is derived from the TwoWay column of the seattle_road_network table (EDGE_DIRECTION).
- the weights are represented using the time taken to travel the segment found in the time column of the seattle_road_network table (WEIGHTS_VALUESPECIFIED). The weights are matched to the edges using the same WKTLINE column as edges (WEIGHTS_EDGE_WKTLINE) and the same TwoWay column as the edge direction (WEIGHTS_EDGE_DIRECTION).

The nodes for the graph are implicitly derived from the edges (as the starting and ending points of each edge). The restrictions component is empty since we are not restricting any of the nodes or edges for this example.
*/


CREATE OR REPLACE DIRECTED GRAPH GRAPH_S (
    EDGES => INPUT_TABLE(
        SELECT
            WKTLINE AS WKTLINE,
            TwoWay AS DIRECTION,
            time AS WEIGHT_VALUESPECIFIED
        FROM
            ki_home.seattle_roads
    ),    
    OPTIONS => KV_PAIRS(
        'graph_table' = 'seattle_graph_debug'
    )
);

/* -------------------------- */
/* Worksheet: Solve the graph */
/* -------------------------- */

/*
There are three different route combinations that we would like to solve.
1. One source to one destination
2. One souurce to many destinations
3. Many sources to many destination.

Let's take each one at a time.
*/


/*
One to One
Kinetica supports the creation and execution of User Defined Functions in SQL (https://docs.kinetica.com/7.1/sql/udf/#sql-execute-function). SOLVE_GRAPH is a function that can be executed either within a SELECT statement as a table function or within an EXECUTE FUNCTION call (https://docs.kinetica.com/7.1/sql/graph/#sql-graph-solve).
We will use the latter.
Our source point is `POINT(-122.1792501 47.2113606)` and our destination point is `POINT(-122.2221 47.5707)`. Let's start by creating two tables - one that stores all the sources and another for the destinations.
*/


/*
Set source and destination points
For our first route combination we start with one source - `POINT(-122.1792501 47.2113606)` - to one destination point - `POINT(-122.2221 47.5707)`. We will create two tables to store these source and desination points.
*/


-- Create tables to record the source and destination points

CREATE OR REPLACE TABLE seattle_sources (wkt WKT NOT NULL);

INSERT INTO ki_home.seattle_sources 
VALUES ('POINT(-122.1792501 47.2113606)');

CREATE OR REPLACE TABLE seattle_dest (wkt WKT NOT NULL);

INSERT INTO ki_home.seattle_dest
VALUES ('POINT(-122.2221 47.5707)');

/*
Kinetica supports the creation and execution of User Defined Functions in SQL.  (see: https://docs.kinetica.com/7.1/sql/udf/#sql-execute-function)
SOLVE_GRAPH is a function that can be executed either within a SELECT statement as a table function or within an EXECUTE FUNCTION call. We will use the latter.
*/


-- Execute the solve graph function
drop table if exists GRAPH_S_ONE_ONE_SOLVED;
EXECUTE FUNCTION SOLVE_GRAPH(
    GRAPH => 'GRAPH_S',
    SOLVER_TYPE => 'SHORTEST_PATH',
    SOURCE_NODES => INPUT_TABLE(SELECT ST_GEOMFROMTEXT(wkt) AS NODE_WKTPOINT from seattle_sources),
    DESTINATION_NODES => INPUT_TABLE(SELECT ST_GEOMFROMTEXT(wkt) AS NODE_WKTPOINT from seattle_dest),
    SOLUTION_TABLE => 'GRAPH_S_ONE_ONE_SOLVED'
);

/*
The solutions table provides the route for the shortest path and its associated costs.
*/


SELECT * FROM ki_home.GRAPH_S_ONE_ONE_SOLVED;

/*
You can easily visualize the route on workbench as shown below.
*/


/*
One to many
Next we want to find the shortest path from the same source point to multiple desination points. Let's update the destination table to add these additional points.
*/


INSERT INTO ki_home.seattle_dest
VALUES
('POINT(-122.541017 47.809121)'), 
('POINT(-122.520440 47.624725)'),
('POINT(-122.467915 47.427280)');

/*
The only change we need to make to our previous code, now is the name of the solution table.
*/


drop table if exists GRAPH_S_ONE_MANY_SOLVED;
EXECUTE FUNCTION SOLVE_GRAPH(
    GRAPH => 'GRAPH_S',
    SOLVER_TYPE => 'SHORTEST_PATH',
    SOURCE_NODES => INPUT_TABLE(SELECT ST_GEOMFROMTEXT(wkt) AS NODE_WKTPOINT from seattle_sources),
    DESTINATION_NODES => INPUT_TABLE(SELECT ST_GEOMFROMTEXT(wkt) AS NODE_WKTPOINT from seattle_dest),
    SOLUTION_TABLE => 'GRAPH_S_ONE_MANY_SOLVED'
);

/*
The solution table lists each route from the source point to the 4 destination points.
*/


select * from ki_home.GRAPH_S_ONE_MANY_SOLVED;

/*
Many to Many
The third example illustrates a shortest path solve from two source nodes to four destination nodes. For this example, there are two starting points (POINT(-122.1792501 47.2113606) and POINT(-122.375180125237 47.8122103214264) and paths will be calculated from the first source to two different destinations and from the second source to two other destinations. When many source nodes and many destination nodes are provided, the graph solver pairs the source and destination node by list index and calculate a shortest path solve for each pair. So the first point in the solver list is paired with the first in the destination so on and so forth.

Let's add these additional values to the source table. Note that we don't need to update the destination table since it already contains the 4 destination nodes.
*/


INSERT INTO ki_home.seattle_sources 
VALUES
('POINT(-122.1792501 47.2113606)'), 
('POINT(-122.375180125237 47.8122103214264)'),
('POINT(-122.375180125237 47.8122103214264)');

/*
The only thing to update in our solver function is the name of the solution table
*/


EXECUTE FUNCTION SOLVE_GRAPH(
    GRAPH => 'GRAPH_S',
    SOLVER_TYPE => 'SHORTEST_PATH',
    SOURCE_NODES => INPUT_TABLE((SELECT ST_GEOMFROMTEXT(wkt) AS NODE_WKTPOINT from seattle_sources)),
    DESTINATION_NODES => INPUT_TABLE((SELECT ST_GEOMFROMTEXT(wkt) AS NODE_WKTPOINT from seattle_dest)),
    SOLUTION_TABLE => 'GRAPH_S_MANY_MANY_SOLVED'
);

/*
Table shows the 4 routes from the two source points to two different destinations and the associated costs.
*/


select * from ki_home.GRAPH_S_MANY_MANY_SOLVED;
