#!/bin/bash
echo "Running fetch_a_ABCD script using bash"
echo "Expected usage: fetch_a_ABCD Study_Directory Subject_ID type image_suffix S3_path"
if [ "$#" -ne 5 ]; then
  echo "Illegal number of parameters provided"
  exit 10
fi

dir=$1
sub=$2
type=$3
suff=$4
s3=$5

echo "Command Args Provided: Subjects_Dir=$dir GUID=$sub type=$type suffix=$suffS3_path=$s3"
echo ""

#Check or make Subjects_dir
if [ -d $dir ] ; then
  echo "Project Directory exists, skipping directory creation"
else
  echo "Creating project directory $dir"
  mkdir $dir
fi

#Check or make Subject w/in Subjects_dir
if [ -d $dir/$sub ] ; then
  echo "subject Directory exists, skipping directory creation"
else
  echo "Creating subject directory $sub"
  mkdir $dir/$sub
fi

#Check or make type directory w/in Subjects_dir/subject
if [ -d $dir/$sub/$type ] ; then
  echo "type Directory exists, skipping directory creation"
else
  echo "Creating type directory $type"
  mkdir $dir/$sub/$type
fi

#Check or make temp directory w/in Subjects_dir/subject/type
if [ -d $dir/$sub/$type/tmp ] ; then
  echo "temp Directory exists, skipping directory creation"
else
  echo "Creating temp directory "
  mkdir $dir/$sub/$type/tmp
fi

#Get file from s3, if it's not here
if [ -f $dir/$sub/$type/tmp/$sub.tgz ] ; then
  echo ""
  echo "File $dir/$sub/$type/tmp/$sub.tgz exists, not fetching"
else
  echo ""
  echo "Fetching from $s3"
  aws s3 cp $s3 $dir/$sub/$type/tmp/$sub.tgz --profile NDA
  if [ $? -ne 0 ] ; then
    echo "Fetch from S3 failed, exiting"
    exit 1
  fi
fi


#extract this file
tar xvzf $dir/$sub/$type/tmp/$sub.tgz -C $dir/$sub/$type/tmp --strip-components 3

#make NIFTI
echo "dcm2nii"
/Applications/MRIcron/dcm2nii -o $dir/$sub/$type/tmp `ls $dir/$sub/$type/tmp/*/*.dcm | head -1`

# Move NIFTI to final location
echo ""
echo "Moving nifti"
mv `ls $dir/$sub/$type/tmp/*/*.nii.gz` $dir/$sub/$type/${sub}_${suff}.nii.gz
if [ $? -ne 0 ] ; then
  echo "NIFTI move failed,  exiting"
  exit 2
fi

# Move DICOM's to storage location
echo "Moving dicom"
if [ -d $dir/$sub/$type/${sub}_${suff}_dicom ] ; then
  echo "dicom Directory exists, skipping directory creation"
else
  echo "Creating dicom directory "
  mkdir $dir/$sub/$type/${sub}_${suff}_dicom
fi
mv $dir/$sub/$type/tmp/*/*.dcm $dir/$sub/$type/${sub}_${suff}_dicom
if [ $? -ne 0 ] ; then
  echo "dicom move failed,  exiting"
  exit 3
fi

# Move json file to accompany image
echo "Moving json"
mv $dir/$sub/$type/tmp/*.json $dir/$sub/$type/${sub}_${suff}.json
if [ $? -ne 0 ] ; then
  echo "json move failed,  exiting"
  exit 4
fi

#Cleanup
echo ""
echo "Clean up"
rm -r $dir/$sub/$type/tmp
if [ $? -ne 0 ] ; then
  echo "clean up failed, exiting"
  exit 5
fi

#The End
echo ""
echo "The End"
exit 0







