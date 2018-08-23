#!/bin/bash 
#Name Approver Owner
#Passing Run Time Arguments
echo "InstanceId: $1"


#getting instance ids 


iName=$(aws ec2 describe-instances --instance-id $1 --query 'Reservations[].Instances[].[Tags[?Key==`Name`].Value | [0]]' --output text)
iApprover=$(aws ec2 describe-instances --instance-id $1 --query 'Reservations[].Instances[].[Tags[?Key==`Approver`].Value | [0]]' --output text)
iOwner=$(aws ec2 describe-instances --instance-id $1 --query 'Reservations[].Instances[].[Tags[?Key==`Owner`].Value | [0]]' --output text) 
echo $iName , $iApprover , $iOwner
echo "----------------------------------------------------------------"


#getting volume ids attached to the instances   
for j in $(aws ec2 describe-volumes --filters Name=attachment.instance-id,Values=$1 --query 'Volumes[].{ID:VolumeId}' --output text); do

echo $j

# checking there tag values   
vName=$(aws ec2 describe-volumes --volume-id $j --query 'Volumes[].[Tags[?Key==`Name`].Value | [0]]' --output text)   
vApprover=$(aws ec2 describe-volumes --volume-id $j --query 'Volumes[].[Tags[?Key==`Approver`].Value | [0]]' --output text)
vOwner=$(aws ec2 describe-volumes --volume-id $j --query 'Volumes[].[Tags[?Key==`Owner`].Value | [0]]' --output text) 



# if there are no tag values assign instance tag values to  the volumes            
if [ "$iName" != "None" ] && [ "$vName" == "None" ]; then              
aws ec2 create-tags --resources $j --tags Key=Name,Value=$iName        
fi
if [ "$iApprover" != "None" ] && [ "$vApprover" == "None" ]; then              
aws ec2 create-tags --resources $j --tags Key=Approver,Value=$iApprover        
fi
if [ "$iOwner" != "None" ] && [ "$vOwner" == "None" ]; then               
aws ec2 create-tags --resources $j --tags Key=Owner,Value=$iOwner        
fi
   
   echo $vName , $vApprover , $vOwner
   
echo "Tagging Successfully Completed !!"
   done
done
