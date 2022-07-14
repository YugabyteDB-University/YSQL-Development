/* 
util_ybtserver_metrics.sql
Website: https://university.yugabyte.com
Author: Seth Luersen
Purpose: Utility user-defined functions to gather metrics for YB-TServers
*/

-- for crosstab
-- for crosstab

create extension if not exists tablefunc;

-- drop all
drop table if exists tbl_yb_tserver_metrics_snapshots cascade;

-- create
create table if not exists tbl_yb_tserver_metrics_snapshots(
    host text default '',
    ts timestamptz default now(), 
    metrics jsonb,
    primary key (host asc, ts asc));


drop function if exists fn_yb_tserver_metrics_snap;

-- modify to yb_tserver_webport flag, 8200
-- default is 9000, but there is a conflict for the ipykernel_launcher
create or replace function fn_yb_tserver_metrics_snap(snaps_to_keep int default 1,yb_tserver_webport int default 8200) returns timestamptz as $DO$
declare i record; 
begin

    delete from tbl_yb_tserver_metrics_snapshots 
    where 1=1
    and ts not in (
        select distinct ts          
        from tbl_yb_tserver_metrics_snapshots
        order by ts desc
        limit snaps_to_keep);
    
    for i in (select host from yb_servers()) loop 
        execute format(
        $COPY$
        copy tbl_yb_tserver_metrics_snapshots(host,metrics) from program
        $BASH$
        exec 5<>/dev/tcp/%s/%s ; awk 'BEGIN{printf "%s\t"}/[[]/{in_json=1}in_json==1{printf $0}' <&5 & printf "GET /metrics HTTP/1.0\r\n\r\n" >&5
        $BASH$
        $COPY$
        ,i.host,yb_tserver_webport,i.host); 
    end loop; 

    update tbl_yb_tserver_metrics_snapshots y
    set    metrics = y2.metrics
    from  (
    select host, ts, array_to_json(array_agg(elems)) as metrics
    from tbl_yb_tserver_metrics_snapshots t
        , jsonb_array_elements(metrics) elems
    where 1=1
        and elems->'attributes'->>'namespace_name' <> 'system'
        and elems->'attributes'->>'namespace_name' <> ''
    group by 1,2
    ) y2
    where 1=1
        and y2.host = y.host 
        and y2.ts = y.ts;
     
    return clock_timestamp(); 
end; 
$DO$ language plpgsql;


create or replace view vw_yb_tserver_metrics_snapshot_tablets as
select 
    host
    ,ts
    ,jsonb_array_elements(metrics)->>'type' as type
    ,jsonb_array_elements(metrics)->>'id'   as tablet_id
    ,jsonb_array_elements(metrics)->'attributes'->>'namespace_name' as namespace_name
    ,jsonb_array_elements(metrics)->'attributes'->>'table_name' as table_name
    ,jsonb_array_elements(metrics)->'attributes'->>'table_id' as table_id
    ,jsonb_array_elements(jsonb_array_elements(metrics)->'metrics')->>'name' as metric_name
    ,(jsonb_array_elements(jsonb_array_elements(metrics)->'metrics')->>'value')::numeric as metric_value
    ,(jsonb_array_elements(jsonb_array_elements(metrics)->'metrics')->>'total_sum')::numeric as metric_sum
    ,(jsonb_array_elements(jsonb_array_elements(metrics)->'metrics')->>'total_count')::numeric as metric_count
    from tbl_yb_tserver_metrics_snapshots
    where 1=1;

-- select * from vw_yb_tserver_metrics_snapshot_tablets;

-- drop view if exists vw_yb_tserver_metrics_snapshot_tablets_metrics;

create or replace view vw_yb_tserver_metrics_snapshot_tablets_metrics as
select
    ts
    , host
    , metric_name
    , namespace_name
    , table_name
    , table_id
    , tablet_id
    , sum(case when metric_name='is_raft_leader' then metric_value end)over(
        partition by
        host, namespace_name, table_name, table_id, tablet_id, ts)
    as is_raft_leader
    , metric_value-lead(metric_value)
        over(
            partition by 
            host, namespace_name, table_name, table_id, tablet_id, metric_name 
            order by ts desc) as value
    , extract(epoch from ts-lead(ts)
        over(
            partition by 
            host, namespace_name, table_name, table_id, tablet_id, metric_name 
            order by ts desc)) as seconds
    , rank()over(
        partition by
        host, namespace_name, table_name, table_id,tablet_id, metric_name 
        order by ts desc) as relative_snap_id
    , metric_value
    , metric_sum
    , metric_count
    from vw_yb_tserver_metrics_snapshot_tablets
    where 1=1 
    and table_name not in('metrics','tbl_yb_tserver_metrics_snapshots')
    and namespace_name <> 'system'
    and namespace_name IS NOT NULL;

-- select * from vw_yb_tserver_metrics_snapshot_tablets_metrics;

-- drop view if exists vw_yb_tserver_metrics_report;

create or replace view vw_yb_tserver_metrics_report as
select 
    value
    , round(value/seconds) as rate
    , host
    , namespace_name
    , table_name
    , table_id
    , tablet_id
    , is_raft_leader
    , metric_name
    , ts
    , relative_snap_id
from vw_yb_tserver_metrics_snapshot_tablets_metrics as tablets_delta 
where 1=1
and table_id IS NOT NULL
and value>0;
--order by namespace_name,table_name,table_id,tablet_id;

-- select * from vw_yb_tserver_metrics_report;

-- a convenient "ybwr_last" shows the last snapshot:
create or replace view vw_yb_tserver_metrics_last as 
select * 
from vw_yb_tserver_metrics_report 
where 1=1
and relative_snap_id=1;


