TODO
====

* Read Dimi's mail to see what he expects from this new import.
* Regarder webapp (migrations)

Summary
=======

This directory contains the updated (2014) import scripts for the IFBL project.

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
    