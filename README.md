# ABCDfetch
Some tools for local fetching ABCD data for local processing

## fetch_a_ABCD
This shell script takes a S3 path, fetches from S3, and prepared the data for local use in a BIDS-like representation

Usage: 
  fetch_a_ABCD.sh Study_Directory Subject_ID image_suffix type S3_path
  
  For example:
    ./fetch_a_ABCD test sub1 anat T1w s3://NDAR_Central_1/submission_12844/fast-track/mssm/NDARINV007W6H7B_baselineYear1Arm1_ABCD-T1_20170224175304.tgz
    
This command will:
* Create, if needed, a 'Study_Directory' in the local directory from where the command is run [Note: This should be updated to requiring a full path...]
* Create, if needed, a 'Subject_ID' subdirectory in the Study_Directory
* Create, if needed, a directory called 'type' ('anat' in this example). [Note, it is currently up to the user to name this in BIDS compliant fashion]
* Temporarily creates a 'tmp' directory within this 'type' subdirectory
* Copies the named S3 file into this temporary directory
* unzip's, and dcm2nii's the downloaded S3 file
* Stores the nii.gz version in the 'type' directory, named 'Subject_ID'_'image_suffix'.nii.gz. In this example case, in the 'anat' directory, we have a file called sub1_T1w.nii.gz. [Note, it is currently up to the user to name this in BIDS compliant fashion]
* The dicom's are stored in the 'type' directory in a subdirectory called 'Subject_ID'_'image_suffix_dicom, and the json file is paired with the image file in the 'type' directory
* Finally, the 'tmp' directory is cleaned out

## Prerequsites

This is a bash script. The following are assumes to be present:
* AWS CLI (Amazon webservices command line interface)
* Chris Rorden's dcm2nii (currently hard coded to /Applications/MRIcron/dcm2nii, would be nice to generalize!)
* NDA Access permission to ABCD, and an 'NDA' profile in your AWS configuration (more about this elsewhere)
* My workflow for NDA access includes use of the NDA downloadmanager commandline tool

## Warning: 
I'm not really a programmer, and this is a virtually complete hack; would welcome any cleaning and improvements...
