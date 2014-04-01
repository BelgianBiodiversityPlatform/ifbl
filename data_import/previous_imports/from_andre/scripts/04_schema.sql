--- DROP schema nbgb_ifbl CASCADE;
create schema nbgb_ifbl;

-- DROP TABLE nbgb_ifbl.sources CASCADE;
create table nbgb_ifbl.sources(
	id 				serial primary key,
	name 			varchar(256),
	institutionCode	varchar(8),
	collectionCode	varchar(8),
	lastUpdate		date
);

-- DROP TABLE nbgb_ifbl.people CASCADE;
create table nbgb_ifbl.people(
	id 					serial primary key,
	source_id			integer references nbgb_ifbl.sources,
	family_name 		varchar(256),
	first_name			varchar(256)
);

-- DROP TABLE nbgb_ifbl.species CASCADE;
create table nbgb_ifbl.species(
	id 					serial primary key,
	source_id			integer references nbgb_ifbl.sources,
	scientific_name		varchar(256) unique, --- full scientific name
	fr_name				varchar(256),  --- french vernacular name 
	en_name				varchar(256), --- english vernacular name 
	nl_name				varchar(256)  --- dutch vernacular name 
);

-- DROP TABLE nbgb_ifbl.areas CASCADE;
create table nbgb_ifbl.areas(
	id 				serial primary key,
	source_id		integer references nbgb_ifbl.sources,
	ifbl_code		varchar(8) unique, --- format is 'A9-99-99' (1x1km) or 'A9-99' (4x4km) or 'A9' (32x20km)
	toponym			varchar(256),
	latitude		float,
	longitude		float,
	uncertainty		integer,
	coordinateSystem	varchar(8),
	b_region		boolean, --- within Brussels region
	f_region		boolean, --- within Flamish region
	w_region		boolean  --- within Walloon region
);

-- DROP TABLE nbgb_ifbl.models CASCADE;
create table nbgb_ifbl.models(
	id 				serial primary key,
	source_id		integer references nbgb_ifbl.sources,
	name			varchar(64) --- checklist model used
);

-- DROP TABLE nbgb_ifbl.checklists CASCADE;
create table nbgb_ifbl.checklists(
	id 				serial primary key,
	source_id		integer references nbgb_ifbl.sources,
	area1_id		integer references nbgb_ifbl.areas, --- 32x20 km eg 'H6'
	area2_id		integer references nbgb_ifbl.areas, --- 4x4 km eg 'H6-35'
	area3_id		integer references nbgb_ifbl.areas, --- 1x1 km eg 'H6-35-14'
	model_id		integer references nbgb_ifbl.models, --- checklist model used
	begin_date		date, --- checklist date
	end_date		date, --- checklist date
	observers		varchar(512) --- list of observers for this checklist
);

-- DROP TABLE nbgb_ifbl.observers CASCADE;
create table nbgb_ifbl.observers(--- observer(s) responsible for checklist
	source_id		integer references nbgb_ifbl.sources,
	checklist_id 	integer references nbgb_ifbl.checklists,
	person_id		integer references nbgb_ifbl.people
);

-- DROP TABLE nbgb_ifbl.observations CASCADE;
create table nbgb_ifbl.observations(--- species presence on checklist
	id		serial primary key,
	source_id		integer references nbgb_ifbl.sources,
	original_id		integer, --as given by data owner
	checklist_id 	integer references nbgb_ifbl.checklists,
	species_id		integer references nbgb_ifbl.species
);