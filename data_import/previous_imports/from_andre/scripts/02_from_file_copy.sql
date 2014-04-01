---MS-Access: export file as delimited text
---EditPlus: save in UTF8 format

--- Import intoPostgreSQL
COPY ifbl_input FROM '/home/aheugheb/db/IFBL/IFBL input.txt' NULL AS '' DELIMITER ';' HEADER CSV;
COPY ifbl_squares FROM '/home/aheugheb/db/IFBL/ifblCodes_lat_long.csv' NULL AS '' DELIMITER ';' HEADER CSV;
COPY ifbl_squares FROM '/home/aheugheb/db/IFBL/ifbl4.csv' NULL AS '' DELIMITER ';' HEADER CSV;
COPY ifbl_squares FROM '/home/aheugheb/db/IFBL/ifbl32x20.csv' NULL AS '' DELIMITER ';' HEADER CSV;

COPY ifbl_2009 FROM '/home/aheugheb/db2/ifbl/IFBL2009.csv' NULL AS '' DELIMITER ',' HEADER CSV;
COPY ifbl_2010 FROM '/home/aheugheb/db2/ifbl/IFBL2010.csv' NULL AS '' DELIMITER ',' HEADER CSV;
COPY ifbl_2013 FROM '/home/aheugheb/db2/ifbl/IFBL2013.csv' NULL AS '' DELIMITER ';' HEADER CSV;

--- fix IFBL III 2013 dates
select "BeginDatum", "EindDatum" from ifbl_2013 where length("BeginDatum") != 10 order by "BeginDatum";
update ifbl_2013 set "BeginDatum" = '01/01/1970' where "BeginDatum"='01/01/190' and "EindDatum"='31/12/1970';
update ifbl_2013 set "BeginDatum" = '01/01/1953' where "BeginDatum"='01/01/195' and "EindDatum"='01/01/1953';
update ifbl_2013 set "BeginDatum" = '02/07/1939' where "BeginDatum"='02/071939' and "EindDatum"='03/07/1939';
update ifbl_2013 set "BeginDatum" = "EindDatum" where "BeginDatum"='12/061948' and "EindDatum"='12/06/1948';
update ifbl_2013 set "BeginDatum" = "EindDatum" where "BeginDatum"='20/03/191' and "EindDatum"='20/03/1951';
update ifbl_2013 set "BeginDatum" = "EindDatum" where "BeginDatum"='24/061958' and "EindDatum"='24/06/1958';
update ifbl_2013 set "BeginDatum" = "EindDatum" where "BeginDatum"='27021960' and "EindDatum"='27/02/1960';
update ifbl_2013 set "BeginDatum" = "EindDatum" where "BeginDatum"='28/07/194' and "EindDatum"='28/07/1948';
update ifbl_2013 set "BeginDatum" = "EindDatum" where "BeginDatum"='25/040/196' and "EindDatum"='25/04/1965';
update ifbl_2013 set "BeginDatum" = '01/01/1970' where "BeginDatum"='01/001/197' and "EindDatum"='31/12/1970';
update ifbl_2013 set "BeginDatum" = '1963-02-28' where "BeginDatum"='1963-02-29';
update ifbl_2013 set "BeginDatum" = '1948-04-30' where "BeginDatum"='1948-04-31';

select "BeginDatum", "EindDatum" from ifbl_2013 where length("EindDatum") != 10 order by "EindDatum";
update ifbl_2013 set "EindDatum" = "BeginDatum" where "BeginDatum"='13/06/1948' and "EindDatum"='13/06/948';
update ifbl_2013 set "EindDatum" = "BeginDatum" where "BeginDatum"='18/06/1955' and "EindDatum"='18/06/195';
update ifbl_2013 set "EindDatum" = "BeginDatum" where "BeginDatum"='20/10/1948' and "EindDatum"='20/101948';
update ifbl_2013 set "EindDatum" = '31/07/1946' where "BeginDatum"='01/07/1946' and "EindDatum"='31/071946';
update ifbl_2013 set "EindDatum" = "BeginDatum" where "EindDatum"='05/071/953';
update ifbl_2013 set "EindDatum" = "BeginDatum" where "EindDatum"='15/001/196';
update ifbl_2013 set "EindDatum" = "BeginDatum" where "EindDatum"='31/007/196';
update ifbl_2013 set "EindDatum" = '1962-09-30' where "EindDatum"='1962-09-31';
update ifbl_2013 set "EindDatum" = '1963-02-28' where "EindDatum"='1963-02-29';
update ifbl_2013 set "EindDatum" = '1938-06-30' where "EindDatum"='1938-06-31';
update ifbl_2013 set "EindDatum" = '1954-06-30' where "EindDatum"='1954-06-31';
update ifbl_2013 set "EindDatum" = '1963-06-30' where "EindDatum"='1963-06-31';
update ifbl_2013 set "EindDatum" = '1957-06-30' where "EindDatum"='1957-06-31';
update ifbl_2013 set "EindDatum" = '1959-06-30' where "EindDatum"='1959-06-31';
update ifbl_2013 set "EindDatum" = '1948-04-30' where "EindDatum"='1948-04-31';
update ifbl_2013 set "EindDatum" = '1962-04-30' where "EindDatum"='1962-04-31';

