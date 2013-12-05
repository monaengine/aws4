aws4
====

Amazon Web Services Simple Snapshot Script

aws4 is a simple bash script that allows you to automatically create snapshots of your ec2 instance.

This is a young project and need help to improve it.
All contributions will be welcome

====
Prerequisites

The awss4 package should work on aws-cli.

https://github.com/aws/aws-cli

====
Installation

you have to create a folder in /var/log with the command

# mkdir /var/log/backup

clone the project in your /root

set the environment variables

AWS_ACCESS_KEY=

AWS_SECRET_KEY=

EC2_URL=

and the variables in the script aws4.sh:

MY_INSTANCE_ID =

MAIL_RECIPIENTS =


Now you can launch aws4.
