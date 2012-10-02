cd ../kernel

for fin in `ls *.pas`; do
  # kernel.pas is a program, not a unit!
  if [ $fin != "kernel.pas" ]; then
    # change the file extension to .xml
    fout=`echo $fin | sed 's/\..*//'`.xml
    # call makeskel
    makeskel --package=fpos --input=$fin --output=../doc/$fout
  fi
done

cd ../doc
