TODO
====



* Read Dimi's mail to see what he expects from this new import.
* Regarder webapp (migrations)
* Import details about Geoserver, etc... in data_import_2012/README.txt (to move here)

Summary
=======

This directory contains the updated (2014) import scripts and documentation for the IFBL project.

Input:
------
    * CSV files frm the 3 IFBL Digit Calls
    * Other floristic data from Florabank

Output:
-------

One single database (raw/preparatory data in schema public, processed/webapp data in nbgb_ifbl):
    * Containing all the source data for the Rails webapp
    * And a DwC view to be consumed by IPT (GBIF publication). !!! Florabank data should be filtered from this view so it is not published twice at GBIF!!!


Content
=======
    * ifbl_csv_source: source data from IFBL Digit Calls
    * previous_imports: previous import scripts given by andre

Instructions
============

Automatically
-------------
::

    $ pip install -r requirements.txt
    $ ./import_all.py

Manually
---------

$ createdb ifbl  # Create database

TODO: Document from Python script


Changé depuis André, à checker:
-------------------------------

00_input_schema.sql: retiré tables ifbl_square et aggregate array_accum
    