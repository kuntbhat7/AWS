#!/bin/bash 
#Name Approver Owner

#getting instance ids 

if [ $# -eq 0 ]; then
  instance=
else
  instance="$1"
fi


#getting instance ids 
for i in $(aws ec2 describe-instances --instance-id $instance --query 'Reservations[].Instances[].InstanceId' --output text); do
printf "\nInstance = "$i"\n"

# getting tag values based on key values


iName=$(aws ec2 describe-instances --instance-id $i --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value | [0]]' --output text)
iApprover=$(aws ec2 describe-instances --instance-id $i --query 'Reservations[].Instances[].[Tags[?Key==`Approver`].Value | [0]]' --output text)
iOwner=$(aws ec2 describe-instances --instance-id $i --query 'Reservations[].Instances[].[Tags[?Key==`Owner`].Value | [0]]' --output text) 
echo "CurrentName = "$iName , "CurrentApprover = "$iApprover , "CurrentOwner = "$iOwner
echo "--------------------------------------------------------------------------------"



#getting volume ids attached to the instances   
for j in $(aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=$i --query 'Volumes[].{ID:VolumeId}' --output text); do


echo "VolumesAttached = "$j

# checking there tag values   
vName=$(aws ec2 describe-volumes --volume-id $j --query 'Volumes[].[Tags[?Key==`Name`].Value | [0]]' --output text)   
vApprover=$(aws ec2 describe-volumes --volume-id $j --query 'Volumes[].[Tags[?Key==`Approver`].Value | [0]]' --output text)
vOwner=$(aws ec2 describe-volumes --volume-id $j --query 'Volumes[].[Tags[?Key==`Owner`].Value | [0]]' --output text) 
vDevice=$(aws ec2 describe-volumes --volume-id $j --query Volumes[].Attachments[].Device --output text)


# if there are no tag values assign instance tag values to  the volumes            
if [ "$iName" != "None" ] && [ "$vName" == "None" ]; then              
aws ec2 create-tags --resources $j --tags Key=Name,Value="ebs-"$iName"-"$vDevice       
fi
if [ "$iApprover" != "None" ] && [ "$vApprover" == "None" ]; then              
aws ec2 create-tags --resources $j --tags Key=Approver,Value=$iApprover        
fi
if [ "$iOwner" != "None" ] && [ "$vOwner" == "None" ]; then               
aws ec2 create-tags --resources $j --tags Key=Owner,Value=$iOwner        
fi
   
   echo "AssignedName = "$iName , "AssignedApprover = "$iApprover , "AssignedOwner = "$iOwner
echo "--------------------------------------------------------------------------------"
   done
   done
   printf "\n\n"
echo "Tagging Completed Successfully !!"