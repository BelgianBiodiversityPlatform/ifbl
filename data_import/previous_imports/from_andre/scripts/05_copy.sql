INSERT INTO nbgb_ifbl.sources (name) VALUES ('IFBL digit2009'), ('IFBL digit2010'), ('IFBL digit2013'), ('INBO Florabank');


--- IMPORT DATA from IFBL2009 digit project
INSERT INTO nbgb_ifbl.people (source_id, family_name, first_name)
(
	select distinct on ("Achternaam","Voornaam") 1,"Achternaam","Voornaam" from ifbl_2009 i where "Achternaam" is not null order by "Achternaam","Voornaam"
);

INSERT INTO nbgb_ifbl.species (source_id,scientific_name, nl_name)
(
	select distinct on ("NaamWetenschappelijk","NaamNederlands") 1, "NaamWetenschappelijk","NaamNederlands" from ifbl_2009 i where "NaamWetenschappelijk" is not null order by "NaamWetenschappelijk"
);

INSERT INTO nbgb_ifbl.areas (source_id, ifbl_code, toponym, latitude, longitude, uncertainty, coordinateSystem)
(
	(select 1, code, '', lat, long, 10000, '32x20km' from ifbl_squares where length(code)=2)
	union
	(select 1, code, '', lat, long, 3000, 'IFBL 4km' from ifbl_squares where length(code)=5)
	union
	(select distinct on (i."IFBL") 1, i."IFBL", i."Toponiem", s.lat, s.long, 750, 'IFBL 1km' from ifbl_2009 i 
	left join ifbl_squares s on s.code = i."IFBL" where length(i."IFBL")=8 order by i."IFBL")
);

INSERT INTO nbgb_ifbl.models (source_id, name)
(
	select distinct on ("Bron") 1,"Bron" from ifbl_2009 i where "Bron" is not null order by "Bron"
);

INSERT INTO nbgb_ifbl.checklists (source_id, area1_id, area2_id, area3_id,model_id, begin_date, end_date)
(
select distinct on ("IFBL","BeginDatum") 1, a1.id, a2.id, a3.id, m.id, 
to_date("BeginDatum", 'YYYY-MM-DD'), 
to_date("EindDatum", 'YYYY-MM-DD') 
from ifbl_2009 i 
left join nbgb_ifbl.models m on m.name = i."Bron"
left join nbgb_ifbl.areas a1 on a1.ifbl_code = substr(i."IFBL",1,2)
left join nbgb_ifbl.areas a2 on a2.ifbl_code = substr(i."IFBL",1,5)
left join nbgb_ifbl.areas a3 on a3.ifbl_code = i."IFBL"
order by "IFBL","BeginDatum"
);

INSERT INTO nbgb_ifbl.observers (source_id,checklist_id, person_id)
(
	select distinct 1, c.id, o.id from ifbl_2009 i
	left join nbgb_ifbl.people o on (o.source_id=1 and o.family_name=i."Achternaam" and o.first_name= i."Voornaam") 
	left join nbgb_ifbl.areas a on (a.ifbl_code = i."IFBL")
	left join nbgb_ifbl.checklists c on (c.source_id=1 and c.area3_id = a.id and c.begin_date = to_date(i."BeginDatum", 'YYYY-MM-DD'))
	where length("IFBL")=8
);
INSERT INTO nbgb_ifbl.observations (source_id, checklist_id, species_id)
(
	select distinct 1, c.id, s.id from ifbl_2009 i
	left join nbgb_ifbl.species s on (s.scientific_name=i."NaamWetenschappelijk") 
	left join nbgb_ifbl.areas a on ( a.ifbl_code = i."IFBL")
	left join nbgb_ifbl.checklists c on (c.source_id=1 and c.area3_id = a.id and c.begin_date = to_date(i."BeginDatum", 'YYYY-MM-DD'))
	where length("IFBL")=8
);

Update nbgb_ifbl.checklists set observers= tmp.observers from (
	select checklist_id,
	array_to_string (array_accum((person.family_name || ' ' || person.first_name)::varchar::text), ', ') as observers
	from nbgb_ifbl.observers observer 
	join nbgb_ifbl.people person on person.id = observer.person_id
	group by observer.checklist_id
) as tmp where id= tmp.checklist_id

