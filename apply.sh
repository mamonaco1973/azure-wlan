#!/bin/bash
set -euo pipefail

# ================================================================================
# apply.sh — Two-stage deploy for azure-wlan (vWAN + NAT demo)
# Stage 1: networking (VNets, subnets, NAT Gateways)
# Stage 2: vWAN hubs, VMs, NSGs — vars injected from stage 1 outputs
# ================================================================================

# ------------------------------------------------------------------------------
# Environment validation
# ------------------------------------------------------------------------------
./check_env.sh

# ------------------------------------------------------------------------------
# Stage 1: Networking
# ------------------------------------------------------------------------------
cd 01-networking
terraform init -upgrade
terraform apply -auto-approve
cd ..

# ------------------------------------------------------------------------------
# Capture stage 1 outputs
# ------------------------------------------------------------------------------
RG=$(cd 01-networking && terraform output -raw resource_group_name)

VNET1_ID=$(cd 01-networking && terraform output -raw vnet1_id)
VNET2_ID=$(cd 01-networking && terraform output -raw vnet2_id)
VNET3_ID=$(cd 01-networking && terraform output -raw vnet3_id)

SUBNET1_ID=$(cd 01-networking && terraform output -raw subnet1_id)
SUBNET2_ID=$(cd 01-networking && terraform output -raw subnet2_id)
SUBNET3_ID=$(cd 01-networking && terraform output -raw subnet3_id)

# ------------------------------------------------------------------------------
# Stage 2: vWAN, VMs, NSGs
# ------------------------------------------------------------------------------
cd 02-vwan
terraform init -upgrade
terraform apply -auto-approve \
  -var="resource_group_name=${RG}" \
  -var="vnet1_id=${VNET1_ID}" \
  -var="vnet2_id=${VNET2_ID}" \
  -var="vnet3_id=${VNET3_ID}" \
  -var="subnet1_id=${SUBNET1_ID}" \
  -var="subnet2_id=${SUBNET2_ID}" \
  -var="subnet3_id=${SUBNET3_ID}"
cd ..

# ------------------------------------------------------------------------------
# Capture VM names from stage 2
# ------------------------------------------------------------------------------
VM1=$(cd 02-vwan && terraform output -raw vm1_name)
VM2=$(cd 02-vwan && terraform output -raw vm2_name)
VM3=$(cd 02-vwan && terraform output -raw vm3_name)

# ------------------------------------------------------------------------------
# Wait for nginx to be active on each VM before validating
# az vm run-command replaces SSM — poll until nginx reports active
# ------------------------------------------------------------------------------
wait_for_nginx() {
  local vm_name=$1
  local rg=$2
  local max=36
  local delay=10

  echo "Waiting for nginx on ${vm_name}..."
  for ((i=1; i<=max; i++)); do
    STATUS=$(az vm run-command invoke \
      --resource-group "${rg}" \
      --name "${vm_name}" \
      --command-id RunShellScript \
      --scripts "systemctl is-active nginx" \
      --query "value[0].message" -o tsv 2>/dev/null || true)

    if echo "${STATUS}" | grep -q "^active"; then
      echo "  nginx is active on ${vm_name}"
      return 0
    fi

    echo "  [${i}/${max}] not ready yet — retrying in ${delay}s"
    sleep "${delay}"
  done

  echo "ERROR: nginx never became active on ${vm_name}" >&2
  return 1
}

wait_for_nginx "${VM1}" "${RG}"
wait_for_nginx "${VM2}" "${RG}"
wait_for_nginx "${VM3}" "${RG}"

# ------------------------------------------------------------------------------
# Run cross-VNet validation
# ------------------------------------------------------------------------------
./validate.sh
