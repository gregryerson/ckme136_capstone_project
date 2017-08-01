-- create similar field to clean_address for parking tickets that were administered at an approximate intersection
-- i.e lcation1 = @, location 2 =  COVINGTON RD, location 4 = BRUCEWOOD CRES, clean_intersection = COVINGTON RD & BRUCEWOOD CRES
-- 1,136,873 rows updated

ALTER TABLE parking_dataset
ADD COLUMN clean_intersection varchar(255);

-- begin cleaning 
UPDATE parking_dataset
SET clean_intersection = location2 || ' & ' || location4
WHERE clean_address IS NULL AND location2 IS NOT NULL AND loc2_has_num = FALSE AND location4 IS NOT NULL AND loc4_has_num = FALSE;

-- following same steps as step4_parking_tickets_clean_address.sql file
-- each street within the intersection needs to be cleaned separately
ALTER TABLE parking_dataset
ADD COLUMN int1_clean_address varchar(255);

-- parse first address from intersection field
-- i.e. JANE ST & DUNDAS ST W = JANE ST
UPDATE parking_dataset
SET int1_clean_address = LEFT(clean_intersection, STRPOS(clean_intersection, ' & ') -1)
WHERE clean_intersection IS NOT NULL;

ALTER TABLE parking_dataset
ADD COLUMN int1_street_name_clean varchar(255);

