#!/bin/bash
set -euo pipefail

# ================================================================================
# validate.sh — Cross-VNet connectivity checks for azure-wlan
# Uses az vm run-command invoke (Azure equivalent of SSM send-command)
# Each VM curls the other two; expects "{ip} - Welcome to VNet {region}"
# ================================================================================

# ------------------------------------------------------------------------------
# Load resource group and VM names from Terraform outputs
# ------------------------------------------------------------------------------
RG=$(cd 01-networking && terraform output -raw resource_group_name)
VM1=$(cd 02-vwan && terraform output -raw vm1_name)
VM2=$(cd 02-vwan && terraform output -raw vm2_name)
VM3=$(cd 02-vwan && terraform output -raw vm3_name)

VM1_IP=$(cd 02-vwan && terraform output -raw vm1_private_ip)
VM2_IP=$(cd 02-vwan && terraform output -raw vm2_private_ip)
VM3_IP=$(cd 02-vwan && terraform output -raw vm3_private_ip)

# ------------------------------------------------------------------------------
# Wait for nginx to be active before curling — safe to call standalone
# ------------------------------------------------------------------------------
wait_for_nginx() {
  local vm_name=$1
  local max=36
  local delay=10

  echo "Waiting for nginx on ${vm_name}..."
  for ((i=1; i<=max; i++)); do
    STATUS=$(az vm run-command invoke \
      --resource-group "${RG}" \
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

# ------------------------------------------------------------------------------
# run_check: invoke curl from source VM to target IP, print result
# ------------------------------------------------------------------------------
run_check() {
  local src_vm=$1
  local target_ip=$2
  local label=$3

  echo "  ${src_vm} → ${label} (${target_ip})"
  RESULT=$(az vm run-command invoke \
    --resource-group "${RG}" \
    --name "${src_vm}" \
    --command-id RunShellScript \
    --scripts "curl -s --connect-timeout 5 http://${target_ip}" \
    --query "value[0].message" -o tsv 2>/dev/null \
    | awk '/\[stdout\]/{found=1; next} /\[stderr\]/{found=0} found && NF')

  if [ -n "${RESULT}" ]; then
    echo "    OK: ${RESULT}"
  else
    echo "    FAIL: no response from ${target_ip}" >&2
    return 1
  fi
}

# ------------------------------------------------------------------------------
# Readiness check — only needed if running validate.sh standalone
# (apply.sh already waits; this is a no-op if nginx is already active)
# ------------------------------------------------------------------------------
wait_for_nginx "${VM1}"
wait_for_nginx "${VM2}"
wait_for_nginx "${VM3}"

# ------------------------------------------------------------------------------
# Cross-VNet curl checks — 6 total (full mesh)
# ------------------------------------------------------------------------------
echo ""
echo "=== Validating cross-VNet connectivity ==="
echo ""

echo "[${VM1}]"
run_check "${VM1}" "${VM2_IP}" "${VM2}"
run_check "${VM1}" "${VM3_IP}" "${VM3}"

echo "[${VM2}]"
run_check "${VM2}" "${VM1_IP}" "${VM1}"
run_check "${VM2}" "${VM3_IP}" "${VM3}"

echo "[${VM3}]"
run_check "${VM3}" "${VM1_IP}" "${VM1}"
run_check "${VM3}" "${VM2_IP}" "${VM2}"

echo ""
echo "=== All checks passed ==="
