CREATE TABLE transactions (
  user_id INT NOT NULL,
  account_id INT NOT NULL,
  geo_partition TEXT,
  account_type TEXT NOT NULL,
  amount NUMERIC NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
) PARTITION BY LIST (geo_partition)

CREATE TABLESPACE tblspace_us WITH (
  replica_placement = '{"num_replicas": 1, "placement_blocks":
  [{"cloud": "cloud1", "region": "region1", "zone": "zone1", "min_num_replicas": 1}]}'
)

CREATE TABLESPACE tblspace_eu WITH (
  replica_placement = '{"num_replicas": 1, "placement_blocks":
  [{"cloud": "cloud2", "region": "region2", "zone": "zone2", "min_num_replicas": 1}]}'
)

CREATE TABLESPACE tblspace_ap WITH (
  replica_placement = '{"num_replicas": 1, "placement_blocks": [{"cloud": "cloud3", "region": "region3", "zone": "zone3", "min_num_replicas": 1}]}'
)