--- IMPORT DATA from IFBL2010 digit project
---DELETE FROM nbgb_ifbl.observations where source_id=2;
---DELETE FROM nbgb_ifbl.observers where source_id=2;
---DELETE FROM nbgb_ifbl.checklists where source_id=2;
---DELETE FROM nbgb_ifbl.models where source_id=2;
---DELETE FROM nbgb_ifbl.areas where source_id=2;
---DELETE FROM nbgb_ifbl.species where source_id=2;
---DELETE FROM nbgb_ifbl.people where source_id=2;

INSERT INTO nbgb_ifbl.people (source_id, family_name, first_name)
(
	select distinct on ("Achternaam","Voornaam") 2,"Achternaam","Voornaam" from ifbl_2010 i 
	where "Achternaam" is not null 
	and "Achternaam"||"Voornaam" not in (select family_name || first_name from nbgb_ifbl.people) 
	order by "Achternaam","Voornaam"
);

INSERT INTO nbgb_ifbl.species (source_id,scientific_name, nl_name)
(
	select distinct on ("NaamWetenschappelijk","NaamNederlands") 2, "NaamWetenschappelijk","NaamNederlands" from ifbl_2010 i 
	where "NaamWetenschappelijk" is not null 
	and "NaamWetenschappelijk" not in (select scientific_name from nbgb_ifbl.species)
	order by "NaamWetenschappelijk"
);

INSERT INTO nbgb_ifbl.areas (source_id, ifbl_code, toponym, latitude, longitude, uncertainty, coordinateSystem)
(

	select distinct on (i."IFBL") 2, i."IFBL", i."Toponiem", s.lat, s.long, 750, 'IFBL 1km' from ifbl_2010 i 
	left join ifbl_squares s on s.code = i."IFBL" 
	where length(i."IFBL")=8 
	and i."IFBL" not in (select ifbl_code from nbgb_ifbl.areas)
	order by i."IFBL"
);


INSERT INTO nbgb_ifbl.models (source_id, name)
(
	select distinct on ("Bron") 2,"Bron" from ifbl_2010 i 
	where "Bron" is not null 
	and "Bron" not in (select name from nbgb_ifbl.models)
	order by "Bron"
);

INSERT INTO nbgb_ifbl.checklists (source_id, area1_id, area2_id, area3_id,model_id, begin_date, end_date)
(
select distinct on ("IFBL","BeginDatum") 2, a1.id, a2.id, a3.id, m.id, 
"BeginDatum"::date, 
"EindDatum"::date
from ifbl_2010 i 
left join nbgb_ifbl.models m on m.name = i."Bron"
left join nbgb_ifbl.areas a1 on a1.ifbl_code = substr(i."IFBL",1,2)
left join nbgb_ifbl.areas a2 on a2.ifbl_code = substr(i."IFBL",1,5)
left join nbgb_ifbl.areas a3 on a3.ifbl_code = i."IFBL"
order by "IFBL","BeginDatum"
);

INSERT INTO nbgb_ifbl.observers (source_id,checklist_id, person_id)
(
	select distinct 2, c.id, o.id from ifbl_2010 i
	left join nbgb_ifbl.people o on (o.family_name=i."Achternaam" and o.first_name= i."Voornaam") 
	left join nbgb_ifbl.areas a on (a.ifbl_code = i."IFBL")
	left join nbgb_ifbl.checklists c on (c.source_id=2 and c.area3_id = a.id and c.begin_date = i."BeginDatum"::date)
	where length("IFBL")=8
);
INSERT INTO nbgb_ifbl.observations (source_id, checklist_id, species_id)
(
	select distinct 2, c.id, s.id from ifbl_2010 i
	left join nbgb_ifbl.species s on (s.scientific_name=i."NaamWetenschappelijk") 
	left join nbgb_ifbl.areas a on ( a.ifbl_code = i."IFBL")
	left join nbgb_ifbl.checklists c on (c.source_id=2 and c.area3_id = a.id and c.begin_date = i."BeginDatum"::date)
	where length("IFBL")=8
);

