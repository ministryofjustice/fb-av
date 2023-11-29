[![CircleCI](https://circleci.com/gh/ministryofjustice/clamav/tree/main.svg?style=svg)](https://circleci.com/gh/ministryofjustice/clamav/tree/main)

# ClamAV

ClamAV daemon, using the [official](https://github.com/Cisco-Talos/clamav/blob/main/README.Docker.md) docker image.
It builds a release preloaded with signature databases and runs `freshclam` periodically in the background,
updating the virus signatures. `clamd` itself is listening on exposed port `3310`.

On your main container, you still need to install `clamav-daemon` :

`apt-get install clamav-daemon -y`

Then you can scan a file with: `clamdscan -c clamd.container.conf --stream file`

clamd.container.conf being:
```
TCPSocket 3310
TCPAddr localhost # or wherever you setup this container
```

ClamAV have databases that can be downloaded manually, these can be found here:
- http://database.clamav.net/main.cvd
- http://database.clamav.net/daily.cvd
- http://database.clamav.net/bytecode.cvd

The ClamAV moderators limited the ability to download these files via ways such as `wget` and `curl` due the enormous number of daily downloads, more details [here](https://www.mail-archive.com/clamav-users@lists.clamav.net/msg49810.html).

## Run Locally
`docker run -p 3310:3310 [image reference]`
or
`docker-compose up`

**From inside root of fb-user-filestore:**

Test a file - okay

`clamdscan -c config/clamd/development.conf --stream --no-summary README.md`

Test downloaded (file downloaded from [eicar.org](https://www.eicar.org/)) - virus found

`clamdscan -c config/clamd/development.conf --stream --no-summary ~/Downloads/eicar.com.txt`

## Deployment

Continuous Integration (CI) is enabled on this project via CircleCI.

On merge to main, tests are executed and if green deployed to the test environment. This build can then be promoted to production.

## Monitoring

Container logs are shipped to Kibana like every other app, however there is no alerting facility there.
