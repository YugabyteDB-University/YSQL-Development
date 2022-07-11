DROP TABLE IF EXISTS tbl_cities;
DROP TABLE IF EXISTS tbl_states;
DROP TABLE IF EXISTS tbl_countries;


CREATE TABLE tbl_cities (
  city_id INTEGER NOT NULL,
  city_name varchar(255)  NOT NULL,
  city_name_alt varchar(255),
  state_id INTEGER NOT NULL,
  state_code varchar(255)  NOT NULL,
  country_id INTEGER NOT NULL,
  country_code char(2)  NOT NULL,
  latitude decimal(10,8) NOT NULL,
  longitude decimal(11,8) NOT NULL,
  created_at timestamp NOT NULL DEFAULT '2021-12-31 12:59:59',
  updated_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  flag SMALLINT NOT NULL DEFAULT '1',
  wiki_data_id varchar(255),
  PRIMARY KEY (city_id)
) ;

CREATE TABLE tbl_countries (
  country_id INTEGER NOT NULL,
  country_name varchar(255)  NOT NULL,
  country_name_alt varchar(255),
  iso3 char(3)  ,
  numeric_code char(3)  ,
  iso2 char(2)  ,
  phonecode varchar(255)  ,
  capital varchar(255)  ,
  currency varchar(255)  ,
  currency_name varchar(255)  ,
  currency_symbol varchar(255)  ,
  tld varchar(255)  ,
  native varchar(255)  ,
  region varchar(255)  ,
  subregion varchar(255)  ,
  timezones jsonb ,
  translations jsonb  ,
  latitude decimal(10,8) ,
  longitude decimal(11,8) ,
  emoji varchar(191) ,
  emojiU varchar(191) ,
  created_at timestamp NOT NULL DEFAULT '2021-12-31 12:59:59',
  updated_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  flag SMALLINT NOT NULL DEFAULT '1',
  wiki_data_id varchar(255),
  PRIMARY KEY (country_id)
) ;

CREATE TABLE tbl_states (
  state_id INTEGER NOT NULL,
  state_name varchar(255)  NOT NULL,
  country_id INTEGER NOT NULL,
  country_code char(2)  NOT NULL,
  fips_code varchar(255)  ,
  iso2 varchar(255)  ,
  type varchar(191)  ,
  latitude decimal(10,8) ,
  longitude decimal(11,8) ,
  created_at timestamp NOT NULL DEFAULT '2021-12-31 12:59:59',
  updated_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  flag SMALLINT NOT NULL DEFAULT '1',
  wiki_data_id varchar(255),
  PRIMARY KEY (state_id)
) ;
