#!/usr/bin/env bash

set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No color

pass() {
  echo -e "${GREEN}✔ $1${NC}"
}

fail() {
  echo -e "${RED}✖ $1${NC}"
  exit 1
}

echo "🔍 Validating Kubernetes resources..."

# 1. Deployments
kubectl get deployment wordpress >/dev/null 2>&1 || fail "wordpress deployment not found"
kubectl get deployment wordpress-mysql >/dev/null 2>&1 || fail "wordpress-mysql deployment not found"
pass "Deployments exist"

# 2. Services
kubectl get svc wordpress >/dev/null 2>&1 || fail "wordpress service not found"
kubectl get svc wordpress-mysql >/dev/null 2>&1 || fail "wordpress-mysql service not found"
pass "Services exist"

# 3. PVCs
kubectl get pvc wp-pv-claim >/dev/null 2>&1 || fail "PVC wp-pv-claim not found"
kubectl get pvc mysql-pv-claim >/dev/null 2>&1 || fail "PVC mysql-pv-claim not found"
pass "PVCs exist"

# 4. ConfigMaps
wordpress_keys=$(kubectl get configmap wordpress -o json | jq -r '.data | keys[]' || echo "")
[[ "$wordpress_keys" == *"host"* && "$wordpress_keys" == *"user"* ]] || fail "wordpress ConfigMap missing expected keys"
pass "wordpress ConfigMap contains required keys"

mysql_keys=$(kubectl get configmap wordpress-mysql -o json | jq -r '.data | keys[]' || echo "")
[[ "$mysql_keys" == *"database"* && "$mysql_keys" == *"user"* ]] || fail "wordpress-mysql ConfigMap missing expected keys"
pass "wordpress-mysql ConfigMap contains required keys"

# 5. Secret
secret_keys=$(kubectl get secret database -o json | jq -r '.data | keys[]' || echo "")
[[ "$secret_keys" == *"user-password"* && "$secret_keys" == *"root-password"* ]] || fail "database secret missing expected keys"
pass "Secret database contains required keys"

# 6. Ingress
kubectl get ingress wordpress >/dev/null 2>&1 || fail "Ingress wordpress not found"
pass "Ingress exists"

# 7. WordPress HTTP check
echo "🌐 Testing WordPress via port-forward..."
kubectl port-forward svc/wordpress 8080:80 >/dev/null 2>&1 &
PORT_FORWARD_PID=$!
sleep 10

STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/wp-admin/install.php)
if [[ "$STATUS_CODE" == "200" ]]; then
  pass "WordPress returned HTTP 200 OK"
else
  fail "WordPress did not return 200 OK (got $STATUS_CODE)"
fi

kill -9 $PORT_FORWARD_PID

echo -e "\n${GREEN}✅ All checks passed!${NC}"