UPDATE parking_dataset
SET int1_street_name_clean = (CASE WHEN int1_clean_address LIKE '% REDPATHA V' THEN 'REDPATH'
WHEN int1_clean_address LIKE '%ST CLAIR' THEN 'ST CLAIR'
WHEN int1_clean_address LIKE '%ST CLAIR%' THEN 'ST CLAIR'
WHEN int1_clean_address LIKE '%LAWRENCE%' THEN 'LAWRENCE'
WHEN int1_clean_address LIKE '%EGLINTON' THEN 'EGLINTON'
WHEN int1_clean_address LIKE '% AV EAST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, 'AV EAST') - 2)
WHEN int1_clean_address LIKE '% AV WEST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, 'AV WEST') - 2)
WHEN int1_clean_address LIKE '% AV E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, 'AV E') - 2)
WHEN int1_clean_address LIKE '% AV W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, 'AV W') - 2)
WHEN int1_clean_address LIKE '% A' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' A') - 1)
WHEN int1_clean_address LIKE '% AV%' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, 'AVE') - 2)
WHEN int1_clean_address LIKE '% AV' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, 'AV') - 2)
WHEN int1_clean_address LIKE '% AV%E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, 'AV E') - 2)
WHEN int1_clean_address LIKE '% AV%W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, 'AV E') - 2)
WHEN int1_clean_address LIKE '% AVE.' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE.') - 1)
WHEN int1_clean_address LIKE '% AVE N' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE N') - 1)
WHEN int1_clean_address LIKE '% AVE E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE E') - 1)
WHEN int1_clean_address LIKE '% AVE S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE S') - 1)
WHEN int1_clean_address LIKE '% AVE W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE W') - 1)
WHEN int1_clean_address LIKE '% AV' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AV') - 1)
WHEN int1_clean_address LIKE '% AV E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AV E') - 1)
WHEN int1_clean_address LIKE '% AV W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AV W') - 1)
WHEN int1_clean_address LIKE '% AV WEST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AV WEST') - 1)
WHEN int1_clean_address LIKE '% AVE. W.' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE. W.') - 1)
WHEN int1_clean_address LIKE '% AVENUE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVENUE') - 1)
WHEN int1_clean_address LIKE '% AVENUE WEST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVENUE WEST') - 1)
WHEN int1_clean_address LIKE '% AVE WEST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE WEST') - 1)
WHEN int1_clean_address LIKE '% AVE   W/S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE   W/S') - 1)
WHEN int1_clean_address LIKE '% VE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' VE') - 1)
WHEN int1_clean_address LIKE '% AVE UN 101' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE UN 101') - 1)
WHEN int1_clean_address LIKE '% AVE UN 102' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE UN 102') - 1)
WHEN int1_clean_address LIKE '% AVR' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVR') - 1)
WHEN int1_clean_address LIKE '% AVE N/S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE N/S') - 1)
WHEN int1_clean_address LIKE '% AV EAST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AV EAST') - 1)
WHEN int1_clean_address LIKE '% AVE EAST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE EAST') - 1)
WHEN int1_clean_address LIKE '% VE E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' VE E') - 1)
WHEN int1_clean_address LIKE '% AV --16' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AV --16') - 1)
WHEN int1_clean_address LIKE '% AV UNIT --1 ' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AV UNIT --1 ') - 1)
WHEN int1_clean_address LIKE '% AV UNIT --31' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AV UNIT --31') - 1)
WHEN int1_clean_address LIKE '% AVE UN 25' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE UN 25') - 1)
WHEN int1_clean_address LIKE '% VAE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' VAE') - 1)
WHEN int1_clean_address LIKE '% AVE LINE.' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE LINE.') - 1)
WHEN int1_clean_address LIKE '% AVE  E--2' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE  E--2') - 1)
WHEN int1_clean_address LIKE '% AVE GARAGE --31' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE GARAGE --31') - 1)
WHEN int1_clean_address LIKE '% FINCHAV W ' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' FINCHAV W ') - 1)
WHEN int1_clean_address LIKE '% AVEE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVEE') - 1)
WHEN int1_clean_address LIKE '% AE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AE') - 1)
WHEN int1_clean_address LIKE '% AVE3' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE3') - 1)
WHEN int1_clean_address LIKE '% AVE3' THEN 'DANFORTH'
WHEN int1_clean_address LIKE '%  DANFORTHA V' THEN 'PROGRESS'
WHEN int1_clean_address LIKE '% PROGRESS AE' THEN 'EGLINTON'
WHEN int1_clean_address LIKE '% EGLINTON W' THEN 'SHEPPARD'
WHEN int1_clean_address LIKE '% SHEPPARD WEST' THEN 'SHEPPARD'
WHEN int1_clean_address LIKE '% V W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' V W') - 1)
WHEN int1_clean_address LIKE '% AV % 34' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AV % 34') - 1)
WHEN int1_clean_address LIKE '% AV % 34' THEN 'CLARENDON'
WHEN int1_clean_address LIKE '% AVENUE W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVENUE W') - 1)
WHEN int1_clean_address LIKE '% AVE. W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE. W') - 1)
WHEN int1_clean_address LIKE '% A V' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' A V') - 1)
WHEN int1_clean_address LIKE '% A VW' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' A VW') - 1)
WHEN int1_clean_address LIKE '% AE W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AE W') - 1)
WHEN int1_clean_address LIKE '% AVE. W ' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE. W ') - 1)
WHEN int1_clean_address LIKE '% AVE.W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE.W') - 1)
WHEN int1_clean_address LIKE '% AVE.W.' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE.W.') - 1)
WHEN int1_clean_address LIKE '% VE W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' VE W') - 1)
WHEN int1_clean_address LIKE '% VE W' THEN 'SHEPPARD'
WHEN int1_clean_address LIKE '% AVENUE EAST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVENUE EAST') - 1)
WHEN int1_clean_address LIKE '% AVENUE E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVENUE E') - 1)
WHEN int1_clean_address LIKE '% AVE W  NR 5' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE W  NR 5') - 1)
WHEN int1_clean_address LIKE '% AVE W  NR 8' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE W  NR 8') - 1)
WHEN int1_clean_address LIKE '% AVE W NR 22' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE W NR 22') - 1)
WHEN int1_clean_address LIKE '% AVE W NR 22' THEN 'PHARMACY'
WHEN int1_clean_address LIKE '% AEV' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AEV') - 1)
WHEN int1_clean_address LIKE '% AEV' THEN 'BENSON'
WHEN int1_clean_address LIKE '% BENSONA V' THEN 'LAWRENCE'
WHEN int1_clean_address LIKE '% LAWRENCE W' THEN 'BISHOP'
WHEN int1_clean_address LIKE '% BISHOPA V' THEN 'JEFFERSON'
WHEN int1_clean_address LIKE '% JEFFERSONA V' THEN 'FRASER'
WHEN int1_clean_address LIKE '% FRASERAV' THEN 'LAWRENCE'
WHEN int1_clean_address LIKE '% LAWRENCEAV W' THEN 'HANNA'
WHEN int1_clean_address LIKE '% AVE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' AVE') - 1)
WHEN int1_clean_address LIKE '% BYWY' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BYWY') - 1)
WHEN int1_clean_address LIKE '% BYWY' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BL N' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD NORTH' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD UNIT --63' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD UNIT --63') - 1)
WHEN int1_clean_address LIKE '% BLVD UNIT --62' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD UNIT --62') - 1)
WHEN int1_clean_address LIKE '% BLVD UNIT --46' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD UNIT --46') - 1)
WHEN int1_clean_address LIKE '% BLVD UNIT --48' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD UNIT --48') - 1)
WHEN int1_clean_address LIKE '% BLVD UNIT --41' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD UNIT --41') - 1)
WHEN int1_clean_address LIKE '% BLVD UNIT --38' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD UNIT --38') - 1)
WHEN int1_clean_address LIKE '% BLVD UNIT --32' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD UNIT --32') - 1)
WHEN int1_clean_address LIKE '% BLVD UNIT --61' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD UNIT --61') - 1)
WHEN int1_clean_address LIKE '% BVD' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BVD') - 1)
WHEN int1_clean_address LIKE '% BOULEVARD WEST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BOULEVARD WEST') - 1)
WHEN int1_clean_address LIKE '% BLVF W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVF W') - 1)
WHEN int1_clean_address LIKE '% BLVD. W.' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD. W.') - 1)
WHEN int1_clean_address LIKE '% BLDV' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLDV') - 1)
WHEN int1_clean_address LIKE '% LBLVD W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' LBLVD W') - 1)
WHEN int1_clean_address LIKE '% BLV W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLV W') - 1)
WHEN int1_clean_address LIKE '% BLVD --33' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD --33') - 1)
WHEN int1_clean_address LIKE '% LBVD W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' LBVD W') - 1)
WHEN int1_clean_address LIKE '% BLV' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLV') - 1)
WHEN int1_clean_address LIKE '% BL' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BL') - 1)
WHEN int1_clean_address LIKE '% BL W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BL W') - 1)
WHEN int1_clean_address LIKE '% BLVD.' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD.') - 1)
WHEN int1_clean_address LIKE '% BVLD' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BVLD') - 1)
WHEN int1_clean_address LIKE '% BLVD' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD') - 1)
WHEN int1_clean_address LIKE '% BLVD N' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD N') - 1)
WHEN int1_clean_address LIKE '% BLVD E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD E') - 1)
WHEN int1_clean_address LIKE '% BLVD S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD S') - 1)
WHEN int1_clean_address LIKE '% BLVD SOUTH' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD SOUTH') - 1)
WHEN int1_clean_address LIKE '% BLVD W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD W') - 1)
WHEN int1_clean_address LIKE '% BLVD WEST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD WEST') - 1)
WHEN int1_clean_address LIKE '% BL NR%' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BL NR%') - 1)
WHEN int1_clean_address LIKE '% BLVD UNIT --36' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD UNIT --36') - 1)
WHEN int1_clean_address LIKE '% BLVD UNIT --69' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BLVD UNIT --69') - 1)
WHEN int1_clean_address LIKE '% BL UN 32' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' BL UN 32') - 1)
WHEN int1_clean_address LIKE '% CIR' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CIR') - 1)
WHEN int1_clean_address LIKE '% CIRCLE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CIRCLE') - 1)
WHEN int1_clean_address LIKE '% CRCL' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRCL') - 1)
WHEN int1_clean_address LIKE '% CIRT' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CIRT') - 1)
WHEN int1_clean_address LIKE '% CIRCUIT' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CIRCUIT') - 1)
WHEN int1_clean_address LIKE '% CRCT' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRCT') - 1)
WHEN int1_clean_address LIKE '% CRESENT' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRESENT') - 1)
WHEN int1_clean_address LIKE '% CRES.' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRES.') - 1)
WHEN int1_clean_address LIKE '% CRE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRE') - 1)
WHEN int1_clean_address LIKE '% CR' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CR') - 1)
WHEN int1_clean_address LIKE '% CRESCENT' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRESCENT') - 1)
WHEN int1_clean_address LIKE '% CRES' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRES') - 1)
WHEN int1_clean_address LIKE '% CRES N' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRES N') - 1)
WHEN int1_clean_address LIKE '% CRES E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRES E') - 1)
WHEN int1_clean_address LIKE '% CRES S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRES S') - 1)
WHEN int1_clean_address LIKE '% CRES W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRES W') - 1)
WHEN int1_clean_address LIKE '% CRS' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRS') - 1)
WHEN int1_clean_address LIKE '% CREST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CREST') - 1)
WHEN int1_clean_address LIKE '% CT.' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CT.') - 1)
WHEN int1_clean_address LIKE '% COURT' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' COURT') - 1)
WHEN int1_clean_address LIKE '% CRT.' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRT.') - 1)
WHEN int1_clean_address LIKE '% CRT' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRT') - 1)
WHEN int1_clean_address LIKE '% CRT N' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRT N') - 1)
WHEN int1_clean_address LIKE '% CRT E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRT E') - 1)
WHEN int1_clean_address LIKE '% CRT S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRT S') - 1)
WHEN int1_clean_address LIKE '% CRT W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CRT W') - 1)
WHEN int1_clean_address LIKE '% CS' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CS') - 1)
WHEN int1_clean_address LIKE '% CT' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' CT') - 1)
WHEN int1_clean_address LIKE '% DR.' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' DR.') - 1)
WHEN int1_clean_address LIKE '% DRIVE  S/S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' DRIVE  S/S') - 1)
WHEN int1_clean_address LIKE '% DR W/S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' DR W/S') - 1)
WHEN int1_clean_address LIKE '% DRIVE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' DRIVE') - 1)
WHEN int1_clean_address LIKE '% DR' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' DR') - 1)
WHEN int1_clean_address LIKE '% DR N' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' DR N') - 1)
WHEN int1_clean_address LIKE '% DR E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' DR E') - 1)
WHEN int1_clean_address LIKE '% DR S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' DR S') - 1)
WHEN int1_clean_address LIKE '% DR W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' DR W') - 1)
WHEN int1_clean_address LIKE '% DR N/S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' DR N/S') - 1)
WHEN int1_clean_address LIKE '% DR S/S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' DR S/S') - 1)
WHEN int1_clean_address LIKE '% DRV' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' DRV') - 1)
WHEN int1_clean_address LIKE '% GDN' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' GDN') - 1)
WHEN int1_clean_address LIKE '% GARDENS' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' GARDENS') - 1)
WHEN int1_clean_address LIKE '% GRDNS' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' GRDNS') - 1)
WHEN int1_clean_address LIKE '% GDNS' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' GDNS') - 1)
WHEN int1_clean_address LIKE '% GRN' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' GRN') - 1)
WHEN int1_clean_address LIKE '% GR' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' GR') - 1)
WHEN int1_clean_address LIKE '% GRV' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' GRV') - 1)
WHEN int1_clean_address LIKE '% GROVE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' GROVE') - 1)
WHEN int1_clean_address LIKE '% GATE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' GATE') - 1)
WHEN int1_clean_address LIKE '% GT' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' GT') - 1)
WHEN int1_clean_address LIKE '% HILL' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' HILL') - 1)
WHEN int1_clean_address LIKE '% HILLS' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' HILLS') - 1)
WHEN int1_clean_address LIKE '% HILL S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' HILL S') - 1)
WHEN int1_clean_address LIKE '% HILL N' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' HILL N') - 1)
WHEN int1_clean_address LIKE '% HEIGHTS' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' HEIGHTS') - 1)
WHEN int1_clean_address LIKE '% HTS' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' HTS') - 1)
WHEN int1_clean_address LIKE '% KEEP' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' KEEP') - 1)
WHEN int1_clean_address LIKE '% LN' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' LN') - 1)
WHEN int1_clean_address LIKE '% LA' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' LA') - 1)
WHEN int1_clean_address LIKE '% LANE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' LANE') - 1)
WHEN int1_clean_address LIKE '% LANEWAY' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' LANEWAY') - 1)
WHEN int1_clean_address LIKE '% LINE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' LINE') - 1)
WHEN int1_clean_address LIKE '% LWN' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' LWN') - 1)
WHEN int1_clean_address LIKE '% MEWS' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' MEWS') - 1)
WHEN int1_clean_address LIKE '% PATH' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' PATH') - 1)
WHEN int1_clean_address LIKE '% PATHWAY' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' PATHWAY') - 1)
WHEN int1_clean_address LIKE '% PARK' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' PARK') - 1)
WHEN int1_clean_address LIKE '% PK' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' PK') - 1)
WHEN int1_clean_address LIKE '% PKWY' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' PKWY') - 1)
WHEN int1_clean_address LIKE '% PLACE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' PLACE') - 1)
WHEN int1_clean_address LIKE '% PL' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' PL') - 1)
WHEN int1_clean_address LIKE '% PTWY' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' PTWY') - 1)
WHEN int1_clean_address LIKE '% PTY' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' PTY') - 1)
WHEN int1_clean_address LIKE '% QUAY' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' QUAY') - 1)
WHEN int1_clean_address LIKE '% QUAY E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' QUAY E') - 1)
WHEN int1_clean_address LIKE '% QUAY W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' QUAY W') - 1)
WHEN int1_clean_address LIKE '% ROAD' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ROAD') - 1)
WHEN int1_clean_address LIKE '% HILLR D' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' HILLR D') - 1)
WHEN int1_clean_address LIKE '% RD  E/S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD  E/S') - 1)
WHEN int1_clean_address LIKE '% RD' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD') - 1)
WHEN int1_clean_address LIKE '% RD.' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD.') - 1)
WHEN int1_clean_address LIKE '% RD N' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD N') - 1)
WHEN int1_clean_address LIKE '% RD E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD E') - 1)
WHEN int1_clean_address LIKE '% RD S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD S') - 1)
WHEN int1_clean_address LIKE '% RD W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD W') - 1)
WHEN int1_clean_address LIKE '% RD SB' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD SB') - 1)
WHEN int1_clean_address LIKE '% RD  --2' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD  --2') - 1)
WHEN int1_clean_address LIKE '% RD  --4' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD  --4') - 1)
WHEN int1_clean_address LIKE '% RD  --90' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD  --90') - 1)
WHEN int1_clean_address LIKE '% RAOD' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RAOD') - 1)
WHEN int1_clean_address LIKE '% RD ES' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD ES') - 1)
WHEN int1_clean_address LIKE '% RD W/S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD W/S') - 1)
WHEN int1_clean_address LIKE '% R' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' R') - 1)
WHEN int1_clean_address LIKE '% R' THEN 'KINGSTON'
WHEN int1_clean_address LIKE '% KINGSTONR D' THEN 'MCCOWAN'
WHEN int1_clean_address LIKE '% MCCOWNR D' THEN 'WESTON'
WHEN int1_clean_address LIKE '% WESTONR D ' THEN 'KENNEDY'
WHEN int1_clean_address LIKE '% RD SPOT 56' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD SPOT 56') - 1)
WHEN int1_clean_address LIKE '% RD SPOT 56' THEN 'LLOYD MANOR'
WHEN int1_clean_address LIKE '% LLOYD MANOR D' THEN 'SENTINEL'
WHEN int1_clean_address LIKE '% SENTINELLR D ' THEN 'DON MILLS'
WHEN int1_clean_address LIKE '% DON MILLS D' THEN 'DON MILLS'
WHEN int1_clean_address LIKE '% DON MILLS RD 3' THEN 'DON MILLS'
WHEN int1_clean_address LIKE '% DON MILLSR D' THEN 'DON MILLS'
WHEN int1_clean_address LIKE '% DON MILL SRD' THEN 'DON MILLS'
WHEN int1_clean_address LIKE '% DON MILLSR D' THEN 'KENNEDY'
WHEN int1_clean_address LIKE '% KENNEDYR D' THEN 'WESTON'
WHEN int1_clean_address LIKE '% RD%3' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD%3') - 1)
WHEN int1_clean_address LIKE '% RD%3' THEN 'MARKHAM'
WHEN int1_clean_address LIKE '% SQUARE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' SQUARE') - 1)
WHEN int1_clean_address LIKE '% RD N%S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' RD N%S') - 1)
WHEN int1_clean_address LIKE '% RD N%S' THEN 'WESTON'
WHEN int1_clean_address LIKE '% SQ' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' SQ') - 1)
WHEN int1_clean_address LIKE '% SQ N' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' SQ N') - 1)
WHEN int1_clean_address LIKE '% SQ E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' SQ E') - 1)
WHEN int1_clean_address LIKE '% SQ S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' SQ S') - 1)
WHEN int1_clean_address LIKE '% SQ W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' SQ W') - 1)
WHEN int1_clean_address LIKE '% SQ W' THEN 'YONGE'
WHEN int1_clean_address LIKE '% YONGE T' THEN 'YONGE'
WHEN int1_clean_address LIKE '% YONGES T' THEN 'HURON'
WHEN int1_clean_address LIKE '% ST W%S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST W%S') - 1)
WHEN int1_clean_address LIKE '% ST. EAST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST. EAST') - 1)
WHEN int1_clean_address LIKE '% S E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' S E') - 1)
WHEN int1_clean_address LIKE '% S E' THEN 'HOLLY'
WHEN int1_clean_address LIKE '% ST BACKLOT' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST BACKLOT') - 1)
WHEN int1_clean_address LIKE '% ST BACKLOT' THEN 'ELIZABETH'
WHEN int1_clean_address LIKE '% ST F' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST F') - 1)
WHEN int1_clean_address LIKE '% S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' S') - 1)
WHEN int1_clean_address LIKE '% STE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' STE') - 1)
WHEN int1_clean_address LIKE '% S TW' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' S TW') - 1)
WHEN int1_clean_address LIKE '% ST.' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST.') - 1)
WHEN int1_clean_address LIKE '% ST. E.' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST. E.') - 1)
WHEN int1_clean_address LIKE '% ST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST') - 1)
WHEN int1_clean_address LIKE '% ST N' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST N') - 1)
WHEN int1_clean_address LIKE '% ST E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST E') - 1)
WHEN int1_clean_address LIKE '% ST EAST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST EAST') - 1)
WHEN int1_clean_address LIKE '% ST WEST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST WEST') - 1)
WHEN int1_clean_address LIKE '% ST S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST S') - 1)
WHEN int1_clean_address LIKE '% ST W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST W') - 1)
WHEN int1_clean_address LIKE '% ST. W.' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST. W.') - 1)
WHEN int1_clean_address LIKE '% STREET WEST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' STREET WEST') - 1)
WHEN int1_clean_address LIKE '% STREET' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' STREET') - 1)
WHEN int1_clean_address LIKE '% S TE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' S TE') - 1)
WHEN int1_clean_address LIKE '% ST W N/S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST W N/S') - 1)
WHEN int1_clean_address LIKE '% S W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' S W') - 1)
WHEN int1_clean_address LIKE '% ST WS' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST WS') - 1)
WHEN int1_clean_address LIKE '% STREET W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' STREET W') - 1)
WHEN int1_clean_address LIKE '% STREET W' THEN 'KING'
WHEN int1_clean_address LIKE '% KINGS T E' THEN 'KING'
WHEN int1_clean_address LIKE '% T W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' T W') - 1)
WHEN int1_clean_address LIKE '% ST E/S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST E/S') - 1)
WHEN int1_clean_address LIKE '% ST E/S' THEN 'SUMACH'
WHEN int1_clean_address LIKE '% SST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' SST') - 1)
WHEN int1_clean_address LIKE '% ST ES' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST ES') - 1)
WHEN int1_clean_address LIKE '% ST W NS' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST W NS') - 1)
WHEN int1_clean_address LIKE '% ST N/S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST N/S') - 1)
WHEN int1_clean_address LIKE '% STREET EAST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' STREET EAST') - 1)
WHEN int1_clean_address LIKE '% STR' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' STR') - 1)
WHEN int1_clean_address LIKE '% ST  W' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST  W') - 1)
WHEN int1_clean_address LIKE '% ST  W' THEN 'SPADINA'
WHEN int1_clean_address LIKE '% STREET E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' STREET E') - 1)
WHEN int1_clean_address LIKE '% STREET E' THEN 'BLOOR'
WHEN int1_clean_address LIKE '% BLOORST W' THEN 'YONGE'
WHEN int1_clean_address LIKE '% STREET   N3-03 - N3-04' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' STREET   N3-03 - N3-04') - 1)
WHEN int1_clean_address LIKE '% ST  E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST  E') - 1)
WHEN int1_clean_address LIKE '% ST E%B' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST E%B') - 1)
WHEN int1_clean_address LIKE '% ST E%B' THEN 'MERTON'
WHEN int1_clean_address LIKE '% ST 3' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST 3') - 1)
WHEN int1_clean_address LIKE '% ST 3' THEN 'SHERBOURNE'
WHEN int1_clean_address LIKE '% SHERBOURNE T' THEN 'WELLESLEY'
WHEN int1_clean_address LIKE '% ST. E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST. E') - 1)
WHEN int1_clean_address LIKE '% T E' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' T E') - 1)
WHEN int1_clean_address LIKE '% ST W %' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST W %') - 1)
WHEN int1_clean_address LIKE '% STW' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' STW') - 1)
WHEN int1_clean_address LIKE '% STW' THEN 'QUEEN'
WHEN int1_clean_address LIKE '% ST. EAST' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST. EAST') - 1)
WHEN int1_clean_address LIKE '% ST W%S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST W%S') - 1)
WHEN int1_clean_address LIKE '% ST S%S' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST S%S') - 1)
WHEN int1_clean_address LIKE '% ST S%S' THEN 'ELIZABETH'
WHEN int1_clean_address LIKE '% ST --114' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' ST --114') - 1)
WHEN int1_clean_address LIKE '% TERRACE' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' TERRACE') - 1)
WHEN int1_clean_address LIKE '% TERR' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' TERR') - 1)
WHEN int1_clean_address LIKE '% TER' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' TER') - 1)
WHEN int1_clean_address LIKE '% TRAIL' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' TRAIL') - 1)
WHEN int1_clean_address LIKE '% TRL' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' TRL') - 1)
WHEN int1_clean_address LIKE '% TR' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' TR') - 1)
WHEN int1_clean_address LIKE '% WALK' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' WALK') - 1)
WHEN int1_clean_address LIKE '% WAY --75' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' WAY --75') - 1)
WHEN int1_clean_address LIKE '% WAY' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' WAY') - 1)
WHEN int1_clean_address LIKE '% WAY  TH --4' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' WAY  TH --4') - 1)
WHEN int1_clean_address LIKE '% WDS' THEN LEFT(int1_clean_address, STRPOS(int1_clean_address, ' WDS') - 1)
ELSE NULL END)
WHERE clean_intersection IS NOT NULL;

