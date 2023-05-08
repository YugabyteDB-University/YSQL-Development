drop table if exists tbl_vectors;
drop table if exists tbl_arrays;
drop table if exists tbl_jsonbs;

create table tbl_vectors (v tsvector, k serial primary key);
create table tbl_arrays (a int[], k serial primary key);
create table tbl_jsonbs (j jsonb, k serial primary key);

-- use nonconcurrently since there is no risk of online ops.
drop index if exists idx_vectors;
drop index if exists idx_arrays;
drop index if exists idx_jsonbs;

create index nonconcurrently idx_vectors on tbl_vectors using ybgin (v);
create index nonconcurrently idx_arrays on tbl_arrays using ybgin (a);
create index nonconcurrently idx_jsonbs on tbl_jsonbs using ybgin (j);

insert into tbl_vectors values
    (to_tsvector('simple', 'the quick brown fox')),
    (to_tsvector('simple', 'jumps over the')),
    (to_tsvector('simple', 'lazy dog'));

-- add some filler rows to make sequential scan more costly.
insert into tbl_vectors select to_tsvector('simple', 'filler') from generate_series(1, 1000);

insert into tbl_arrays values
    ('{1,1,6}'),
    ('{1,6,1}'),
    ('{2,3,6}'),
    ('{2,5,8}'),
    ('{null}'),
    ('{}'),
    (null);

insert into tbl_arrays select '{0}' from generate_series(1, 1000);

insert into tbl_jsonbs values
    ('{"a":{"number":5}}'),
    ('{"some":"body"}'),
    ('{"some":"one"}'),
    ('{"some":"thing"}'),
    ('{"some":["where","how"]}'),
    ('{"some":{"nested":"jsonb"}, "and":["another","element","not","a","number"]}');
    
insert into tbl_jsonbs select '"filler"' from generate_series(1, 1000);
