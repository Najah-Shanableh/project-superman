#!/bin/bash

# Setup
HOST=dssgsummer2014postgres.c5faqozfo86k.us-west-2.rds.amazonaws.com
USER=mentors
DB=mentor_training
export PGPASSWORD="mentors2014"

# Prep work and create table statement
psql -h $HOST -U $USER $DB <<EOF
-- Create schema so I don't mess with anyone
CREATE SCHEMA IF NOT EXISTS nick;

-- Create table statement
DROP TABLE IF EXISTS building_violations;
-- Create table modified from "head -n 100000 Building_Violations.csv | csvsql -i postgresql --table building_violations"
CREATE TABLE building_violations (
        id integer not null,
        violation_last_modified_date date not null,
        violation_date date not null,
        violation_code varchar(9) not null,
        violation_status varchar(8) not null,
        violation_status_date date,
        violation_description varchar(30),
        violation_location varchar(242),
        violation_inspector_comments varchar(3869),
        violation_ordinance varchar(807),
        inspector_id varchar(9) not null,
        inspection_number integer not null,
        inspection_status varchar(6) not null,
        inspection_waived varchar(1) not null,
        inspection_category varchar(12) not null,
        department_bureau varchar(26) not null,
        address varchar(50) not null,
        property_group integer not null,
        ssa integer,
        latitude float,
        longitude float,
        location varchar(39)
);
EOF

# Clean up the building violations data to avoid errors in upload
cat Building_Violations.csv | sed 's/, ,/,,/g' > Building_Violations_cleaned.csv

# Upload data and change schema
psql -h $HOST -U $USER $DB <<EOF
\copy building_violations from Building_Violations_cleaned.csv CSV HEADER;
DROP TABLE IF EXISTS nick.building_violations;
ALTER TABLE building_violations SET SCHEMA nick;
EOF