#!/bin/bash 

echo "Please give one or more instance ids (for all instances give 'ALL' in CAPS)"
read inst

echo "Please give the Tag-Keys to be copied from the above EC2 Instance(followed by spaces):"
read line
tags=( $line )

if [ "$inst" = "ALL" ]; then
	inst=
	instances=( $(aws ec2 describe-instances --instance-id $inst --query 'Reservations[].Instances[].InstanceId' --output text) )
else

instances=( $(aws ec2 describe-instances --instance-id $inst --query 'Reservations[].Instances[].InstanceId' --output text) )

fi

echo No. Of Instances To Be Copied to EBS : ${instances[@]}

# looping through each instance
for instance in "${instances[@]}"
do
    printf "\n***InstanceID = "$instance"***\n"
	  keys=( $(aws ec2 describe-instances --instance-id $instance --query 'Reservations[].Instances[].[Tags | [].Key]' --output text) )
	  values=( $(aws ec2 describe-instances --instance-id $instance --query 'Reservations[].Instances[].[Tags | [].Value]' --output text) )
	# get the instance name
	instanceName=$(aws ec2 describe-instances --instance-id $instance --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value | [0]]' --output text)
	# get the volumes for the instance
	volumes=( $(aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=$instance --query 'Volumes[].{ID:VolumeId}' --output text) )

	# loop through each volume
	for volume in "${volumes[@]}"
	do
		dev=$(aws ec2 describe-volumes --volume-id $volume --query Volumes[].Attachments[].Device --output text)
		device=${dev:5:7}
		printf "\n"
		echo "----------------------------------------"
		echo "For Volume: $volume"
		echo "----------------------------------------"
		# loop through each tag provided by the user
		for tag in "${tags[@]}"
		do
			printf "\nChecking Tag...................: "$tag"\n"
			count=0
			for value in "${values[@]}"
			do
				key="${keys[count]}"
				count=$count+1
				echo "Key: "$key", Value: "$value
				if [[ $tag = $key ]]; then
					
					aws ec2 create-tags --resources $volume --tags Key=$key,Value=$value
				fi
			done
			echo "Parameter: '"$tag"' Of Argument Matches with EC2 $key value= '"$value"'"
				echo "Completed Tagging Argument '"$tag"'to value: '"$value"'"
		done
		aws ec2 create-tags --resources $volume --tags Key=Name,Value="ebs-"$instanceName"-"$device
	done
done
 printf "\nTagging Completed Successfully !!\n"