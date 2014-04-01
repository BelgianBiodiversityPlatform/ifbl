---DROP VIEW dwC14_ifbl;
CREATE OR REPLACE VIEW dwC14_ifbl AS 
-- DarwinCore 1.4 --
SELECT 'BR:IFBL:' || to_char(observation.id, '00000009')::text AS GlobalUniqueIdentifier,
		'2014-03-19'::date AS DateLastModified, 
		'HumanObservation'::text AS BasisOfRecord, 
		'BR'::text AS InstitutionCode, 
		'IFBL'::text AS CollectionCode, 
		to_char(observation.id, '00000009')::text AS CatalogNumber,
---		NULL::text AS InformationWithheld,
---		NULL::text AS Remarks,
-- Taxonomic Elements --
		COALESCE(species.scientific_name) AS ScientificName, 
---		NULL::text AS HigherTaxon,
---		NULL::text AS Kingdom,
--- 	NULL::text AS Phylum, 
---		tc.name::text AS Class, 
---		NULL::text AS Order, 
---		tf.name::text AS Family, 
---		tg.name::text AS Genus, 
---		ts.name::text AS SpecificEpithet, 
---		NULL::text AS InfraSpecificRank, 
---		NULL::text AS InfraSpecificEpithet,
---		ts.author AS AuthorYearOfScientificName,		 
		'ICBN'::text AS NomenclaturalCode,
-- Identification Elements --
---		specimen.identif_qualifier::text AS IdentificationQualifier,
-- Locality Elements --
---		NULL::text AS HigherGeography, 
---		NULL::text AS Continent, 
---		NULL::text AS WaterBody, 
---		NULL::text AS IslandGroup, 
---		NULL::text AS Island, 
		'BE'::text AS Country, 
---		NULL::text AS StateProvince, 
---		NULL::text AS County, 
		area.toponym::text AS Locality, 
---		nullif(specimen.altitude,0)::text AS MinimumElevationInMeters, 
---		nullif(specimen.altitude,0)::text AS MaximumElevationInMeters, 
---		NULL::text AS MinimumDepthInMeters, 
---		NULL::text AS MaximumDepthInMeters, 
-- Collecting Event Elements --
---		NULL::text AS CollectingMethod,
---		NULL::text AS ValidDistributionFlag,
		checklist.begin_date::text as EarliestDateCollected,
		checklist.end_date::text as LatestDateCollected,
---		NULL::text as DayOfYear,
		checklist.observers AS Collector, 
-- Biological Elements --
---		NULL::text AS Sex, 
---		NULL::text AS LifeStage, 
---		NULL::text AS Attributes,
-- References Elements --
---		NULL::text AS ImageURL,
---		NULL::text AS RelatedInformation,

-- Curatorial Extension --
		observation.id AS CatalogNumberNumeric,
---		coalesce(identifier.family_name ||', '||identifier.first_name, '')::text AS IdentifiedBy, 
---		specimen.identified_date::text AS DateIdentified, 
---		specimen.collection_num::text AS CollectorNumber, 
---		coalesce(specimen.label,'')::text AS FieldNumber, 
---		specimen.station::text AS FieldNotes, 
---		NULL::text as VerbatimCollectingDate,
---		NULL::text AS VerbatimElevation, 
---		NULL::text AS VerbatimDepth, 
---		NULL::text AS Preparations, 
---		specimen.type_status::text AS TypeStatus,
---		NULL::text AS GenBankNumber, 
---		NULL::text AS OtherCatalogNumbers, 
---		NULL::text AS RelatedCatalogedItems,
---		specimen.disposition AS Disposition,
---		NULL::text AS IndividualCount, 

-- Geospatial Extension --
		to_char(area.latitude, 'S990D999')::text AS DecimalLatitude, 
		to_char(area.longitude, 'S990D999')::text AS DecimalLongitude, 
		'WGS84'::text AS GeodeticDatum, 
		'750'::text AS CoordinateUncertaintyInMeters,
---		NULL::text AS PointRadiusSpatialFit,
		area.ifbl_code::text AS VerbatimCoordinates,
---		specimen.orig_lat::text AS VerbatimLatitude, 
---		specimen.orig_long::text AS VerbatimLongitude
		'IFBL 1km'::text AS VerbatimCoordinateSystem
---		NULL::text AS GeoreferenceProtocol, 
---		NULL::text AS GeoreferenceSources,
---		NULL::text AS GeoreferenceVerificationStatus,
---		NULL::text AS GeoreferenceRemarks, 
---		NULL::text AS FootprintWKT, 
---		NULL::text AS FootprintSpatialFit

	FROM nbgb_ifbl.observations observation
		LEFT JOIN nbgb_ifbl.checklists checklist ON checklist.id = observation.checklist_id
		LEFT JOIN nbgb_ifbl.species species ON species.id = observation.species_id
		LEFT JOIN nbgb_ifbl.areas area ON area.id = checklist.area3_id	
	WHERE observation.source_id in (1,2, 3)
;



---select * from dwC14_ifbl limit 1000;

