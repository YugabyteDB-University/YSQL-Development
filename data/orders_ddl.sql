DROP TABLE IF EXISTS order_changes;
DROP TABLE IF EXISTS order_changes_2022_02;
DROP TABLE IF EXISTS order_changes_2022_03;
DROP TABLE IF EXISTS order_changes_default;

CREATE TABLE order_changes (
  user_id INT NOT NULL,
  account_id INT NOT NULL,
  change_date DATE,
  description TEXT
) PARTITION BY RANGE (change_date);

CREATE TABLE order_changes_2022_02 PARTITION OF order_changes (
  user_id,
  account_id,
  change_date,
  description,
  PRIMARY KEY (user_id HASH, account_id, change_date)
) FOR
VALUES
FROM ('2022-02-01') TO ('2022-03-01');

CREATE TABLE order_changes_2022_03 PARTITION OF order_changes (
  user_id,
  account_id,
  change_date,
  description,
  PRIMARY KEY (user_id HASH, account_id, change_date)
) FOR
VALUES
FROM ('2022-03-01') TO ('2022-04-01');

CREATE TABLE order_changes_default PARTITION OF order_changes DEFAULT;