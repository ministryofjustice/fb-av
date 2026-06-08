[![CircleCI](https://circleci.com/gh/ministryofjustice/clamav/tree/main.svg?style=svg)](https://circleci.com/gh/ministryofjustice/clamav/tree/main)

# ClamAV

ClamAV daemon, using the [official](https://github.com/Cisco-Talos/clamav/blob/main/README.Docker.md) docker image.
It builds a release preloaded with signature databases and runs `freshclam` periodically in the background,
updating the virus signatures. `clamd` itself is listening on exposed port `3310`.

## Run Locally
```bash
docker compose up
```

### Test locally
```bash
bash test-av.sh
```

This will stream to the local docker instance
1. This README
2. the eidcar test signature, which is built and held in memory

Echoing the outputs.

## Deployment

Continuous Integration (CI) is enabled on this project via CircleCI.

On merge to main, tests are executed and if green deployed to the test environment. This build can then be promoted to production.

## Monitoring

Container logs are shipped to Kibana like every other app, however there is no alerting facility there.
