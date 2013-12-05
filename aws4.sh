#!/bin/sh
source /etc/profile
 
MY_INSTANCE_ID=
LOG="/var/log/backup/ec2-snapshot_$(date +%Y%m%d).log"
VOLUME_LIST="/root/script/volume_list"
MAIL_RECIPIENTS=

#
# Get active/in-use volume-id for current instance-id
#
ec2-describe-volumes --filter attachment.instance-id=$MY_INSTANCE_ID --filter status=in-use | grep VOLUME | awk '{ print $2 }' > $VOLUME_LIST
 
sync
 
#
# Create snapshot
#
echo "******* Start create EBS Snapshot for EC2 istance - $(date +%m-%d-%Y-%T)" >> $LOG
 
DATE=$(date +'%Y%m%d_%H%M')
 
for volume in $(cat $VOLUME_LIST); do

   VOLUMENAME=$(ec2-describe-volumes --filter attachment.instance-id=$MY_INSTANCE_ID --filter volume-id=$volume | grep Name | awk '{ print $5 }') 

   DESC="Snapshot for volume $VOLUMENAME in date $DATE"

   SNAP_NAME="S_"$VOLUMENAME"_"$DATE
 
   SNAP_ID=$(ec2-create-snapshot -d "$DESC" $volume | awk '{ print $2 }')

   echo "start creating snapshot for the volume: $VOLUMENAME \($volume) with description: $DESC \($SNAP_ID)" >> $LOG

   echo $SNAP_ID 

   ec2-create-tags $SNAP_ID --tag Name="$SNAP_NAME"

   SNAP_STATUS=$(ec2-describe-snapshots --filter description="$DESC" | grep "SNAPSHOT"  | awk '{ print $4 }')

      while [ "$SNAP_STATUS" != 'completed' ]; do

	  if [ "$SNAP_STATUS" = 'pending' ];
	  then
	  
			sleep 30
			SNAP_STATUS=$(ec2-describe-snapshots -region eu-west-1 --aws-access-key $ACCESS_KEY_ID --aws-secret-key $SECRET_ACCESS_KEY --filter description="$DESC" | grep "SNAPSHOT"  | awk '{ print $4 }')	

	  else
			echo "Snapshot $SNAP_ID $SNAP_NAME status $SNAP_STATUS " | mail -s "AWS EC2 snapshot KO" $MAIL_RECIPIENTS
			exit 1
		
	  fi
	
    done

    echo "status: $SNAP_STATUS" >> $LOG
	
    echo "" >> $LOG

 
done
 
echo "******* End Backup @ $(date +%m-%d-%Y-%T)" >> $LOG

cat $LOG | mail -s "AWS EC2 snapshot VegaCloud" $MAIL_RECIPIENTS

 
exit 0
