# # modify $pdflatex to use custom format
$pdflatex= 'pdflatex -synctex=1 --shell-escape -file-line-error %O %S';

# $aux_dir = 'buildmk'; # change localization of aux files
# $out_dir = 'outdir'; # change localization of final outputs


$clean_ext = "%R.bbl %R-mset.bib glg glstex %R-1.glstex loc %R.memo.dir/* %R.memo.dir mmz mmz.log soc snm synctex.gz synctex.gz(busy)";
