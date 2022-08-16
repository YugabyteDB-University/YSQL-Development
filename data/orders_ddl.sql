DROP TABLE IF EXISTS order_changes;
DROP TABLE IF EXISTS order_changes_2019_02;
DROP TABLE IF EXISTS order_changes_2019_03;
DROP TABLE IF EXISTS order_changes_default;

CREATE TABLE order_changes (
  user_id INT NOT NULL,
  account_id INT NOT NULL,
  change_date DATE,
  description TEXT
) PARTITION BY RANGE (change_date);

CREATE TABLE order_changes_2019_02 PARTITION OF order_changes (
  user_id,
  account_id,
  change_date,
  description,
  PRIMARY KEY (user_id HASH, account_id, change_date)
) FOR
VALUES
FROM ('2019-02-01') TO ('2019-03-01');

CREATE TABLE order_changes_2019_03 PARTITION OF order_changes (
  user_id,
  account_id,
  change_date,
  description,
  PRIMARY KEY (user_id HASH, account_id, change_date)
) FOR
VALUES
FROM ('2019-03-01') TO ('2019-04-01');

CREATE TABLE order_changes_default PARTITION OF order_changes DEFAULT;