Update nbgb_ifbl.checklists set observers= tmp.observers from (
	select checklist_id,
	array_to_string (array_accum((person.family_name || ' ' || person.first_name)::varchar::text), ', ') as observers
	from nbgb_ifbl.observers observer 
	join nbgb_ifbl.people person on person.id = observer.person_id
	where observer.source_id=2
	group by observer.checklist_id
) as tmp where id= tmp.checklist_id;

--- IMPORT DATA from IFBL2013 digit project
---DELETE FROM nbgb_ifbl.observations where source_id=3;
---DELETE FROM nbgb_ifbl.observers where source_id=3;
---DELETE FROM nbgb_ifbl.checklists where source_id=3;
---DELETE FROM nbgb_ifbl.models where source_id=3;
---DELETE FROM nbgb_ifbl.areas where source_id=3;
---DELETE FROM nbgb_ifbl.species where source_id=3;
---DELETE FROM nbgb_ifbl.people where source_id=3;


INSERT INTO nbgb_ifbl.people (source_id, family_name, first_name)
(
	select distinct on ("Achternaam","Voornaam") 3,"Achternaam","Voornaam" from ifbl_2013 i 
	where "Achternaam" is not null 
	and "Achternaam"||"Voornaam" not in (select family_name || first_name from nbgb_ifbl.people) 
	order by "Achternaam","Voornaam"
);

INSERT INTO nbgb_ifbl.species (source_id,scientific_name, nl_name)
(
	select distinct on ("NaamWetenschappelijk","NaamNederlands") 3, "NaamWetenschappelijk","NaamNederlands" from ifbl_2013 i 
	where "NaamWetenschappelijk" is not null 
	and "NaamWetenschappelijk" not in (select scientific_name from nbgb_ifbl.species)
	order by "NaamWetenschappelijk"
);

INSERT INTO nbgb_ifbl.areas (source_id, ifbl_code, toponym, latitude, longitude, uncertainty, coordinateSystem)
(

	select distinct on (i."IFBL") 3, i."IFBL", i."Toponiem", s.lat, s.long, 750, 'IFBL 1km' from ifbl_2013 i 
	left join ifbl_squares s on s.code = i."IFBL" 
	where length(i."IFBL")=8 
	and i."IFBL" not in (select ifbl_code from nbgb_ifbl.areas)
	order by i."IFBL"
);


INSERT INTO nbgb_ifbl.models (source_id, name)
(
	select distinct on ("Bron") 3,"Bron" from ifbl_2013 i 
	where "Bron" is not null 
	and "Bron" not in (select name from nbgb_ifbl.models)
	order by "Bron"
);

INSERT INTO nbgb_ifbl.checklists (source_id, area1_id, area2_id, area3_id,model_id, begin_date, end_date)
(
select distinct on ("IFBL","BeginDatum") 3, a1.id, a2.id, a3.id, m.id, 
"BeginDatum"::date, 
"EindDatum"::date
from ifbl_2013 i 
left join nbgb_ifbl.models m on m.name = i."Bron"
left join nbgb_ifbl.areas a1 on a1.ifbl_code = substr(i."IFBL",1,2)
left join nbgb_ifbl.areas a2 on a2.ifbl_code = substr(i."IFBL",1,5)
left join nbgb_ifbl.areas a3 on a3.ifbl_code = i."IFBL"
order by "IFBL","BeginDatum"
);

INSERT INTO nbgb_ifbl.observers (source_id,checklist_id, person_id)
(
	select distinct 3, c.id, o.id from ifbl_2013 i
	left join nbgb_ifbl.people o on (o.family_name=i."Achternaam" and o.first_name= i."Voornaam") 
	left join nbgb_ifbl.areas a on (a.ifbl_code = i."IFBL")
	left join nbgb_ifbl.checklists c on (c.source_id=3 and c.area3_id = a.id and c.begin_date = i."BeginDatum"::date)
	where length("IFBL")=8
);
INSERT INTO nbgb_ifbl.observations (source_id, checklist_id, species_id)
(
	select distinct 3, c.id, s.id from ifbl_2013 i
	left join nbgb_ifbl.species s on (s.scientific_name=i."NaamWetenschappelijk") 
	left join nbgb_ifbl.areas a on ( a.ifbl_code = i."IFBL")
	left join nbgb_ifbl.checklists c on (c.source_id=3 and c.area3_id = a.id and c.begin_date = i."BeginDatum"::date)
	where length("IFBL")=8
);

