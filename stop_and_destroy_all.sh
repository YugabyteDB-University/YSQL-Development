#! /bin//bash
YB_PATH_BASE=/home/gitpod/yugabyte/var

echo "Destroying nodes..."
NUMBER_NODES=3

for (( NODE_NUM=1; NODE_NUM<=$NUMBER_NODES; NODE_NUM++ ))
do
  echo "Destroy node $NODE_NUM of $NUMBER_NODES"
  yugabyted destroy --base_dir=$YB_PATH_BASE/node$NODE_NUM > /dev/null 2>&1
  sleep 2
  echo "Deleteing node${NODE_NUM} directory"
  rm -rf ${YB_PATH_BASE}/node${NODE_NUM}
done