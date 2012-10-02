fpdoccmd="fpdoc --package=fpos --output=chm --auto-toc --auto-index --make-searchable"

for f in `ls ../kernel/*.pas`; do
  # kernel.pas is a program, not a unit!
  if [ $f != "../kernel/kernel.pas" ]; then
    fpdoccmd="$fpdoccmd --input=$f"
  fi
done

for f in `ls *.xml`; do
  fpdoccmd="$fpdoccmd --descr=$f"
done

# call fpdoc
$fpdoccmd
