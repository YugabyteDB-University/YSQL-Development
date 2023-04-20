drop table if exists tbl_order_changes;
drop table if exists tbl_order_changes_prtn_2023_01;
drop table if exists tbl_order_changes_prtn_2023_02;
drop table if exists tbl_order_changes_prtn_2023_03;
drop table if exists tbl_order_changes_prtn_2023_04;
drop table if exists tbl_order_changes_prtn_default;

create table if not exists tbl_order_changes (
  user_id int not null,
  account_id int not null,
  change_date date,
  description text
) partition by range (change_date);

create table if not exists tbl_order_changes_prtn_2023_01 partition of tbl_order_changes (
  user_id,
  account_id,
  change_date,
  description,
  primary key (user_id hash, change_date desc)
) for
values
from ('2023-01-01') to ('2023-02-01');

create table if not exists  tbl_order_changes_prtn_2023_02 partition of  tbl_order_changes (
  user_id,
  account_id,
  change_date,
  description,
 primary key (user_id hash, change_date desc)
) for
values
from ('2023-02-01') to ('2023-03-01');

create table if not exists  tbl_order_changes_prtn_2023_03 partition of  tbl_order_changes (
  user_id,
  account_id,
  change_date,
  description,
  primary key (user_id hash, change_date desc)
) for
values
from ('2023-03-01') to ('2023-04-01');


create table  if not exists  tbl_order_changes_prtn_2023_04 partition of tbl_order_changes (
  user_id,
  account_id,
  change_date,
  description,
  primary key (user_id hash, change_date desc)
) for
values
from ('2023-04-01') to ('2023-05-01');

--create table tbl_order_changes_prtn_default partition of tbl_order_changes default ;