COPY ifbl_squares FROM '/home/nnoe/test_apps/ifblserver/new_data_import/datasource/ifblCodes_lat_long.csv' NULL AS '' DELIMITER ';' HEADER CSV;
COPY ifbl_squares FROM '/home/nnoe/test_apps/ifblserver/new_data_import/datasource/ifbl4-fixed.csv' NULL AS '' DELIMITER ';' HEADER CSV;
--COPY ifbl_squares FROM '/home/nnoe/IFBL_source/ifbl32x20.csv' NULL AS '' DELIMITER ';' HEADER CSV; 