-- a convenient "ybwr_snap_and_show_tablet_load" takes a snapshot and show the metrics
create or replace view vw_yb_tserver_metrics_snap_and_show_tablet_load as 
select 
    value
    , rate
    , namespace_name
    , table_name
    , table_id
    , host
    , tablet_id
    , is_raft_leader
    , metric_name
    , to_char(100*value/sum(value)
        over(
            partition by
            namespace_name, table_name, table_id, metric_name),'999%') as "%table"
    , sum(value)
        over(
            partition by
            namespace_name, table_name, table_id, metric_name) as "table"
from vw_yb_tserver_metrics_last , fn_yb_tserver_metrics_snap()
where 1=1
and table_name not in ('metrics','ybwr_snapshots')
and metric_name not in ('follower_lag_ms')
order by ts desc, namespace_name, table_name, table_id, host, tablet_id, is_raft_leader, "table" desc, value desc, metric_name;

-- select * from vw_yb_tserver_metrics_snap_and_show_tablet_load;



-- crosstab view
create or replace view vw_yb_tserver_metrics_snap_and_show_tablet_load_ct as 
select 
   ct_row_name
    , "ct_rocksdb_number_db_seek"
    , "ct_rocksdb_number_db_next"
    , "ct_rows_inserted"
     from crosstab($$
        select 
            format('%s | %s | %s | %s | %s', namespace_name, table_name, format('http://%s:7000/table?id=%s',host,table_id),tablet_id, case is_raft_leader when 0 then ' ' else 'L' end) vw_row_name, 
            metric_name category, 
            sum(value)
        from vw_yb_tserver_metrics_snap_and_show_tablet_load 
        where 1=1
        and metric_name in ('rocksdb_number_db_seek','rocksdb_number_db_next','rows_inserted') 
        group by namespace_name, table_name, host, table_id, tablet_id, is_raft_leader, metric_name
        order by 1, 2 desc,3
        $$) 
     as (ct_row_name text, "ct_rocksdb_number_db_seek" numeric, "ct_rocksdb_number_db_next" numeric, "ct_rows_inserted" decimal);


-- crosstab function

create or replace function fn_yb_tserver_metrics_snap_and_show_tablet_load_ct(isLocal int default 0)
returns table (
    row_name text, 
    rocksdb_number_db_seek numeric,
    rocksdb_number_db_next numeric,
    rows_inserted numeric
)
language plpgsql
as $DO$
begin

    if isLocal = 1 then
        return query
        select 
        ct_row_name
        , "ct_rocksdb_number_db_seek"
        , "ct_rocksdb_number_db_next"
        , "ct_rows_inserted"
        from crosstab($$
            select 
                format('%s | %s | %s | %s | %s', namespace_name, table_name, format('http://%s:7000/table?id=%s',host,table_id),tablet_id, case is_raft_leader when 0 then ' ' else 'L' end) vw_row_name, 
                metric_name category, 
                sum(value)
            from vw_yb_tserver_metrics_snap_and_show_tablet_load 
            where 1=1
            and metric_name in ('rocksdb_number_db_seek','rocksdb_number_db_next','rows_inserted') 
            group by namespace_name, table_name, host, table_id, tablet_id, is_raft_leader, metric_name
            order by 1, 2 desc,3
            $$) 
        as (ct_row_name text, "ct_rocksdb_number_db_seek" numeric, "ct_rocksdb_number_db_next" numeric, "ct_rows_inserted" decimal);
     else
        return query
        select 
            ct_row_name
            , "ct_rocksdb_number_db_seek"
            , "ct_rocksdb_number_db_next"
            , "ct_rows_inserted"
            from crosstab($$
                select 
                    format('%s | %s | %s | %s | %s', namespace_name, table_name, table_id, tablet_id, case is_raft_leader when 0 then ' ' else 'L' end) vw_row_name, 
                    metric_name category, 
                    sum(value)
                from vw_yb_tserver_metrics_snap_and_show_tablet_load 
                where 1=1
                and metric_name in ('rocksdb_number_db_seek','rocksdb_number_db_next','rows_inserted') 
                group by namespace_name, table_name, host, table_id, tablet_id, is_raft_leader, metric_name
                order by 1, 2 desc,3
                $$) 
            as (ct_row_name text, "ct_rocksdb_number_db_seek" numeric, "ct_rocksdb_number_db_next" numeric, "ct_rows_inserted" decimal);
     end if;
end; $DO$;





drop function if exists fn_yb_tserver_metrics_snap_table;

create or replace function fn_yb_tserver_metrics_snap_table(isLocal int default 0)
returns table (
    row_name text, 
    rocksdb_number_db_seek numeric,
    rocksdb_number_db_next numeric,
    rows_inserted numeric
)
language plpgsql
as $DO$
begin
    return query
    select * 
    from fn_yb_tserver_metrics_snap_and_show_tablet_load_ct(isLocal);
end; $DO$;


/*
ybwr_report -- >
.. vw_yb_tserver_metrics_report
.... vw_yb_tserver_metrics_snapshot_tablets_metrics
...... vw_yb_tserver_metrics_snapshot_tablets
........ tbl_yb_tserver_metrics_snapshots

ybwr_snap_and_show_tablet_load -->
vw_yb_tserver_metrics_snap_and_show_tablet_load 
.. vw_yb_tserver_metrics_last  fn_yb_tserver_metrics_snap()
.... vw_yb_tserver_metrics_report 


fn_yb_tserver_metrics_snap()
.. tbl_yb_tserver_metrics_snapshots


fn_yb_tserver_metrics_snap_table
.. fn_yb_tserver_metrics_snap_and_show_tablet_load_ct
....  vw_yb_tserver_metrics_snap_and_show_tablet_load
*/