Update nbgb_ifbl.checklists set observers= tmp.observers from (
	select checklist_id,
	array_to_string (array_accum((person.family_name || ' ' || person.first_name)::varchar::text), ', ') as observers
	from nbgb_ifbl.observers observer 
	join nbgb_ifbl.people person on person.id = observer.person_id
	where observer.source_id=3
	group by observer.checklist_id
) as tmp where id= tmp.checklist_id;


---IMPORT DATA from INBO Florabank Darwincore archive
INSERT INTO nbgb_ifbl.species (source_id,scientific_name)
(
	select distinct on (originalNameUsage) 3, originalNameUsage from inbo_dwca 
	where originalNameUsage not in (select scientific_name from nbgb_ifbl.species) order by originalNameUsage
); 

INSERT INTO nbgb_ifbl.areas (source_id, ifbl_code, toponym, latitude, longitude, uncertainty, coordinateSystem)
(
	select distinct on (verbatimCoordinates) 3, i.verbatimCoordinates, i.verbatimLocality, 
	s.lat,
	s.long, 
	i.coordinateUncertaintyInMeters, 
	i.verbatimCoordinateSystem from inbo_dwca i 
	left join ifbl_squares s on s.code = i.verbatimCoordinates
	where verbatimCoordinates not in (select ifbl_code from nbgb_ifbl.areas) order by verbatimCoordinates
);


INSERT INTO nbgb_ifbl.models (source_id, name)
(
	select distinct on (occurrenceDetails) 3,occurrenceDetails from inbo_dwca i 
	where occurrenceDetails not in (select name from nbgb_ifbl.models) order by occurrenceDetails
);

INSERT INTO nbgb_ifbl.checklists (source_id, area1_id, area2_id, area3_id, model_id, begin_date, end_date, observers)
(
	select distinct on 
	(verbatimCoordinates,eventDate) 3, a1.id, a2.id, a3.id, m.id, 
	to_date(split_part(eventdate, '/', 1), 'YYYY-MM-DD'), 
	to_date(split_part(eventdate, '/', 2), 'YYYY-MM-DD'),
	recordedBy
	from inbo_dwca i 
	left join nbgb_ifbl.models m on m.name = occurrenceDetails
	left join nbgb_ifbl.areas a1 on a1.ifbl_code = substr(verbatimCoordinates,1,2)
	left join nbgb_ifbl.areas a2 on a2.ifbl_code = substr(verbatimCoordinates,1,5)
	left join nbgb_ifbl.areas a3 on a3.ifbl_code = verbatimCoordinates	order by verbatimCoordinates,eventDate
);
INSERT INTO nbgb_ifbl.observations (source_id, original_id, checklist_id, species_id)
(
	select distinct 3, catalogNumber, c.id, s.id from inbo_dwca i
	left join nbgb_ifbl.species s on (s.scientific_name=originalNameUsage) 
	left join nbgb_ifbl.areas a on (a.ifbl_code = verbatimCoordinates)
	left join nbgb_ifbl.checklists c on (c.area3_id = a.id and c.begin_date = 	to_date(split_part(eventdate, '/', 1), 'YYYY-MM-DD'))
	where length(verbatimCoordinates)=8 
	union
	select distinct 3, catalogNumber, c.id, s.id from inbo_dwca i
	left join nbgb_ifbl.species s on (s.scientific_name=originalNameUsage) 
	left join nbgb_ifbl.areas a on (a.ifbl_code = verbatimCoordinates)
	left join nbgb_ifbl.checklists c on (c.area2_id = a.id and c.begin_date = 	to_date(split_part(eventdate, '/', 1), 'YYYY-MM-DD'))
	where length(verbatimCoordinates)=5	
);

--duplicates
select distinct on (scientificName, verbatimCoordinates, eventDate)
scientificName, verbatimCoordinates, eventDate, count (*) as count,
array_to_string (array_accum(catalognumber::varchar::text), ', ') as ids from inbo_dwca
group by scientificName, verbatimCoordinates, eventDate ;