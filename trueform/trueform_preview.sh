file=$1
export TFHOSTPATH=/tfpreview
export TFPCPATH='\\192.168.110.30\tfpreview'
export TFWEBPATH='https://192.168.110.30/ext/tfpreview'

export device=$2 
export cpdate=`date +%s`

cat $file | awk  \
	'BEGIN {
		print "%cpBegin";
		print "%cpParam:-sVGL_SPOOL_PREVIEW";
		print "%cpUserData:vglinvp";
		print "%cpUsrDefData:";
		print "%cpUsrDefOptions:N";
		print "%cpDate:" ENVIRON["cpdate"];
		print "%cpUser:" ENVIRON["USER"];
		print "%cpEnd";
		}
		{print $0}
		'\ | tee /tmp/processed.txt | lpr -P $device

prospl trueform/trueform_preview $USER$cpdate.pdf

