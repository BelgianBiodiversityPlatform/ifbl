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
    "scientificName" varchar(255),
    "verbatimCoordinates" varchar(255),
    "verbatimLocality" varchar(255),
    "coordinateUncertaintyInMeters" varchar(255),
    "verbatimCoordinateSystem" varchar(255),
    "associatedReferences" varchar(255),
    "eventDate" varchar(64),
    "recordedBy" varchar(255),
    "catalogNumber" varchar(255),

    primary key ("catalogNumber")
);