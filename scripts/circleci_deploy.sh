#!/usr/bin/env sh

set -e -u -o pipefail

# example usage
# ./scripts/circleci_deploy.sh test dev KUBE_TOKEN_TEST_DEV
# ./scripts/circleci_deploy.sh test staging KUBE_TOKEN_TEST_STAGING

environment_name=$1
deployment_name=$2
kube_token=$3
sentry_dsn=$4

echo "kubectl configure credentials"
kubectl config set-credentials "circleci_${environment_name}_${deployment_name}" --token="${kube_token}"

echo "kubectl configure context"
kubectl config set-context "circleci_${environment_name}_${deployment_name}" --cluster="$KUBE_CLUSTER" --user="circleci_${environment_name}_${deployment_name}" --namespace="formbuilder-platform-${environment_name}-${deployment_name}"

echo "kubectl use circleci context"
kubectl config use-context "circleci_${environment_name}_${deployment_name}"

echo "apply kubernetes changes to ${environment_name} ${deployment_name}"

CONFIG_FILE="/tmp/fb-av-$environment_name-$deployment_name.yaml"

helm template deploy/fb-av-chart \
  --set app_image_tag="APP_${CIRCLE_SHA1}" \
  --set circleSha1=$CIRCLE_SHA1 \
  --set platformEnv=$environment_name \
  --set environmentName="${environment_name}-${deployment_name}" \
  --set sentry_dsn=$sentry_dsn \
  > $CONFIG_FILE

kubectl apply -f $CONFIG_FILE -n formbuilder-platform-$environment_name-$deployment_name