-- street type
ALTER TABLE parking_dataset
ADD COLUMN int1_street_type varchar(25);

UPDATE parking_dataset
SET int1_street_type = (CASE WHEN int1_clean_address LIKE '% AVE' THEN 'AVE'
WHEN int1_clean_address LIKE '% REDPATHA V' THEN 'AVE'
WHEN int1_clean_address LIKE '% A' THEN 'AVE'
WHEN int1_clean_address LIKE '% AV%' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE.' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE N' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE E' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE S' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE W' THEN 'AVE'
WHEN int1_clean_address LIKE '% AV' THEN 'AVE'
WHEN int1_clean_address LIKE '% AV E' THEN 'AVE'
WHEN int1_clean_address LIKE '% AV W' THEN 'AVE'
WHEN int1_clean_address LIKE '% AV WEST' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE. W.' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVENUE' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVENUE WEST' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE WEST' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE   W/S' THEN 'AVE'
WHEN int1_clean_address LIKE '% VE' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE UN 101' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE UN 102' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVR' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE N/S' THEN 'AVE'
WHEN int1_clean_address LIKE '% AV EAST' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE EAST' THEN 'AVE'
WHEN int1_clean_address LIKE '% VE E' THEN 'AVE'
WHEN int1_clean_address LIKE '% AV --16' THEN 'AVE'
WHEN int1_clean_address LIKE '% AV UNIT --1 ' THEN 'AVE'
WHEN int1_clean_address LIKE '% AV UNIT --31' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE UN 25' THEN 'AVE'
WHEN int1_clean_address LIKE '% VAE' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE LINE.' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE  E--2' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE GARAGE --31' THEN 'AVE'
WHEN int1_clean_address LIKE '% FINCHAV W ' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVEE' THEN 'AVE'
WHEN int1_clean_address LIKE '% AE' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE3' THEN 'AVE'
WHEN int1_clean_address LIKE '%  DANFORTHA V' THEN 'AVE'
WHEN int1_clean_address LIKE '% PROGRESS AE' THEN 'AVE'
WHEN int1_clean_address LIKE '% EGLINTON W' THEN 'AVE'
WHEN int1_clean_address LIKE '% SHEPPARD WEST' THEN 'AVE'
WHEN int1_clean_address LIKE '% SHEPPARD E' THEN 'AVE'
WHEN int1_clean_address LIKE '% V W' THEN 'AVE'
WHEN int1_clean_address LIKE '% AV % 34' THEN 'AVE'
WHEN int1_clean_address LIKE '% CLARENDONA V' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVENUE W' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE. W' THEN 'AVE'
WHEN int1_clean_address LIKE '% A V' THEN 'AVE'
WHEN int1_clean_address LIKE '% A VW' THEN 'AVE'
WHEN int1_clean_address LIKE '% AE W' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE. W ' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE.W' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE.W.' THEN 'AVE'
WHEN int1_clean_address LIKE '% VE W' THEN 'AVE'
WHEN int1_clean_address LIKE '% SHEPPARDAV W' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVENUE EAST' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVENUE E' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE W  NR 5' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE W  NR 8' THEN 'AVE'
WHEN int1_clean_address LIKE '% AVE W NR 22' THEN 'AVE'
WHEN int1_clean_address LIKE '% PHARMACYA V' THEN 'AVE'
WHEN int1_clean_address LIKE '% AEV' THEN 'AVE'
WHEN int1_clean_address LIKE '% BENSONA V' THEN 'AVE'
WHEN int1_clean_address LIKE '% LAWRENCE W' THEN 'AVE'
WHEN int1_clean_address LIKE '% BISHOPA V' THEN 'AVE'
WHEN int1_clean_address LIKE '% JEFFERSONA V' THEN 'AVE'
WHEN int1_clean_address LIKE '% FRASERAV' THEN 'AVE'
WHEN int1_clean_address LIKE '% LAWRENCEAV W' THEN 'AVE'
WHEN int1_clean_address LIKE '% HANNAA V' THEN 'AVE'
WHEN int1_clean_address LIKE '% BAGNATO' THEN 'BAGNATO'
WHEN int1_clean_address LIKE '% BYWY' THEN 'BYWAY'
WHEN int1_clean_address LIKE '% BL N' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD NORTH' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD UNIT --64' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD UNIT --63' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD UNIT --62' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD UNIT --46' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD UNIT --48' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD UNIT --41' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD UNIT --38' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD UNIT --32' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD UNIT --61' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BVD' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BOULEVARD WEST' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVF W' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD. W.' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLDV' THEN 'BLVD'
WHEN int1_clean_address LIKE '% LBLVD W' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLV W' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD --33' THEN 'BLVD'
WHEN int1_clean_address LIKE '% LBVD W' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLV' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BL' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BL W' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD.' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BVLD' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD N' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD E' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD S' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD SOUTH' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD W' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD WEST' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BL NR%' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD UNIT --36' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BLVD UNIT --69' THEN 'BLVD'
WHEN int1_clean_address LIKE '% BL UN 32' THEN 'BLVD'
WHEN int1_clean_address LIKE '% CIR' THEN 'CRCL'
WHEN int1_clean_address LIKE '% CIRCLE' THEN 'CRCL'
WHEN int1_clean_address LIKE '% CRCL' THEN 'CRCL'
WHEN int1_clean_address LIKE '% CIRT' THEN 'CRCT'
WHEN int1_clean_address LIKE '% CIRCUIT' THEN 'CRCT'
WHEN int1_clean_address LIKE '% CRCT' THEN 'CRCT'
WHEN int1_clean_address LIKE '% CRESENT' THEN 'CRES'
WHEN int1_clean_address LIKE '% CRES.' THEN 'CRES'
WHEN int1_clean_address LIKE '% CRE' THEN 'CRES'
WHEN int1_clean_address LIKE '% CR' THEN 'CRES'
WHEN int1_clean_address LIKE '% CRESCENT' THEN 'CRES'
WHEN int1_clean_address LIKE '% CRES' THEN 'CRES'
WHEN int1_clean_address LIKE '% CRES N' THEN 'CRES'
WHEN int1_clean_address LIKE '% CRES E' THEN 'CRES'
WHEN int1_clean_address LIKE '% CRES S' THEN 'CRES'
WHEN int1_clean_address LIKE '% CRES W' THEN 'CRES'
WHEN int1_clean_address LIKE '% CRS' THEN 'CRES'
WHEN int1_clean_address LIKE '% CREST' THEN 'CRES'
WHEN int1_clean_address LIKE '% CT.' THEN 'CRT'
WHEN int1_clean_address LIKE '% COURT' THEN 'CRT'
WHEN int1_clean_address LIKE '% CRT.' THEN 'CRT'
WHEN int1_clean_address LIKE '% CRT' THEN 'CRT'
WHEN int1_clean_address LIKE '% CRT N' THEN 'CRT'
WHEN int1_clean_address LIKE '% CRT E' THEN 'CRT'
WHEN int1_clean_address LIKE '% CRT S' THEN 'CRT'
WHEN int1_clean_address LIKE '% CRT W' THEN 'CRT'
WHEN int1_clean_address LIKE '% CS' THEN 'CS'
WHEN int1_clean_address LIKE '% CT' THEN 'CRT'
WHEN int1_clean_address LIKE '% DR.' THEN 'DR'
WHEN int1_clean_address LIKE '% DRIVE  S/S' THEN 'DR'
WHEN int1_clean_address LIKE '% DR W/S' THEN 'DR'
WHEN int1_clean_address LIKE '% DRIVE' THEN 'DR'
WHEN int1_clean_address LIKE '% DR' THEN 'DR'
WHEN int1_clean_address LIKE '% DR N' THEN 'DR'
WHEN int1_clean_address LIKE '% DR E' THEN 'DR'
WHEN int1_clean_address LIKE '% DR S' THEN 'DR'
WHEN int1_clean_address LIKE '% DR W' THEN 'DR'
WHEN int1_clean_address LIKE '% DR N/S' THEN 'DR'
WHEN int1_clean_address LIKE '% DR S/S' THEN 'DR'
WHEN int1_clean_address LIKE '% DRV' THEN 'DR'
WHEN int1_clean_address LIKE '% GDN' THEN 'GRN'
WHEN int1_clean_address LIKE '% GARDENS' THEN 'GDNS'
WHEN int1_clean_address LIKE '% GRDNS' THEN 'GDNS'
WHEN int1_clean_address LIKE '% GDNS' THEN 'GDNS'
WHEN int1_clean_address LIKE '% GRN' THEN 'GRN'
WHEN int1_clean_address LIKE '% GR' THEN 'GRV'
WHEN int1_clean_address LIKE '% GRV' THEN 'GRV'
WHEN int1_clean_address LIKE '% GROVE' THEN 'GRV'
WHEN int1_clean_address LIKE '% GATE' THEN 'GT'
WHEN int1_clean_address LIKE '% GT' THEN 'GT'
WHEN int1_clean_address LIKE '% HILL' THEN 'HILL'
WHEN int1_clean_address LIKE '% HILLS' THEN 'HILLS'
WHEN int1_clean_address LIKE '% HILL S' THEN 'HILL'
WHEN int1_clean_address LIKE '% HILL N' THEN 'HILL'
WHEN int1_clean_address LIKE '% HEIGHTS' THEN 'HTS'
WHEN int1_clean_address LIKE '% HTS' THEN 'HTS'
WHEN int1_clean_address LIKE '% KEEP' THEN 'KEEP'
WHEN int1_clean_address LIKE '% LN' THEN 'LANE'
WHEN int1_clean_address LIKE '% LA' THEN 'LANE'
WHEN int1_clean_address LIKE '% LANE' THEN 'LANE'
WHEN int1_clean_address LIKE '% LANEWAY' THEN 'LANEWAY'
WHEN int1_clean_address LIKE '% LINE' THEN 'LINE'
WHEN int1_clean_address LIKE '% LWN' THEN 'LWN'
WHEN int1_clean_address LIKE '% MEWS' THEN 'MEWS'
WHEN int1_clean_address LIKE '% PATH' THEN 'PATH'
WHEN int1_clean_address LIKE '% PATHWAY' THEN 'PATHWAY'
WHEN int1_clean_address LIKE '% PARK' THEN 'PK'
WHEN int1_clean_address LIKE '% PK' THEN 'PK'
WHEN int1_clean_address LIKE '% PKWY' THEN 'PKWY'
WHEN int1_clean_address LIKE '% PLACE' THEN 'PL'
WHEN int1_clean_address LIKE '% PL' THEN 'PL'
WHEN int1_clean_address LIKE '% PTWY' THEN 'PTWY'
WHEN int1_clean_address LIKE '% PTY' THEN 'PTY'
WHEN int1_clean_address LIKE '% QUAY' THEN 'QUAY'
WHEN int1_clean_address LIKE '% QUAY E' THEN 'QUAY'
WHEN int1_clean_address LIKE '% QUAY W' THEN 'QUAY'
WHEN int1_clean_address LIKE '% ROAD' THEN 'RD'
WHEN int1_clean_address LIKE '% HILLR D' THEN 'RD'
WHEN int1_clean_address LIKE '% RD  E/S' THEN 'RD'
WHEN int1_clean_address LIKE '% RD' THEN 'RD'
WHEN int1_clean_address LIKE '% RD.' THEN 'RD'
WHEN int1_clean_address LIKE '% RD N' THEN 'RD'
WHEN int1_clean_address LIKE '% RD E' THEN 'RD'
WHEN int1_clean_address LIKE '% RD S' THEN 'RD'
WHEN int1_clean_address LIKE '% RD W' THEN 'RD'
WHEN int1_clean_address LIKE '% RD SB' THEN 'RD'
WHEN int1_clean_address LIKE '% RD  --2' THEN 'RD'
WHEN int1_clean_address LIKE '% RD  --4' THEN 'RD'
WHEN int1_clean_address LIKE '% RD  --90' THEN 'RD'
WHEN int1_clean_address LIKE '% RAOD' THEN 'RD'
WHEN int1_clean_address LIKE '% RD ES' THEN 'RD'
WHEN int1_clean_address LIKE '% RD W/S' THEN 'RD'
WHEN int1_clean_address LIKE '% R' THEN 'RD'
WHEN int1_clean_address LIKE '% KINGSTONR D' THEN 'RD'
WHEN int1_clean_address LIKE '% MCCOWNR D' THEN 'RD'
WHEN int1_clean_address LIKE '% WESTONR D ' THEN 'RD'
WHEN int1_clean_address LIKE '% KENNEDYR D' THEN 'RD'
WHEN int1_clean_address LIKE '% RD SPOT 56' THEN 'RD'
WHEN int1_clean_address LIKE '% LLOYD MANOR D' THEN 'RD'
WHEN int1_clean_address LIKE '% SENTINELLR D ' THEN 'RD'
WHEN int1_clean_address LIKE '% DON MILLS D' THEN 'RD'
WHEN int1_clean_address LIKE '% DON MILLS RD 3' THEN 'RD'
WHEN int1_clean_address LIKE '% DON MILLSR D' THEN 'RD'
WHEN int1_clean_address LIKE '% DON MILL SRD' THEN 'RD'
WHEN int1_clean_address LIKE '% DON MILLSR D' THEN 'RD'
WHEN int1_clean_address LIKE '% KENNEDYR D' THEN 'RD'
WHEN int1_clean_address LIKE '% WESOTNR D' THEN 'RD'
WHEN int1_clean_address LIKE '% RD%3' THEN 'RD'
WHEN int1_clean_address LIKE '% MARKHAMR D  ' THEN 'RD'
WHEN int1_clean_address LIKE '% SQUARE' THEN 'SQ'
WHEN int1_clean_address LIKE '% RD N%S' THEN 'RD'
WHEN int1_clean_address LIKE '% WESTONR D' THEN 'RD'
WHEN int1_clean_address LIKE '% SQ' THEN 'SQ'
WHEN int1_clean_address LIKE '% SQ N' THEN 'SQ'
WHEN int1_clean_address LIKE '% SQ E' THEN 'SQ'
WHEN int1_clean_address LIKE '% SQ S' THEN 'SQ'
WHEN int1_clean_address LIKE '% SQ W' THEN 'SQ'
WHEN int1_clean_address LIKE '% YONGE T' THEN 'ST'
WHEN int1_clean_address LIKE '% YONGES T' THEN 'ST'
WHEN int1_clean_address LIKE '% HURONS T ' THEN 'ST'
WHEN int1_clean_address LIKE '% ST W%S' THEN 'ST'
WHEN int1_clean_address LIKE '% ST. EAST' THEN 'ST'
WHEN int1_clean_address LIKE '% S E' THEN 'ST'
WHEN int1_clean_address LIKE '% HOLLYS T' THEN 'ST'
WHEN int1_clean_address LIKE '% ST BACKLOT' THEN 'ST'
WHEN int1_clean_address LIKE '% ELIZABETHS T' THEN 'ST'
WHEN int1_clean_address LIKE '% ST F' THEN 'ST'
WHEN int1_clean_address LIKE '% S' THEN 'ST'
WHEN int1_clean_address LIKE '% STE' THEN 'ST'
WHEN int1_clean_address LIKE '% S TW' THEN 'ST'
WHEN int1_clean_address LIKE '% ST.' THEN 'ST'
WHEN int1_clean_address LIKE '% ST. E.' THEN 'ST'
WHEN int1_clean_address LIKE '% ST' THEN 'ST'
WHEN int1_clean_address LIKE '% ST N' THEN 'ST'
WHEN int1_clean_address LIKE '% ST E' THEN 'ST'
WHEN int1_clean_address LIKE '% ST EAST' THEN 'ST'
WHEN int1_clean_address LIKE '% ST WEST' THEN 'ST'
WHEN int1_clean_address LIKE '% ST S' THEN 'ST'
WHEN int1_clean_address LIKE '% ST W' THEN 'ST'
WHEN int1_clean_address LIKE '% ST. W.' THEN 'ST'
WHEN int1_clean_address LIKE '% STREET WEST' THEN 'ST'
WHEN int1_clean_address LIKE '% STREET' THEN 'ST'
WHEN int1_clean_address LIKE '% S TE' THEN 'ST'
WHEN int1_clean_address LIKE '% ST W N/S' THEN 'ST'
WHEN int1_clean_address LIKE '% S W' THEN 'ST'
WHEN int1_clean_address LIKE '% ST WS' THEN 'ST'
WHEN int1_clean_address LIKE '% STREET W' THEN 'ST'
WHEN int1_clean_address LIKE '% KINGS T E' THEN 'ST'
WHEN int1_clean_address LIKE '% KINGS T W' THEN 'ST'
WHEN int1_clean_address LIKE '% T W' THEN 'ST'
WHEN int1_clean_address LIKE '% ST E/S' THEN 'ST'
WHEN int1_clean_address LIKE '% SUMACHS T' THEN 'ST'
WHEN int1_clean_address LIKE '% SST' THEN 'ST'
WHEN int1_clean_address LIKE '% ST ES' THEN 'ST'
WHEN int1_clean_address LIKE '% ST W NS' THEN 'ST'
WHEN int1_clean_address LIKE '% ST N/S' THEN 'ST'
WHEN int1_clean_address LIKE '% STREET EAST' THEN 'ST'
WHEN int1_clean_address LIKE '% STR' THEN 'ST'
WHEN int1_clean_address LIKE '% ST  W' THEN 'ST'
WHEN int1_clean_address LIKE '% SPADINAR D' THEN 'RD'
WHEN int1_clean_address LIKE '% STREET E' THEN 'ST'
WHEN int1_clean_address LIKE '% BLOORST W' THEN 'ST'
WHEN int1_clean_address LIKE '% YONGE T' THEN 'ST'
WHEN int1_clean_address LIKE '% STREET   N3-03 - N3-04' THEN 'ST'
WHEN int1_clean_address LIKE '% ST  E' THEN 'ST'
WHEN int1_clean_address LIKE '% ST E%B' THEN 'ST'
WHEN int1_clean_address LIKE '%  MERTONS T' THEN 'ST'
WHEN int1_clean_address LIKE '% ST 3' THEN 'ST'
WHEN int1_clean_address LIKE '% SHERBOURNE T' THEN 'ST'
WHEN int1_clean_address LIKE '% WELELSLEYS T E' THEN 'ST'
WHEN int1_clean_address LIKE '% ST. E' THEN 'ST'
WHEN int1_clean_address LIKE '% T E' THEN 'ST'
WHEN int1_clean_address LIKE '% ST W %' THEN 'ST'
WHEN int1_clean_address LIKE '% STW' THEN 'ST'
WHEN int1_clean_address LIKE '% QUEEN W' THEN 'ST'
WHEN int1_clean_address LIKE '% ST. EAST' THEN 'ST'
WHEN int1_clean_address LIKE '% ST W%S' THEN 'ST'
WHEN int1_clean_address LIKE '% ST S%S' THEN 'ST'
WHEN int1_clean_address LIKE '% ELIZABETHS T ' THEN 'ST'
WHEN int1_clean_address LIKE '% ST --114' THEN 'ST'
WHEN int1_clean_address LIKE '% TERRACE' THEN 'TER'
WHEN int1_clean_address LIKE '% TERR' THEN 'TER'
WHEN int1_clean_address LIKE '% TER' THEN 'TER'
WHEN int1_clean_address LIKE '% TRAIL' THEN 'TRL'
WHEN int1_clean_address LIKE '% TRL' THEN 'TRL'
WHEN int1_clean_address LIKE '% TR' THEN 'TRL'
WHEN int1_clean_address LIKE '% WALK' THEN 'WALK'
WHEN int1_clean_address LIKE '% WAY --75' THEN 'WAY'
WHEN int1_clean_address LIKE '% WAY' THEN 'WAY'
WHEN int1_clean_address LIKE '% WAY  TH --4' THEN 'WAY'
WHEN int1_clean_address LIKE '% WDS' THEN 'WDS'
WHEN int1_clean_address LIKE '% WOOD' THEN 'WOOD'
ELSE NULL END)
WHERE clean_intersection IS NOT NULL;

