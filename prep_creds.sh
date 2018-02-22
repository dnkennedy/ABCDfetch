#!/bin/bash
echo "Running prep_creds"
echo "Expected usage: prep_creds NDA_UserName"
if [ "$#" -ne 1 ]; then
  echo "Illegal number of parameters provided"
  exit 10
fi
user=$1
initdir=$PWD
ndagood=0

# check if aws cli is available
echo "Checking for the aws commandline interface"
which aws
if [ $? -eq 0 ] ; then
  echo "aws cli found, proceeding"
else
  echo "aws cli not found, please install the aws cli and try again"
  exit 1
fi

# Check if there is an NDA aws credential persona
echo "Checking for NDA credential"
cd ~/.aws
grep NDA config
if [ $? -eq 0 ] ; then
  echo "NDA Personna found, proceeding"
  # Is it active?
  # Insert some test of NDA personna validity
  if [ $ndagood -eq 1 ] ; then
    echo "NDA access valid, proceed to using it."
    cd $initdir
    exit 0
  fi
else
  echo "NDA Personna not found, will try to create this"
  nonda = 1; 
fi

# The case here is either nonda or nda not good, eitherway, proceed
echo "Attempting to create NDA access"

# use downloadmanager to get credentials
#Check on existance of download manager
if [ ! -d ~/downloadmanager ] ; then
  echo "download manager not installed or where expected, sorry charlie..."
  cd $initdir
  exit 2
fi
cd ~/downloadmanager
echo "Running the NDA downloadmanager, you will be asked for your password"
java --add-modules java.se.ee -jar downloadmanager.jar -g tmpcred -u $user

#Check success
if [ ! $? -eq 0 ] ; then
  echo "downloadmanager credential acquisition failed, sorry"
  cd $initdir
  exit 3
fi

echo "Temporarily assuming that the cred generation works, there is a tmpcred file, lets go from here..."
# in principle, I'd run the 'aws configure --profile NDA' command, and provide the accessKey, secretKey via that
# and then do something to append the sessionToken to the end of the credentials file
# first task is to extract these three fields: accessKey, secretKey and sessionToken from the tmpcred file

# access key follows the '=' in the first line of tmpcred
a=`grep accessKey tmpcred`
accesskey="${a#accessKey=}"
echo " accesskey = $accesskey"

# secret key follows the '=' in the second line of tmpcred
a=`grep secretKey tmpcred`
secretkey="${a#secretKey=}"
echo " secretkey = $secretkey"

# session tokin follows the '=' in the third line of tmpcred
a=`grep sessionToken tmpcred`
sessiontoken="${a#sessionToken=}"
echo " sessionToken = $sessiontoken"

# Cleanup tmpcred
#rm tmpcred

# armed with these values, lets deal with the aws files
cd ~/.aws

# run the 'aws configure --profile NDA' command
echo "Configuring the NDA personna in your AWS credentials"

# this takes input from a user, that perhaps I can simulate in an input file.
if [ -e tmpinput ] ; then
  echo "tmpinput exists, not clobbering, I exit"
  exit 10
fi
echo $accesskey >> tmpinput
echo $secretkey >> tmpinput
echo "" >> tmpinput
echo "" >> tmpinput

aws configure --profile NDA < tmpinput
echo ""

rm tmpinput

#Adding 'aws_session_token = ' to the end of 'credentials' file
# IF there had been an NDA persone, we need to replace last file, if no NDA persona, we can just append.
if [ $nonda ] ; then
  echo "appending"
  # safty first
  cp credentials credentials.orig
  echo "aws_session_token = $sessiontoken" >> credentials
else
  echo "replacing"
  # safty first
  mv credentials credentials.orig
  tail -r credentials.orig | tail +2 | tail -r >> credentials
  echo "aws_session_token = $sessiontoken" >> credentials
fi


#The End
echo ""
echo "The End"
cd $initdir
exit 0







