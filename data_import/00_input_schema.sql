-- Create tables for the first stage (raw import)

CREATE TABLE ifbl_2009 ( 
    "IFBL" text,                    --- 1km square IFBL code
    "NaamWetenschappelijk" text,    --- species name
    "NaamNederlands" text,          --- vernacular name
    "BeginDatum" text,              --- observation date
    "EindDatum" text,               --- observation date, (=BeginDatum)
    "Bron" text,                    --- checklist source
    "Toponiem" text,                --- where in Belgium
    "Achternaam" text,              --- observer name
    "Voornaam" text                 --- observer firstname
) with OIDS;

CREATE TABLE ifbl_2010 ( 
    "IFBL" text,                    --- 1km square IFBL code
    "NaamWetenschappelijk" text,    --- species name
    "NaamNederlands" text,          --- vernacular name
    "BeginDatum" text,              --- observation date
    "EindDatum" text,               --- observation date, (=BeginDatum)
    "Bron" text,                    --- checklist source
    "Toponiem" text,                --- where in Belgium
    "Achternaam" text,              --- observer name
    "Voornaam" text                 --- observer firstname
) with OIDS;


CREATE TABLE ifbl_2013 (
    "IFBL" text,                    --- 1km square IFBL code
    "NaamWetenschappelijk" text,    --- species name
    "NaamNederlands" text,          --- vernacular name
    "BeginDatum" text,              --- observation date
    "EindDatum" text,               --- observation date, (=BeginDatum)
    "Bron" text,                    --- checklist source
    "Toponiem" text,                --- where in Belgium
    "Achternaam" text,              --- observer name
    "Voornaam" text,                --- observer firstname
    "NationalePlantentuinNummer" text --- NBGB number
) with OIDS;

CREATE TABLE inbo_dwca ( --- Florabank
    guid                varchar(32),
    occurrenceDetails   text,
    nomenclaturalCode   char(4),
    verbatimCoordinateSystem varchar(8),
    geodeticDatum       char(5),
    catalogNumber       integer,
    verbatimLocality    text,
    verbatimTaxonRank   varchar(8),
    scientificName      varchar(64),
    recordedBy          text,
    language            varchar(8),
    verbatimCoordinates varchar(8),
    decimalLongitude    float,
    originalNameUsage   text,
    country             varchar(2),
    taxonRank           varchar(32),
    collectionCode      varchar(12),
    eventDate           text,
    modified            date,
    institutionCode     varchar(4),
    decimalLatitude     float,
    coordinateUncertaintyInMeters int,
    basisOfRecord       varchar(32),
    primary key (catalogNumber)
);