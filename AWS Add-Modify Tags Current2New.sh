#!/bin/bash
 
	echo "Please give one or more instance ids (for all instances give Caps 'ALL')"
		read inst

instance=( $inst )
if [ "$instance" = "ALL" ]; then
	instance=" "
fi
	echo "Please give the Tag-Key to be modified eg. Owner CurrentValue NewValue :"
		read tags
	arg=( $tags )
  for i in "${instance[@]}"
  do
	iName=$(aws ec2 describe-instances --instance-id $i --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value | [0]]' --output text)
	keys=( $(aws ec2 describe-instances --instance-id $i --query 'Reservations[].Instances[].[Tags | [].Key]' --output text) )
	echo Tag-Keys Present in EC2: ${keys[@]}
	values=( $(aws ec2 describe-instances --instance-id $i --query 'Reservations[].Instances[].[Tags | [].Value]' --output text) )
	echo Respective Values Present in EC2: ${values[@]}
		printf "\nInstance = "$i"\n"
		
#getting volume ids attached to the instances   
  for j in $(aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=$i --query 'Volumes[].{ID:VolumeId}' --output text); do
  count=0
    vDevice=$(aws ec2 describe-volumes --volume-id $j --query Volumes[].Attachments[].Device --output text)
	echo "----------------------------------------"
		echo "VolumesAttached = "$j
	echo "----------------------------------------"
  for key in ${keys[@]}
  do
		echo Matching Passed Tag-Key: ${arg[o]} with EC2 Key: $key
		val="${values[count]}"
				count=$count+1
		if [ "${arg[0]}" = "$key" ]; then
		#&& [ "${arg[1]}" = "$val" ]; then
		aws ec2 create-tags --resources $j --tags Key=${arg[0]},Value=${arg[2]}
		aws ec2 create-tags --resources $j --tags Key=Name,Value="ebs-"$iName"-"$vDevice  
		echo "MATCH FOUND & EBS TAGGED---------->>"
		fi
  done
  done
  done
		printf "\nTagging Completed Successfully !!\n"