--- fix empty names
update ifbl_2009 set "Voornaam"='' where "Voornaam" is null; 
--- fix wrong date format: expected date format is YYYY-MM-DD, convert when format is DD/MM/YYYY
update ifbl_2009 set "BeginDatum" = '1953-08-09' where "BeginDatum"= '0908/1953';
update ifbl_2009 set "BeginDatum" = '1955-03-22' where "BeginDatum"= '22-03-1955';
update ifbl_2009 set "BeginDatum" = '1953-11-22' where "BeginDatum"= '22-11-1953';
update ifbl_2009 set "EindDatum" = '1952-07-26' where "EindDatum"= '26/07/195';
update ifbl_2009 set "EindDatum" = '1955-03-22' where "EindDatum"= '22-03-1955';
update ifbl_2009 set "EindDatum" = '1953-11-22' where "EindDatum"= '22-11-1953';

update ifbl_2009
set "BeginDatum"= to_date("BeginDatum",'DD/MM/YYYY')::text
where "BeginDatum" like '__/__/____';
update ifbl_2009
set "EindDatum"= to_date("EindDatum",'DD/MM/YYYY')::text
where "EindDatum" like '__/__/____';

update ifbl_2010 set "Voornaam"='' where "Voornaam" is null; 
--- fix wrong date format: expected date format is YYYY-MM-DD, convert when format is DD/MM/YYYY
update ifbl_2010 set "BeginDatum" = '10/09/1961' where "BeginDatum"= '10/09/191';
update ifbl_2010 set "BeginDatum" = '28/04/1959' where "BeginDatum"= '28/04/199';
update ifbl_2010 set "BeginDatum" = '22/08/1954' where "BeginDatum"= '2/08/1954';
update ifbl_2010 set "BeginDatum" = '19/06/1949' where "BeginDatum"= '9/06/1949';
update ifbl_2010 set "BeginDatum" = '1970-10-04' where "BeginDatum"= '0970-10-04';
update ifbl_2010 set "EindDatum" = '10/10/195' where "EindDatum"= '10/10/1950';
update ifbl_2010 set "EindDatum" = '18/07/1950' where "EindDatum"= '9/07/1950';

update ifbl_2010
set "BeginDatum"= to_date("BeginDatum",'DD/MM/YYYY')::text where "BeginDatum" ~ E'\\d{1,2}/\\d{1,2}/\\d{4}';
update ifbl_2010
set "EindDatum"= to_date("EindDatum",'DD/MM/YYYY')::text where "EindDatum" ~ E'\\d{1,2}/\\d{1,2}/\\d{4}';
