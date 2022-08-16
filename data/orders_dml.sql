INSERT INTO order_changes
VALUES (1, 1001, '2019-02-15', 'move oven') IF NOT EXISTS;
INSERT INTO order_changes
VALUES (1, 1001, '2019-02-10', 'run cable') IF NOT EXISTS;
INSERT INTO order_changes
VALUES (2, 2002, '2019-03-5', 'add 2nd shower') IF NOT EXISTS;
INSERT INTO order_changes
VALUES (3, 2002, '2019-04-5', 'add 3nd shower') IF NOT EXISTS;