if [ -z "$1" ]; then
   echo "Usage: upload.sh <file>"
   exit 1
fi

tmpfile=".upload-temp.bin"

dd if=/dev/zero of=$tmpfile bs=2M count=1
dd if=$1 of=$tmpfile conv=notrunc

minipro -p EN25QH16 -I -w $tmpfile
rm $tmpfile
