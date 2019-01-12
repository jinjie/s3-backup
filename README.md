# S3 Backup Script

Script I used on servers I manage to backup data files and mysql dump to S3. 

No fuss, just works.

## Requirements:

[AWS Command Line Interface](https://aws.amazon.com/cli/)

`pip install awscli`

## How to use

1. Create a new s3 or use an existing one.
2. Create a new user with access key 
3. Run `aws configure` to configure access key. This will create a file `credentials` in ~/.aws/
4. Copy `config.example` to `config` and edit to suit your needs
4. Configure cron job to run this script based on your backup schedule.

## Folder structure

Backup files will be saved in the bucket with the following structure.

```
<s3-bucket-name>/
  +-- <server-hostname>/
  |   +-- data/   
  |   +-- mysql/
  +-- <server-hostname>/
      +-- data/   
      +-- mysql/
```