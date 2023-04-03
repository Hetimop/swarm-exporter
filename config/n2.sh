
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

  # Print the metrics for the current node
  cat <<EOF
# HELP docker_node_info Docker node information
# TYPE docker_node_info gauge
docker_node_info{node_id="$NODE_ID",hostname="$DOCKER_NODE_HOSTNAME",role="$DOCKER_NODE_ROLE",manager_status="$DOCKER_NODE_MANAGER_STATUS",labels="$DOCKER_NODE_LABELS"} 1
EOF

done

# Get the stack information
DOCKER_STACK_INFO=$(docker stack ls --format '{{.Name}}')

# Print the metrics for stacks
cat <<EOF
# HELP docker_stack_info Docker stack information
# TYPE docker_stack_info gauge
EOF

while read -r DOCKER_STACK_NAME; do
  cat <<EOF
docker_stack_info{name="$DOCKER_STACK_NAME"} 1
EOF
done <<< "$DOCKER_STACK_INFO"


# Get the list of volumes
DOCKER_VOLUMES=$(docker volume ls --format '{{.Name}}')

# Loop through each volume and get its information
for VOLUME_NAME in $DOCKER_VOLUMES; do

  # Get the volume information
  DOCKER_VOLUME_INFO=$(docker volume inspect $VOLUME_NAME)

  # Print the metrics for the current volume
  cat <<EOF
# HELP docker_volume_info Docker volume information
# TYPE docker_volume_info gauge
docker_volume_info{volume_name="$VOLUME_NAME"} $(echo $DOCKER_VOLUME_INFO | jq '.[0].Name' | wc -l)
EOF

done

# Get the list of networks
DOCKER_NETWORKS=$(docker network ls --format '{{.Name}}')

# Loop through each network and get its information
for NETWORK_NAME in $DOCKER_NETWORKS; do

  # Get the network information
  DOCKER_NETWORK_INFO=$(docker network inspect $NETWORK_NAME)

  # Print the metrics for the current network
  cat <<EOF
# HELP docker_network_info Docker network information
# TYPE docker_network_info gauge
docker_network_info{network_name="$NETWORK_NAME"} $(echo $DOCKER_NETWORK_INFO | jq '.[0].Name' | wc -l)
EOF

done

# Get the list of images
DOCKER_IMAGES=$(docker image ls --format '{{.Repository}}:{{.Tag}}')

# Loop through each image and get its information
for IMAGE_NAME in $DOCKER_IMAGES; do

  # Get the image information
  DOCKER_IMAGE_INFO=$(docker image inspect $IMAGE_NAME)

  # Print the metrics for the current image
  cat <<EOF
# HELP docker_image_info Docker image information
# TYPE docker_image_info gauge
docker_image_info{image_name="$IMAGE_NAME"} $(echo $DOCKER_IMAGE_INFO | jq '.[0].Name' | wc -l)
EOF

done
