-- Create tables for the first stage (raw import)

DROP TABLE IF EXISTS ifbl_2009;
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

DROP TABLE IF EXISTS ifbl_2010;
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


DROP TABLE IF EXISTS ifbl_2013;
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