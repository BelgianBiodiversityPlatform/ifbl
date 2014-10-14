Data import / app setup at a glance:
====================================

1. $ pip install -r requirements.txt
2. Configure variables at the top of import_all.py (you'll need a GeoWebApi instance)
3. Run ./import_all.py
4. DB is ready ! (Re)configure if necessary:
    4.1 Rails app
    4.2 Geoserver for Rails app (see below)
    4.3 IPT (consume view)

Notes: 
    - Rails migrations should not be run, they were replaced by Python import scripts.

Geoserver config
================

1) publish "areas_4_derived_from_1" and "areas_with_direct_checklists" directly from the views.
2) For the others layers ("squares_per_species_and_time" and "squares4_per_species_and_time"), we have to use the "SQL views" features of geoserver. Here is the config details:

NB: Take care when configuring Geoserver : SQL Views parameters (such as range_start and range_end) sometimes are messed up by the web interface
NB2: Sometimes geoserver fails because it tries to access some postgis table. The database should be configured so that the SEARCH PATH includes gis (this is done by the import script)

For squares4_per_species_and_time, the config is  identic to squares_per_species_and_time, EXCEPT:
- name of the layer (of course)
- replace WHERE checklists.area3_id by WHERE checklists.area2_id

SQL Statement:
==============

SELECT areas.the_geom, areas.ifbl_code, count(*) AS nb_observations, observations.species_id
   FROM nbgb_ifbl.areas, nbgb_ifbl.checklists, nbgb_ifbl.observations
  WHERE checklists.area3_id = areas.id AND observations.checklist_id = checklists.id


AND ((checklists.begin_date, checklists.end_date) OVERLAPS (DATE '%range_start%', DATE '%range_end%')
)

  GROUP BY areas.ifbl_code, areas.the_geom, observations.species_id
  
SQL view parameters:
====================

range_start 1000-01-01  ^\d\d\d\d-\d\d-\d\d$
range_end   70000-12-31 ^\d\d\d\d-\d\d-\d\d$

Attributes:
===========

the_geom        Geometry    3857
ifbl_code       String          
nb_observations     Long
species_id      Integer

------------------------------------------------------------------------
You'll also have to configure STYLING in Geoserver: 

For squares_XXX layers: (name: ifbl_param):
-------------------------------------------

<?xml version="1.0" encoding="ISO-8859-1"?>
<StyledLayerDescriptor version="1.0.0"
    xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <NamedLayer>
    <Name>Simple polygon</Name>
    <UserStyle>
      <Title>SLD Cook Book: Simple polygon</Title>
      <FeatureTypeStyle>
        <Rule>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">
                #<ogc:Function name="env">
                  <ogc:Literal>color</ogc:Literal>
                  <ogc:Literal>FF0000</ogc:Literal>
                </ogc:Function>
              </CssParameter>
          <CssParameter name="fill-opacity">0.4</CssParameter>
            </Fill>
          </PolygonSymbolizer>
        </Rule>
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>

For area_ layers (name ifbl_noparam):
=====================================

<?xml version="1.0" encoding="ISO-8859-1"?>
<StyledLayerDescriptor version="1.0.0"
    xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <NamedLayer>
    <Name>Simple polygon</Name>
    <UserStyle>
      <Title>SLD Cook Book: Simple polygon</Title>
      <FeatureTypeStyle>
        <Rule>
          <PolygonSymbolizer>
            <Fill>
              <CssParameter name="fill">#338000</CssParameter>
              <CssParameter name="fill-opacity">0.4</CssParameter>
            </Fill>
            <Stroke>
               <CssParameter name="stroke">#000000</CssParameter>
               <CssParameter name="stroke-width">1</CssParameter>
             </Stroke>
          </PolygonSymbolizer>
        </Rule>
      </FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>

We also have to create a distinc style named ifbl_param_print (and make it available - NOT AS DEFAULT - to squares_per_species_and_time AND squares4_per_species_and_time):
=> content of style: idem to ifbl_param but with the opacity at 1 instead of 0.4.


Layouts:
========

In geoserver data dir, we should also create a "layouts" directory containing two files:

ifbl_print_w_ecoregions.xml:
----------------------------

<layout>
    <decoration type="image" affinity="bottom,left" offset="36,36">
        <option name="url" value="http://home.bebif.be/ifbl/images/bbpf_logo.png"/>
    </decoration>
    <decoration type="image" affinity="bottom,left" offset="36,200">
        <option name="url" value="http://home.bebif.be/ifbl/images/ecoregion_legend.png"/>
    </decoration>
</layout>

ifbl_print:
-----------

Idem, but without the second (ecoregion) "decoration" block

Style: ifbl_print_background:
<?xml version="1.0" encoding="ISO-8859-1"?>
<StyledLayerDescriptor version="1.0.0"
 xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd"
 xmlns="http://www.opengis.net/sld"
 xmlns:ogc="http://www.opengis.net/ogc"
 xmlns:xlink="http://www.w3.org/1999/xlink"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<!-- a Named Layer is the basic building block of an SLD document -->
<NamedLayer>
<Name>default_polygon</Name>
<UserStyle>
<!-- Styles can have names, titles and abstracts -->
<Title>Default Polygon</Title>
<Abstract>A sample style that draws a polygon</Abstract>
<!-- FeatureTypeStyles describe how to render different features -->
<!-- A FeatureTypeStyle for rendering polygons -->
<FeatureTypeStyle>
<Rule>
<Name>rule1</Name>
<Title>Gray Polygon with Black Outline</Title>
<Abstract>A polygon with a gray fill and a 1 pixel black outline</Abstract>
<PolygonSymbolizer>
<Fill>
<CssParameter name="fill">#FFFFFF</CssParameter>
</Fill>
<Stroke>
<CssParameter name="stroke">#A65500</CssParameter>
<CssParameter name="stroke-width">2</CssParameter>
</Stroke>
</PolygonSymbolizer>
</Rule>
</FeatureTypeStyle>
</UserStyle>
</NamedLayer>
</StyledLayerDescriptor>


Summary
=======

This directory contains the updated (2014) import scripts and documentation for the IFBL project.

Input:
------
    * CSV files frm the 3 IFBL Digit Calls
    * Other floristic data from Florabank
    * It will need a connextion to GeoWebApi to retrieve IFBL square details.

Output:
-------

One single database (raw/preparatory data in schema public, processed/webapp data in nbgb_ifbl):
    * Containing all the source data for the Rails webapp
    * And a DwC view to be consumed by IPT (GBIF publication). !!! Florabank data should be filtered from this view so it is not published twice at GBIF!!!


Content
=======
    * ifbl_csv_source: source data from IFBL Digit Calls
    * previous_imports: previous import scripts given by andre
    