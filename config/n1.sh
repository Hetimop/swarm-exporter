#!/bin/bash


  # Get a list of all nodes in the swarm
  NODES=$(docker node ls --format '{{.ID}}')

  # Loop through each node and get its information
  for NODE_ID in $NODES; do

    # Get the node information
    DOCKER_NODE_INFO=$(docker node inspect $NODE_ID)

    # Extract the relevant information
    DOCKER_NODE_HOSTNAME=$(echo $DOCKER_NODE_INFO | jq -r '.[].Description.Hostname')
    DOCKER_NODE_ROLE=$(echo $DOCKER_NODE_INFO | jq -r '.[].Spec.Role')
    DOCKER_NODE_MANAGER_STATUS=$(docker node inspect $NODE_ID --format '{{.ManagerStatus}}' | awk '{print tolower($0)}')
    DOCKER_NODE_LABELS=$(docker node inspect $NODE_ID --format '{{json .Spec.Labels}}')

    # Print the metrics
    cat <<EOF
# HELP docker_node_info Docker node information
# TYPE docker_node_info gauge
docker_node_info{node_id="$NODE_ID",hostname="$DOCKER_NODE_HOSTNAME",role="$DOCKER_NODE_ROLE",manager_status="$DOCKER_NODE_MANAGER_STATUS",labels="$DOCKER_NODE_LABELS"} 1
EOF

  done

