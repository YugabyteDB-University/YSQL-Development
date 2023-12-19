#! /bin//bash
YB_PATH_BASE=/home/gitpod/yugabyte/var

echo "Destroying nodes..."
NUMBER_NODES=3

for (( NODE_NUM=1; n<=$NUMBER_NODES; n++ ))
do
  yugabyted destroy --base_dir=$YB_PATH_BASE/node$NODE_NUM > /dev/null &
done