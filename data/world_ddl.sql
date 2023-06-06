drop table if exists tbl_cities;
drop table if exists tbl_states;
drop table if exists tbl_countries;


create table tbl_cities (
  city_id integer not null,
  city_name varchar(255)  not null,
  city_name_alt varchar(255),
  state_id integer not null,
  state_code varchar(255)  not null,
  country_id integer not null,
  country_code char(2)  not null,
  latitude decimal(10,8) not null,
  longitude decimal(11,8) not null,
  created_at timestamp not null default '2021-12-31 12:59:59',
  updated_at timestamp not null default current_timestamp,
  flag smallint not null default '1',
  wiki_data_id varchar(255),
  primary key (city_id)
) ;

create table tbl_countries (
  country_id integer not null,
  country_name varchar(255)  not null,
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
  emojiu varchar(191) ,
  created_at timestamp not null default '2021-12-31 12:59:59',
  updated_at timestamp not null default current_timestamp,
  flag smallint not null default '1',
  wiki_data_id varchar(255),
  primary key (country_id)
) ;

create table tbl_states (
  state_id integer not null,
  state_name varchar(255)  not null,
  country_id integer not null,
  country_code char(2)  not null,
  fips_code varchar(255)  ,
  iso2 varchar(255)  ,
  type varchar(191)  ,
  latitude decimal(10,8) ,
  longitude decimal(11,8) ,
  created_at timestamp not null default '2021-12-31 12:59:59',
  updated_at timestamp not null default current_timestamp,
  flag smallint not null default '1',
  wiki_data_id varchar(255),
  primary key (state_id)
) ;