-- street direction
ALTER TABLE parking_dataset
ADD COLUMN int1_street_dir varchar(255);

UPDATE parking_dataset
SET int1_street_dir = (CASE WHEN int1_clean_address LIKE '% AVE N' THEN 'N'
WHEN int1_clean_address LIKE '% AVE E' THEN 'E'
WHEN int1_clean_address LIKE '% AVE S' THEN 'S'
WHEN int1_clean_address LIKE '% AVE W' THEN 'W'
WHEN int1_clean_address LIKE '% AV E' THEN 'E'
WHEN int1_clean_address LIKE '% AV W' THEN 'W'
WHEN int1_clean_address LIKE '% AV WEST' THEN 'W'
WHEN int1_clean_address LIKE '% AVE. W.' THEN 'W'
WHEN int1_clean_address LIKE '% AVENUE WEST' THEN 'W'
WHEN int1_clean_address LIKE '% AVE WEST' THEN 'W'
WHEN int1_clean_address LIKE '% AV EAST' THEN 'E'
WHEN int1_clean_address LIKE '% AVE EAST' THEN 'E'
WHEN int1_clean_address LIKE '% VE E' THEN 'E'
WHEN int1_clean_address LIKE '% AVE  E--2' THEN 'E'
WHEN int1_clean_address LIKE '% FINCHAV W ' THEN 'W'
WHEN int1_clean_address LIKE '% EGLINTON W' THEN 'W'
WHEN int1_clean_address LIKE '% SHEPPARD WEST' THEN 'W'
WHEN int1_clean_address LIKE '% SHEPPARD E' THEN 'E'
WHEN int1_clean_address LIKE '% V W' THEN 'W'
WHEN int1_clean_address LIKE '% AVENUE W' THEN 'W'
WHEN int1_clean_address LIKE '% AVE. W' THEN 'W'
WHEN int1_clean_address LIKE '% A VW' THEN 'W'
WHEN int1_clean_address LIKE '% AE W' THEN 'W'
WHEN int1_clean_address LIKE '% AVE. W ' THEN 'W'
WHEN int1_clean_address LIKE '% AVE.W' THEN 'W'
WHEN int1_clean_address LIKE '% AVE.W.' THEN 'W'
WHEN int1_clean_address LIKE '% VE W' THEN 'W'
WHEN int1_clean_address LIKE '% SHEPPARDAV W' THEN 'W'
WHEN int1_clean_address LIKE '% AVENUE EAST' THEN 'E'
WHEN int1_clean_address LIKE '% AVENUE E' THEN 'E'
WHEN int1_clean_address LIKE '% AVE W  NR 5' THEN 'W'
WHEN int1_clean_address LIKE '% AVE W  NR 8' THEN 'W'
WHEN int1_clean_address LIKE '% AVE W NR 22' THEN 'W'
WHEN int1_clean_address LIKE '% LAWRENCE W' THEN 'W'
WHEN int1_clean_address LIKE '% LAWRENCEAV W' THEN 'W'
WHEN int1_clean_address LIKE '% BL N' THEN 'N'
WHEN int1_clean_address LIKE '% BLVD NORTH' THEN 'N'
WHEN int1_clean_address LIKE '% BOULEVARD WEST' THEN 'W'
WHEN int1_clean_address LIKE '% BLVF W' THEN 'W'
WHEN int1_clean_address LIKE '% BLVD. W.' THEN 'W'
WHEN int1_clean_address LIKE '% LBLVD W' THEN 'W'
WHEN int1_clean_address LIKE '% BLV W' THEN 'W'
WHEN int1_clean_address LIKE '% LBVD W' THEN 'W'
WHEN int1_clean_address LIKE '% BL W' THEN 'W'
WHEN int1_clean_address LIKE '% BLVD N' THEN 'N'
WHEN int1_clean_address LIKE '% BLVD E' THEN 'E'
WHEN int1_clean_address LIKE '% BLVD S' THEN 'S'
WHEN int1_clean_address LIKE '% BLVD SOUTH' THEN 'S'
WHEN int1_clean_address LIKE '% BLVD W' THEN 'W'
WHEN int1_clean_address LIKE '% BLVD WEST' THEN 'W'
WHEN int1_clean_address LIKE '% CRES N' THEN 'N'
WHEN int1_clean_address LIKE '% CRES E' THEN 'E'
WHEN int1_clean_address LIKE '% CRES S' THEN 'S'
WHEN int1_clean_address LIKE '% CRES W' THEN 'W'
WHEN int1_clean_address LIKE '% CRT N' THEN 'N'
WHEN int1_clean_address LIKE '% CRT E' THEN 'E'
WHEN int1_clean_address LIKE '% CRT S' THEN 'S'
WHEN int1_clean_address LIKE '% CRT W' THEN 'W'
WHEN int1_clean_address LIKE '% DR N' THEN 'N'
WHEN int1_clean_address LIKE '% DR E' THEN 'E'
WHEN int1_clean_address LIKE '% DR S' THEN 'S'
WHEN int1_clean_address LIKE '% DR W' THEN 'W'
WHEN int1_clean_address LIKE '% HILL S' THEN 'S'
WHEN int1_clean_address LIKE '% HILL N' THEN 'N'
WHEN int1_clean_address LIKE '% QUAY E' THEN 'E'
WHEN int1_clean_address LIKE '% QUAY W' THEN 'W'
WHEN int1_clean_address LIKE '% RD N' THEN 'N'
WHEN int1_clean_address LIKE '% RD E' THEN 'E'
WHEN int1_clean_address LIKE '% RD S' THEN 'S'
WHEN int1_clean_address LIKE '% RD W' THEN 'W'
WHEN int1_clean_address LIKE '% SQ N' THEN 'N'
WHEN int1_clean_address LIKE '% SQ E' THEN 'E'
WHEN int1_clean_address LIKE '% SQ S' THEN 'S'
WHEN int1_clean_address LIKE '% SQ W' THEN 'W'
WHEN int1_clean_address LIKE '% ST. EAST' THEN 'E'
WHEN int1_clean_address LIKE '% S E' THEN 'E'
WHEN int1_clean_address LIKE '% STE' THEN 'E'
WHEN int1_clean_address LIKE '% S TW' THEN 'W'
WHEN int1_clean_address LIKE '% ST. E.' THEN 'E'
WHEN int1_clean_address LIKE '% ST N' THEN 'N'
WHEN int1_clean_address LIKE '% ST E' THEN 'E'
WHEN int1_clean_address LIKE '% ST EAST' THEN 'E'
WHEN int1_clean_address LIKE '% ST WEST' THEN 'W'
WHEN int1_clean_address LIKE '% ST S' THEN 'S'
WHEN int1_clean_address LIKE '% ST W' THEN 'W'
WHEN int1_clean_address LIKE '% ST. W.' THEN 'W'
WHEN int1_clean_address LIKE '% STREET WEST' THEN 'W'
WHEN int1_clean_address LIKE '% S TE' THEN 'E'
WHEN int1_clean_address LIKE '% S W' THEN 'W'
WHEN int1_clean_address LIKE '% ST WS' THEN 'W'
WHEN int1_clean_address LIKE '% STREET W' THEN 'W'
WHEN int1_clean_address LIKE '% KINGS T E' THEN 'E'
WHEN int1_clean_address LIKE '% KINGS T W' THEN 'W'
WHEN int1_clean_address LIKE '% T W' THEN 'W'
WHEN int1_clean_address LIKE '% STREET EAST' THEN 'E'
WHEN int1_clean_address LIKE '% ST  W' THEN 'W'
WHEN int1_clean_address LIKE '% STREET E' THEN 'E'
WHEN int1_clean_address LIKE '% BLOORST W' THEN 'W'
WHEN int1_clean_address LIKE '% ST  E' THEN 'E'
WHEN int1_clean_address LIKE '% WELELSLEYS T E' THEN 'E'
WHEN int1_clean_address LIKE '% ST. E' THEN 'E'
WHEN int1_clean_address LIKE '% T E' THEN 'E'
WHEN int1_clean_address LIKE '% ST W %' THEN 'W'
WHEN int1_clean_address LIKE '% STW' THEN 'W'
WHEN int1_clean_address LIKE '% QUEEN W' THEN 'W'
WHEN int1_clean_address LIKE '% ST. EAST' THEN 'E'
ELSE NULL END)
WHERE clean_intersection IS NOT NULL;


