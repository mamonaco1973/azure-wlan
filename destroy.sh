#!/bin/bash
set -euo pipefail

# ================================================================================
# destroy.sh — Reverse two-stage teardown for azure-wlan
# Stage 2 destroyed first (VMs, vWAN depend on stage 1 networking)
# Stage 1 destroyed second (VNets, NAT Gateways, resource group contents)
# ================================================================================

# ------------------------------------------------------------------------------
# Capture stage 1 outputs before destroying stage 2
# Required because stage 2 destroy needs the same -var values used during apply
# ------------------------------------------------------------------------------
RG=$(cd 01-networking && terraform output -raw resource_group_name)

VNET1_ID=$(cd 01-networking && terraform output -raw vnet1_id)
VNET2_ID=$(cd 01-networking && terraform output -raw vnet2_id)
VNET3_ID=$(cd 01-networking && terraform output -raw vnet3_id)

SUBNET1_ID=$(cd 01-networking && terraform output -raw subnet1_id)
SUBNET2_ID=$(cd 01-networking && terraform output -raw subnet2_id)
SUBNET3_ID=$(cd 01-networking && terraform output -raw subnet3_id)

# ------------------------------------------------------------------------------
# Stage 2 destroy: vWAN hubs, VMs, NSGs
# ------------------------------------------------------------------------------
cd 02-peering
terraform destroy -auto-approve \
  -var="resource_group_name=${RG}" \
  -var="vnet1_id=${VNET1_ID}" \
  -var="vnet2_id=${VNET2_ID}" \
  -var="vnet3_id=${VNET3_ID}" \
  -var="subnet1_id=${SUBNET1_ID}" \
  -var="subnet2_id=${SUBNET2_ID}" \
  -var="subnet3_id=${SUBNET3_ID}"
cd ..

# ------------------------------------------------------------------------------
# Stage 1 destroy: networking (VNets, subnets, NAT Gateways, resource group)
# ------------------------------------------------------------------------------
cd 01-networking
terraform destroy -auto-approve
cd ..
