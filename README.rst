This repository contains code for the IFBL project. It contains:

- webapp directory: the source code of the Rails 3 application that powers http://projects.biodiversity.be/ifbl
- data_import: Python import scripts (+IFBL projects data) used to create the IFBL database. This database is consumed by:
    - Rails for the website
    - GeoServer for Geospatial features of the website
    - IPT for publishing IFBL data to GBIF