create table transactions (
  user_id int not null,
  account_id int not null,
  geo_partition text,
  account_type text not null,
  amount numeric not null,
  created_at timestamp default now()
) partition by list (geo_partition)

create tablespace tblspace_us with (
  replica_placement = '{"num_replicas": 1, "placement_blocks":
  [{"cloud": "cloud1", "region": "region1", "zone": "zone1", "min_num_replicas": 1}]}'
)

create tablespace tblspace_eu with (
  replica_placement = '{"num_replicas": 1, "placement_blocks":
  [{"cloud": "cloud2", "region": "region2", "zone": "zone2", "min_num_replicas": 1}]}'
)

create tablespace tblspace_ap with (
  replica_placement = '{"num_replicas": 1, "placement_blocks": [{"cloud": "cloud3", "region": "region3", "zone": "zone3", "min_num_replicas": 1}]}'
)