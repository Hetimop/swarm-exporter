#!/bin/bash

# Récupère la liste des nœuds du cluster
swarm_nodes=$(docker node ls --format "{{.ID}}|{{.Hostname}}|{{.Status}}|{{.Availability}}|{{.ManagerStatus}}|{{.EngineVersion}}")

# Parcourt la liste des nœuds
while read -r node; do
    id=$(echo "$node" | cut -d "|" -f 1)
    hostname=$(echo "$node" | cut -d "|" -f 2)
    status=$(echo "$node" | cut -d "|" -f 3)
    availability=$(echo "$node" | cut -d "|" -f 4)
    manager_status=$(echo "$node" | cut -d "|" -f 5)
    engine_version=$(echo "$node" | cut -d "|" -f 6)

    # Récupère les labels du nœud
#    echo "Inspecting node $id ..."
    node_labels=$(docker node inspect --format '{{ .Spec.Labels }}' "$hostname")

    # Affiche les métriques
    echo "swarm_info{id=\"$id\", hostname=\"$hostname\", status=\"$status\", availability=\"$availability\", manager_status=\"$manager_status\", engine_version=\"$engine_version\"} 1"
    echo "swarm_node_labels{id=\"$id\", hostname=\"$hostname\", labels=\"$node_labels\"} 1"
done <<< "$swarm_nodes"