-- SELECT location1, location2, location3, location4, clean_intersection, int1_clean_address, int1_street_name_clean, int1_street_type, int1_street_dir 
-- FROM parking_dataset 
-- WHERE clean_intersection IS NOT NULL LIMIT 5;

-- after all the cleaning has been made to the street num, street name, street_type, street_dir, create a new address for joining with toronto address table
ALTER TABLE parking_dataset
ADD COLUMN int1_match_address varchar(255);

UPDATE parking_dataset
SET int1_match_address = (CASE WHEN int1_street_name_clean IS NOT NULL AND int1_street_type IS NULL AND int1_street_dir IS NULL THEN int1_street_name_clean 
WHEN int1_street_name_clean IS NOT NULL AND int1_street_type IS NOT NULL AND int1_street_dir IS NULL THEN int1_street_name_clean || ' ' || int1_street_type
WHEN int1_street_name_clean IS NOT NULL AND int1_street_type IS NOT NULL AND int1_street_dir IS NOT NULL THEN int1_street_name_clean || ' ' || int1_street_type || ' ' || int1_street_dir
ELSE NULL END)
WHERE clean_intersection IS NOT NULL;


-- while we have cleaned up the majority of addresses for joining, there are adressess within the clean_address field that were not included as part of the 
-- match address results. This is due to the fact that these street names do not include a street type (i.e THE ESPLANADE, NEEDLE FIRWAY)
-- there are currently 6,641 of these records that exist
-- SELECT COUNT(*) FROM parking_dataset WHERE int1_match_address IS NULL AND clean_intersection IS NOT NULL;

