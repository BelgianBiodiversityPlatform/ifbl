This is the Rails application powering the http://projects.biodiversity.be/ifbl

Requirements
============

- Tested with ruby 1.9.2
- Required gems listed in Gemfile, install with Bundler

To install
==========

- Create the database that will be shared by the Rails app, but also by Geoserver and IPT. See doc in data_import/README.txt
- Do NOT run Rails migrations, they have been integrated in the Python import script
- Possibly, reconfigure/update GeoServer and IPT, see also in data_import/README.txt
- Configure database.yml
- Bundle install to install dependencies
- In application.js, configure: IFBL.constants.wms_url (it may be necessary to setup a proxy server for GeoServer to avoid Same-origin policy issues)
