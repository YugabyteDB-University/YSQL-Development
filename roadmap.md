Developer

DB Internals
- Distributed SQL
  - Hash Sharding
    - partition key
    - clustering key
    - tablets
    - tablet leader
    - rocksdb
      - memtable
      - sst file
    - dockey, subdockey
  - Fast path
    - insert tbl k,v
    - Hash Sharding
    - Tablet leader
    - IntentsDB and RegularDB
      - WAL
        - Transaction id, Hybrid time, Commit time
        - Weak and Strong
    - RocksDB
      - per tablet leader
        - seek
        - next

  

- Isolation levels and transactions
    -  WAL
        - Transaction id, Hybrid time, Commit time
        - Weak and Strong

- Multi-row
    - Example: multiple rows and uniq index
    - IntentsDB and RegularDB
      - WAL
        - Transaction id, Hybrid time, Commit time
        - Weak and Strong
    - RocksDB
      - per tablet leader
        - seek
        - next


Optional: Range sharding ^^ same as above


Takeaways -->
- distributed query execution 
- distributed storage
- 


- Retry logic for isolation levels
- Global Apps