UPDATE parking_dataset
SET int1_match_address = int1_match_address
WHERE int1_match_address IS NULL AND int1_clean_address IS NOT NULL AND int1_clean_address LIKE '%WAY%';

--592 updated

UPDATE parking_dataset
SET int1_match_address = 'THE WEST MALL'
WHERE int1_match_address IS NULL AND int1_clean_address IS NOT NULL AND int1_clean_address LIKE '%WEST MALL%';
--105 rows updated

UPDATE parking_dataset
SET int1_match_address = 'THE EAST MALL'
WHERE int1_match_address IS NULL AND int1_clean_address IS NOT NULL AND int1_clean_address LIKE '%EAST MALL%';
--63 rows updated

UPDATE parking_dataset
SET int1_match_address = 'THE ESPLANADE'
WHERE int1_match_address IS NULL AND int1_clean_address IS NOT NULL AND int1_clean_address LIKE '%LANADE%';
-- 3,949 rows updated

UPDATE parking_dataset
SET int1_match_address = 'YONGE ST'
WHERE int1_match_address IS NULL AND int1_clean_address IS NOT NULL AND int1_clean_address LIKE '%YONG%';
-- 36 rows updated

UPDATE parking_dataset
SET int1_match_address = REPLACE(match_address, '  AVE', ' AVE')
WHERE int1_match_address LIKE '%  AVE%';
-- 1,550 rows updated


-- once i was able to identify addresses/intersections 8,300 / 930,390 were not used for further data cleaning/analysis
-- SELECT COUNT(*) FROM parking_dataset WHERE clean_address IS NULL AND clean_intersection IS NULL;