select  "EindDatum"::date from ifbl_2013 i ;


update ifbl_2013 set "BeginDatum" =split_part("BeginDatum", '/', 3) || '-' || split_part("BeginDatum", '/', 2) || '-' || split_part("BeginDatum", '/', 1) where "BeginDatum"  ~ E'\\d{2}/\\d{2}/\\d{4}';
update ifbl_2013 set "EindDatum" =split_part("EindDatum", '/', 3) || '-' || split_part("EindDatum", '/', 2) || '-' || split_part("EindDatum", '/', 1) where "EindDatum"  ~ E'\\d{2}/\\d{2}/\\d{4}';

--- fix empty names
update ifbl_input set "Voornaam"='' where "Voornaam" is null; 

--- fix wrong date format: expected date format is YYYY-MM-DD, convert when format is DD/MM/YYYY
update ifbl_input set "BeginDatum" = '1953-08-09' where "BeginDatum"= '0908/1953';
update ifbl_input set "BeginDatum" = '1955-03-22' where "BeginDatum"= '22-03-1955';
update ifbl_input set "BeginDatum" = '1953-11-22' where "BeginDatum"= '22-11-1953';
update ifbl_input set "EindDatum" = '1952-07-26' where "EindDatum"= '26/07/195';
update ifbl_input set "EindDatum" = '1955-03-22' where "EindDatum"= '22-03-1955';
update ifbl_input set "EindDatum" = '1953-11-22' where "EindDatum"= '22-11-1953';

update ifbl_input
set "BeginDatum"= to_date("BeginDatum",'DD/MM/YYYY')::text
where "BeginDatum" like '__/__/____';
update ifbl_input
set "EindDatum"= to_date("EindDatum",'DD/MM/YYYY')::text
where "EindDatum" like '__/__/____';

update ifbl2_input set "Voornaam"='' where "Voornaam" is null; 
--- fix wrong date format: expected date format is YYYY-MM-DD, convert when format is DD/MM/YYYY
update ifbl2_input set "BeginDatum" = '10/09/1961' where "BeginDatum"= '10/09/191';
update ifbl2_input set "BeginDatum" = '28/04/1959' where "BeginDatum"= '28/04/199';
update ifbl2_input set "BeginDatum" = '22/08/1954' where "BeginDatum"= '2/08/1954';
update ifbl2_input set "BeginDatum" = '19/06/1949' where "BeginDatum"= '9/06/1949';
update ifbl2_input set "BeginDatum" = '1970-10-04' where "BeginDatum"= '0970-10-04';
update ifbl2_input set "EindDatum" = '10/10/195' where "EindDatum"= '10/10/1950';
update ifbl2_input set "EindDatum" = '18/07/1950' where "EindDatum"= '9/07/1950';

update ifbl2_input
set "BeginDatum"= to_date("BeginDatum",'DD/MM/YYYY')::text where "BeginDatum" ~ E'\\d{1,2}/\\d{1,2}/\\d{4}';
update ifbl2_input
set "EindDatum"= to_date("EindDatum",'DD/MM/YYYY')::text where "EindDatum" ~ E'\\d{1,2}/\\d{1,2}/\\d{4}';

--- Import from INBO DwcArchive
COPY inbo_dwca FROM '/home/aheugheb/florabank/occurrence.txt' DELIMITER '\t';

