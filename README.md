# ABCDfetch
Some tools for local fetching ABCD data for local processing

## fetch_a_ABCD
This shell script takes a S3 path, fetches from S3, and prepared the data for local use in a BIDS-like representation

Usage: 
  fetch_a_ABCD.sh Subjects_Dir GUID image_suffix type S3_path
  
  For example:
    ./fetch_a_ABCD test sub1 anat T1w s3://NDAR_Central_1/submission_12844/fast-track/mssm/NDARINV007W6H7B_baselineYear1Arm1_ABCD-T1_20170224175304.tgz