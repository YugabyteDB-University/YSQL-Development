
#! /bin//bash
YB_PATH_BASE=/home/gitpod/yugabyte/var
# custom for YSQL Developmnet, placement is cloud1.region1.zone1, cloud2.region2.zone2, cloud3.region3.zone3 
start_node() {
    local node_number=$1
    local advertise_address="127.0.0.${node_number}"
    local base_dir="${YB_PATH_BASE}/node${node_number}"
    local cloud_location="cloud${node_number}.region${node_number}.zone${node_number}"
    local master_webserver_port=7000
    local tserver_webserver_port=8200
    local join_arg=""
    local status=""
    if [ "${node_number}" -gt 1 ]; then
        join_arg="--join=127.0.0.1"
    fi

    echo "Starting node ${advertise_address}"
    yugabyted start \
      --advertise_address=${advertise_address} \
      --base_dir=${base_dir} \
      --cloud_location=${cloud_location} \
      --fault_tolerance=cloud \
      --master_flags="yb_num_shards_per_tserver=1,ysql_num_shards_per_tserver=1,ysql_beta_features=true,ysql_enable_packed_row=false" \
      --master_webserver_port=${master_webserver_port} \
      --tserver_flags="yb_num_shards_per_tserver=1,ysql_num_shards_per_tserver=1,ysql_beta_features=true,ysql_enable_packed_row=false" \
      --tserver_webserver_port=${tserver_webserver_port}  ${join_arg} > /dev/null 2>&1
    
    sleep 3

    status=`yugabyted status --base_dir=${YB_PATH_BASE}/node${node_number} | grep Status | sed 's/.*: //; s/|.*//'`

    echo $status

    if [ $status != "Running." ]; then
      echo "Bad news... ${node_number}  node failed to start!"
    fi
}

this_number=1
while [ ${this_number} -le 3 ]; do
    start_node ${this_number}
    sleep 3
    this_number=$((this_number + 1))
done


# node count
node_count=`ysqlsh -U yugabyte -h 127.0.0.1 -Atc "select count(*) from yb_servers();"`

if [ $node_count != 3 ]; then
  echo "Yikes! There's a problem starting YugabyteDB with yugabyted, so will stop and destroy"
  ./stop_and_destroy_all.sh
  exit
else
  yugabyted configure data_placement  \
    --base_dir=${YB_PATH_BASE}/node1  \
    --fault_tolerance=zone > /dev/null 2>&1
  sleep 1
  echo "All nodes should be up. Let's take a look using yugabyted status"
  yugabyted status --base_dir=${YB_PATH_BASE}/node1 
  echo "All nodes should be up. Let's take a look using yb_servers()"
  ysqlsh -U yugabyte -h 127.0.0.1 -c "select * from yb_servers();"
fi

