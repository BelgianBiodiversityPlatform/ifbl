DROP TABLE inbo_dwca IF EXISTS

CREATE TABLE inbo_dwca
(
  guid character varying(32),
  country character varying(2),
  originalnameusage text,
  verbatimlocality text,
  decimallatitude double precision,
  decimallongitude double precision,
  basisofrecord character varying(32),
  catalognumber integer NOT NULL,
  eventdate text,
  language character varying(8),
  verbatimtaxonrank character varying(8),
  collectioncode character varying(12),
  taxonrank character varying(32),
  scientificname character varying(64),
  verbatimcoordinatesystem character varying(8),
  institutioncode character varying(4),
  modified date,
  geodeticdatum character(5),
  verbatimcoordinates character varying(8),
  occurrencedetails text,
  recordedby text,
  nomenclaturalcode character(4),
  coordinateuncertaintyinmeters integer,
  legalrights text,
  CONSTRAINT inbo_dwca_pkey PRIMARY KEY (catalognumber )
)
WITH (
  OIDS=FALSE
);
ALTER TABLE inbo_dwca
  OWNER TO nnoe;


COPY inbo_dwca FROM '/home/nnoe/dwca-florabank/occurrence.txt' DELIMITER '\t';
