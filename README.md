# rancher-s3-backup

A simple docker image that syncs all rancher-data to an s3 bucket.

In a “normal” Rancher setup, rancher uses an internal etcd and stores it into /var/lib/rancher which could be backed up simply by bind-mounting it as a volume and then copying it to somewhere else.

This image makes it's easier for you to just by bind-mounting /var/lib/rancher-data to the host then let it work!

Currently the containr does a sync job everyday at midnight, a tar archive with a timestamp will be uploaded to s3 bucket.

I this proves valid, future work will allow setting up the frequency of the backup as well as a restoration methodology.


## Example:

A simple docker-compose file that contains both this docker image as a service and rancher.

```
version: "3"
services:
  rancher-s3-backup:
    image: salalemdockerhub/rancher-s3-backup:latest
    volumes:
     - /Users/firas/rancher-data:/root/rancher-data
    environment:
     - aws_key=$S3_RANCHER_BACKUP_ACCESS_TOKEN
     - aws_secret=$S3_RANCHER_BACKUP_SECRET
     - DEST_S3=$S3_RANCHER_BACKUP_BUCKET_NAME

  rancher:
    image: rancher/rancher:v2.1.1
    restart: unless-stopped
    volumes:
      - /Users/firas/rancher-data:/var/lib/rancher
    ports:
      - "80:80"
      - "443:443"

```
