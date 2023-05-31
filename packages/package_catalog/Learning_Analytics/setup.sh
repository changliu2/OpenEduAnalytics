#!/bin/bash

# Installs the Learning Analytics package v1.0
# This script can be invoked directly to install the Learning Analytics package v1 assets into an existing Synapse Workspace.
if [ $# -ne 1 ]; then
    echo "This setup script will install the Learning Analytics package v1 assets into an existing Synapse workspace."
    echo "Invoke this script like this:  "
    echo "    setup.sh <synapse_workspace_name>"
    exit 1
fi

synapse_workspace=$1
this_file_path=$(dirname $(realpath $0))

echo "--> Setting up the Learning Analytics package v1 assets."

# 1) install notebooks
eval "az synapse notebook import --workspace-name $synapse_workspace --name LA_build_dimension_tables --spark-pool-name spark3p3sm --file @$this_file_path/notebook/LA_build_dimension_tables.ipynb --only-show-errors"
eval "az synapse notebook import --workspace-name $synapse_workspace --name LA_build_fact_tables --spark-pool-name spark3p3sm --file @$this_file_path/notebook/LA_build_fact_tables.ipynb --only-show-errors"

# 2) setup pipelines
# Note that the ordering below matters because pipelines that are referred to by other pipelines must be created first.
eval "az synapse pipeline create --workspace-name $synapse_workspace --name 1_build_LA_dim_tables --file @$this_file_path/pipeline/1_build_LA_dim_tables.json"
eval "az synapse pipeline create --workspace-name $synapse_workspace --name 2_build_LA_fact_tables --file @$this_file_path/pipeline/2_build_LA_fact_tables.json"
eval "az synapse pipeline create --workspace-name $synapse_workspace --name 3_reset_workspace_LA_package --file @$this_file_path/pipeline/3_reset_workspace_LA_package.json"
eval "az synapse pipeline create --workspace-name $synapse_workspace --name 0_main_LA_package --file @$this_file_path/pipeline/0_main_LA_package.json"

echo "--> Setup complete. The Learning Analytics package v1 assets have been installed in the specified synapse workspace: $synapse_workspace"