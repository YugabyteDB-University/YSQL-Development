#! /bin//bash
MODE="region"

# Check if an argument is provided
# 2.19.2 for yugabyted does not support cloud tolerance
if [[ $# -eq 1 ]]; then
    case $1 in
        zone)
            MODE="zone"
            ;;
        region)
            MODE="region"
            ;;
        cloud)
            #MODE="cloud"
            MODE="region"
            ;;
        *)
            echo "Invalid argument: $1"
            echo "Usage: $0 [zone|region|cloud]"
            exit 1
            ;;
    esac
fi

YB_PATH_BASE=/home/gitpod/yugabyte/var

start_node() {
    local node_number=$1
    local advertise_address="127.0.0.${node_number}"
    local base_dir="${YB_PATH_BASE}/node${node_number}"
    local cloud_location=""
    local master_webserver_port=7000
    local tserver_webserver_port=8200
    local join_arg=""
    local status=""
     
    case "$MODE" in
    zone)
        cloud_location="cloud1.region1.zone$node_number"
        ;;
    region)
        cloud_location="cloud1.region$node_number.zone$node_number"
        ;;
    cloud)
        cloud_location="cloud$node_number.region$node_number.zone$node_number"
        ;;
    *)
    esac

    if [[ ${node_number} -gt 1 ]]; then
        join_arg="--join=127.0.0.1"
    fi

    if [[ ! -d ${base_dir} ]]; then
      # Directory does not exist, so create it
      mkdir -p $base_dir
      echo "Directory created: $base_dir"
    fi

    echo "Starting node ${node_number} with the following: \
    advertise_address=$advertise_address \
    base_dir=$base_dir \
    cloud_location=$cloud_location \
    master_webserver_port=$master_webserver_port \
    tserver_webserver_port=$tserver_webserver_port \
    fault_tolerance=$MODE \
    join_arg=$join_arg"

    yugabyted start \
      --advertise_address=${advertise_address} \
      --base_dir=${base_dir} \
      --cloud_location=${cloud_location} \
      --fault_tolerance=$MODE \
      --master_flags="yb_num_shards_per_tserver=1,ysql_num_shards_per_tserver=1,ysql_beta_features=true,ysql_enable_packed_row=false" \
      --master_webserver_port=${master_webserver_port} \
      --tserver_flags="yb_num_shards_per_tserver=1,ysql_num_shards_per_tserver=1,ysql_beta_features=true,ysql_enable_packed_row=false" \
      --tserver_webserver_port=${tserver_webserver_port}  \
      --callhome=true ${join_arg} > /dev/null 2>&1
    
    sleep 4
    status=$(yugabyted status --base_dir=${YB_PATH_BASE}/node${node_number} | grep Status | sed 's/.*: //; s/|.*//')
    yugabyted status --base_dir=${YB_PATH_BASE}/node${node_number}
    # Trim leading and trailing whitespace
    status=$(echo "$status" | xargs)

    if [[ "$status" == "Running." ]]; then
      echo "Good news! ${node_number} node started!"
      return 0
    else 
      echo "Bad news... ${node_number} node failed to start!"
      return 1
    fi
}

error_fix_bad_node_start() {
  echo "What to do with this error???"
  echo "(1) Ctrl + C to stop this script in the terminal."
  echo "(2) In this terminal, run:"
  echo "./stop_and_destroy_all.sh "
  echo "(3) After the script completes, in the terminal, run: "
  echo "./start_all.sh $MODE"
  echo "(4) Manually open from the Explorer, 01_Lab_Setup.ipynb"
}

error_fix_bad_node_count() {
  echo "What to do with this error???"
  echo "(1) Ctrl + C to stop this script in the terminal."
  echo "(2) After the script completes, in the terminal, run: "
  echo "./start_all.sh $MODE"
  echo "(3) Manually open from the Explorer, 01_Lab_Setup.ipynb"
}

MIN_NODE_NUM=1
MAX_NODE_NUM=3
# Loop to start nodes, up to 3 MAX_NODE_NUM nodes
while (( $MIN_NODE_NUM <= $MAX_NODE_NUM )); do
    echo "Trying to start nodes... $MIN_NODE_NUM of $MAX_NODE_NUM"
    # Start the node
    start_node "${MIN_NODE_NUM}"

    # Check if start_node was successful
    if [ $? -ne 0 ]; then
        echo "Failed to start node ${MIN_NODE_NUM}, going to rm -rf base_dir, show how to fix, and exit"
        rm -rf ${YB_PATH_BASE}/node${MIN_NODE_NUM}
        error_fix_bad_node_start
        exit 1
    fi

    # Wait for 3 seconds before starting the next node
    sleep 3

    # Increment the node number
    (( MIN_NODE_NUM++ ))
done

# node count
NODE_COUNT=$(ysqlsh -U yugabyte -h 127.0.0.1 -Atc "select count(*) from yb_servers();")

# Check if NODE_COUNT is not set or not a number
if [[ -z "$NODE_COUNT" ]] || ! [[ "$NODE_COUNT" =~ ^[0-9]+$ ]]; then
    echo "Yikes! Using ysqlsh, unable to retrieve the node count or the node count is not a valid number, so will stop and destroy and show how to fix"
    ./stop_and_destroy_all.sh
    error_fix_bad_node_count
    exit 1
fi

# Check if NODE_COUNT is not equal to 3
if [[ $NODE_COUNT -ne $MAX_NODE_NUM ]]; then
  echo "Yikes! Using ysqlsh, retrieved node count as $$NODE_COUNT, but it is not equal to $MAX_NODE_NUM, so will stop and destroy"
  ./stop_and_destroy_all.sh
  error_fix_bad_node_count
  exit 1
else
  echo "Looks good in terms of running nodes and node count. Time to configure the data placement..."
  yugabyted configure data_placement  \
    --base_dir=${YB_PATH_BASE}/node1  \
    --fault_tolerance=$MODE > /dev/null 2>&1

  sleep 1

  echo "All nodes should be up. Let's take a look using yugabyted status"

  yugabyted status --base_dir=${YB_PATH_BASE}/node1 

  echo "All nodes should be up. Let's take a look using yb_servers()"

  ysqlsh -U yugabyte -h 127.0.0.1 -c "select * from yb_servers();"

  echo "If you don't see a notebook tab, try one or both of the following..."
  echo " disable popup blocker for this site"
  echo " from Explorer, open '01_Lab_Setup.ipynb"
  exit 0
fi

