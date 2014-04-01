--- drop table ifbl_input;
create table ifbl_input ( --- specimens input table as received from digitization project	
	"IFBL" text,					--- 1km square IFBL code
	"NaamWetenschappelijk" text, 	--- species name
	"NaamNederlands" text,			--- vernacular name
	"BeginDatum" text,				--- observation date
	"EindDatum" text,				--- observation date, (=BeginDatum)
	"Bron" text,					--- checklist source
	"Toponiem" text,				--- where in Belgium
	"Achternaam" text,				--- observer name
	"Voornaam" text  				--- observer firstname
) with OIDS;


--- drop table ifbl_2013;
create table ifbl_2013 ( --- 2013 Flanders+Brussels+Wallonia
	"IFBL" text,					--- 1km square IFBL code
	"NaamWetenschappelijk" text, 	--- species name
	"NaamNederlands" text,			--- vernacular name
	"BeginDatum" text,				--- observation date
	"EindDatum" text,				--- observation date, (=BeginDatum)
	"Bron" text,					--- checklist source
	"Toponiem" text,				--- where in Belgium
	"Achternaam" text,				--- observer name
	"Voornaam" text,  				--- observer firstname
	"NationalePlantentuinNummer" text --- NBGB number
) with OIDS;
	

---drop table ifbl_squares;
create table ifbl_squares ( --- ifbl squares
	code	varchar(8) primary key,
	lat		float,
	long 	float
);

---DROP AGGREGATE array_accum ( anyelement) cascade;
CREATE AGGREGATE array_accum (
    sfunc = array_append,
    basetype = anyelement,
    stype = anyarray,
    initcond = '{}'
);

drop table inbo_dwca;
create table inbo_dwca ( --- DarwinCore records as published by INBO
	guid 				varchar(32),
	occurrenceDetails 	text,
	nomenclaturalCode	char(4),
	verbatimCoordinateSystem varchar(8),
	geodeticDatum		char(5),
	catalogNumber		integer,
	verbatimLocality	text,
	verbatimTaxonRank	varchar(8),
	scientificName		varchar(64),
	recordedBy			text,
	language			varchar(8),
	verbatimCoordinates varchar(8),
	decimalLongitude	float,
	originalNameUsage	text,
	country				varchar(2),
	taxonRank			varchar(32),
	collectionCode 		varchar(12),
	eventDate 			text,
	modified 			date,
	institutionCode 	varchar(4),
	decimalLatitude 	float,
	coordinateUncertaintyInMeters int,
	basisOfRecord 		varchar(32),
	primary key (catalogNumber)
);