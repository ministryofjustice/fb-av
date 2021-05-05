[![CircleCI](https://circleci.com/gh/ministryofjustice/clamav/tree/master.svg?style=svg)](https://circleci.com/gh/ministryofjustice/clamav/tree/master)

# clamav

ClamAV daemon as a Docker image. It *builds* with a current virus database and
*runs* `freshclam` in the background constantly updating the virus signature database. `clamd` itself
is listening on exposed port `3310`.

On your main container, you still need to install `clamav-daemon` :

`apt-get install clamav-daemon -y`

Then you can scan a file with: `clamdscan -c clamd.container.conf --stream file`

clamd.container.conf being:
```
TCPSocket 3310
TCPAddr localhost # or wherever you setup this container
```

---

copied from https://github.com/mko-x/docker-clamav

ClamAV have databases that can be downloaded manually, these can be found here:
- http://database.clamav.net/main.cvd
- http://database.clamav.net/daily.cvd
- http://database.clamav.net/bytecode.cvd

The ClamAV moderators limited the ability to download these files via ways such as `wget` and `curl` due the enormous number of daily downloads, more details [here](https://www.mail-archive.com/clamav-users@lists.clamav.net/msg49810.html).

As a result, we have built a ECR image that holds the 3 files we require, `main.cvd`, `daily.cvd` and `bytecode.cvd`.
The [Dockerfile](Dockerfile) copies these 3 files from the image, freshclam should update these databases in the background, however, any issues with the clamav databases might be resolved by manually downloading the files and updating the `fb-av:base` ECR image.

## Run Locally
`docker run -p 3310:3310 [image reference]`

*From inside root of fb-user-filestore.*

Test a file - okay

`clamdscan -c config/clamd/development.conf --stream --no-summary README.md`

Test downloaded (file downloaded from [eicar.org](https://www.eicar.org/)) - virus found

`clamdscan -c config/clamd/development.conf --stream --no-summary ~/Downloads/eicar.com.txt`

## Deployment

Continuous Integration (CI) is enabled on this project via CircleCI.

On merge to master tests are executed and if green deployed to the test environment. This build can then be promoted to production

## Monitoring

Container logs are shipped to Kibana like every other app, however there is no alerting facility there. Therefore there is a cron job which triggers the `clamav_check.rb` script daily. This does a very rudimentary check to see if the daily updates completed successfully and if not sends an alert to [Sentry](https://sentry.service.dsd.io/).

It currently bundles all the log updates per day, therefore if an update in the morning is successful but an update in the evening is not, the alert will not be sent until the next day.
