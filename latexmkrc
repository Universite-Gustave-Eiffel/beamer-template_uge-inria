
###############################################
# precompile-preamble_latexmkrc
###############################################
print "Latexmk rc file for using precompiled headers.\n",
      "John Collins.  V. 1.3. 3 Jan 2024.\n";
# John Collins jcc8 at psu dot edu

# To implement precompilation of preamble by the package mylatexformat.
# See the documentation for the package mylatexformat for more information.  
# Overall strategy:
#  1. At start of each run of *latex rule, copy (relevant part of) preamble
#     from the primary .tex file to a file with extension .hdr.
#  2. The base name of the header file has -latex, or -pdflatex, etc
#     appended to it.  That provides a flag as to which program is to be
#     used to make the .fmt file, and what program can use the .fmt file.
#  2. A cus-dep is defined to make a .fmt file from the corresponding .hdr
#     file.  It uses mylatexformat, and whichever of the -latex, -pdflatex,
#     etc strings appears at the end of its base name indicates which
#     program to use to create it.  (The -ini option is given to the
#     program to indicate that a .fmt file is to be made.)
#  4. Compilation of document: use .fmt file if it exists.
#     If not, inject a message into the log file, to indicate that the .fmt
#     is missing.  After the analysis of the results of the compilationi,
#     latexmk takes this as an indication that it should try to make the
#     .fmt file.
#
# Note that on an initial round of compilation, before the format file has
# been created, latexmk will do one round of compilation without a
# precompiled preamble.  After that latexmk creates the format file for the
# precompiled header.  Some trickery could be used to get the format file
# to be made first, but since this is a one-time-only issue, it's simpler
# not to do the trickery.
#
# Restriction: Doesn't work with spaces and/or non-ASCII characters in
# name of .tex file.

# STILL TO DO:
#
# 1. Get full dependency information for the step for making the format.
#    Ideally that needs support from latexmk, so as to use its
#    already existing tools.  (Complication: the usual way in which latexmk
#    determines dependencies from a run of a *latex type program assumes
#    that a correct run always generates an .aux file.  That's not the case
#    for "pdflatex -ini" etc.
#    I've done a sufficient job, I think, by using the -recorder option,
#    analyzing the resulting .fls file and using latexmk's documented
#    rdb_set_source subroutine.
# 2. On make of .fmt file, need ideally to use jobname = $root, to avoid
#    problems listed in
# https://tex.stackexchange.com/questions/19403/tikzs-externalization-and-mylatex
#   Then I would need to do some renaming; perhaps save fls and log files from
#   main run, compile the header, rename the fls, log and fmt files from this
#   run, and finally, put the original fls and log files in place.
#   Better, perhaps: Use subdirectories of auxdir, e.g., named fmt-latex,
#   fmt-pdflatex, etc, to contain .fmt file (and .hdr file), along with
#   suitable setting of search path (in variable TEXFORMATS).

# General settings 
# $out_dir = 'output';
# $aux_dir = 'auxdir';

$emulate_aux = 1;   # Avoid any problems with TeXLive, which doesn't
                    # natively support different aux and out directories.
$show_time = 1;     # Show diagnostics on timings, so as to make visible
                    # time savings due to use of preamble.

# Sub-second sleep time will work in latexmk v. 4.82 upwards.
# That gives excellent responsiveness when preview-continuous mode is used,
# and helps to enhance any significant gain in compilation time from the
# use of a precompiled preamble.
$sleep_time = 0.05;

$pdf_mode = 1;   
# Use pdflatex.  Note that xelatex and lualatex don't work
 # with precompiled preambles.

# Configuration for precompiled preamble:
$make_fmt = '%C %O -ini -output-directory=%V -jobname=%B "&%C" mylatexformat.ltx %S';

# I only arrange to use latex and pdflatex with precompiled preambles. 
# None of  lualatex, xelatex, and hilatex can use precompiled headers (from
# tests on 22 Dec 2023).  Each had different trouble, and this is a known
# problem. 
# But things did work for latex and pdflatex.

# Therefore only set things up for latex and pdflatex.
foreach my $engine ( 'latex', 'pdflatex' ) {
    say "Setting rules for $engine";
    ${$engine} = "internal mylatex %R $engine %O %S";
    push @generated_exts, "%R-$engine.*";
}

add_cus_dep( 'hdr', 'fmt', 0, make_fmt_cus_dep );

push @generated_exts, '%R-*.hdr', '%R-*.fmt';


#=================================================

sub make_fmt_cus_dep {
   my $path_base = $_[0];
   my ($base, $path) = fileparse($path_base);
   my $source = "$path_base.hdr";
   my $dest = "$path_base.fmt";
   my $fls = "$path_base.fls";
   my $engine = 'pdflatex';
   if ( $base =~ /-([^-]+)$/ ) {
      $engine = $1;
   }
   my $cmd = $make_fmt;
   $cmd =~ s/%C/$engine/g;
   my $options = '-recorder';
   if ($silent) { $options .= ' -interaction=batchmode'; }
   my $ret = Run_subst( $cmd, 2, $options, $source, $dest, $base  );
   my @source_files = get_fls_inputs( $fls );
   if (@source_files) { rdb_set_source( $rule, @source_files ); }
   else { warn "Could not determine source files for '$rule'\n"; }
   return $ret;
}

#=================================================

sub make_hdrA {
    use strict;
    my ($source, $dest) = @_;
    my $h_in = undef;
    my $h_out = undef;
    if ( ! open( $h_in, "<", $source )  ) {
       print "make_header could not read source file '$source'\n";
       return 1;
    }
    if (! open( $h_out, ">", $dest ) ) {
       print "make_header could not write header file '$dest'\n";
       return 2;
    }
    while (<$h_in>) {
        if ( /^\s*\\begin\s*{document}/
             || /^\s*\\endofdump/ 
             || /^\s*\\csname\s+endofdump\\endcsname/
           )
        { last; }
        print $h_out $_;
    }
    print $h_out "\\endofdump\n";
    close $h_out;
    close $h_in;
    return 0;
}

#=================================================

sub mylatex {
    # Arguments are:
    #   1. base name of the fmt file
    #   2. the compilation program
    #   then the arguments to be 
    use strict;
    our ($aux_dir1, $out_dir1, $emulate_aux, $Pbase, $Psource );

    my ($fmt_base, $engine, @args) = @_;
    $fmt_base .= "-$engine";
    my $source = $$Psource;
    my $ret = 0;

    my $fmt_file = "$aux_dir1$fmt_base.fmt";
    my $hdr_file = "$aux_dir1$fmt_base.hdr";
    if ( make_hdrA( $source, $hdr_file ) > 0 ) {
        die "I'm stopping, since I could not make '$hdr_file' from '$source'.\n";
    }
   
    # Location of .fls file after running engine, before any fudge to
    # emulate aux dir:
    my $fls_file = ($emulate_aux ? $aux_dir1 : $out_dir1 ) . "$$Pbase.fls";
    my $log_file = "$aux_dir1$$Pbase.log";

    if ( -e $fmt_file ) {
        @args = ("-fmt=$fmt_base", @args);
    }
    else {
        print "Format file '$fmt_file' does not exist. I'll run without it.\n";
    }

    my @cmd = ($engine, @args);
    print "Running '@cmd'\n";
    $ret = system @cmd;
    
    # Add lines to fls file to add dependency information:
    # (a) that a hdr file is generated.
    # (b) dependency on fls file.
    # Earlier I thought I needed to force a dependence on fls file. 
    # (22 Dec 2023) I don't remember why, so I'll leave that in.
    append( $fls_file,
            "INPUT $fls_file\n".
            "OUTPUT $hdr_file\n"
     );
    
    # Ensure latexmk knows that the .fmt file needs to be made if it
    # doesn't yet exist:
    if ( !-e $fmt_file ) { append( $log_file, "No file $fmt_file.\n" ); }
    return $ret;
}

#=================================================

sub append {
    use strict;
    my ($file, $string) = @_;
    if ( !-e $file ) { return 1; }
    open( my $fh, ">>", $file )
      or die "Cannot append to '$file'\n $_";
    print $fh $string;
    close $fh;
    return 0;
}

#=================================================

sub get_fls_inputs {
    my $fls_file = shift;
    my %inputs = ();
    my $fh = undef;
    if ( ! open( $fh, '<', $fls_file ) ) {
        warn "Cannot read '$fls_file':\n$!";
        return ();
    }
    while (my $line = <$fh>) {
        if ( $line =~ /^INPUT\s+(.+)\s*$/ ) {
           my $file = $1;
           $inputs{$file} = 1;
        }
    }
    close $fh;
    return keys %inputs;
}

#=================================================


###############################################
# bib2gls_latexmk
###############################################

# Implements use of bib2gls with glossaries-extra.
# Version of 4 Feb 2024. Thanks to Marcel Ilg for a suggestion.
# !!! ONLY WORKS WITH VERSION 4.54 or higher of latexmk
# Improve clean up.
push @generated_exts, 'glg', '%R*.glstex', '%R-1.glstex';

# For case that \GlsXtrLoadResources is used and so glstex file 
# (first one) has same name as .aux file.
add_cus_dep('aux', 'glstex', 0, 'run_bib2gls');

# For case that \glsxtrresourcefile is used and so glstex file 
# (first one) has same name as .bib file.
add_cus_dep('bib', 'glstex', 0, 'run_bib2gls_alt');

sub run_bib2gls {
    my $ret = 0;
    my ($base, $path) = fileparse( $_[0] );

    if ( $silent ) {
        $ret = system( "bib2gls", "--silent", "--group", "--dir", $path, $base );
    } else {
        $ret = system( "bib2gls", "--group", "--dir", $path, $base );
    };

    if ($ret) {
        warn "Run_bib2gls: Error, so I won't analyze .glg file\n";
        return $ret;
    }
    # Analyze bib2gls's log file:
    my $glg = "$_[0].glg";
    if ( open( my $glg_fh, '<', $glg) ) {
        rdb_add_generated( $glg ); 
        while (<$glg_fh>) {
            s/\s*$//;
            if (/^Reading\s+(.+)$/) { rdb_ensure_file( $rule, $1 ); }
            if (/^Writing\s+(.+)$/) { rdb_add_generated( $1 ); }
        }
        close $glg_fh;
    }
    else {
        warn "Run_bib2gls: Cannot read log file '$glg': $!\n";
    }
    return $ret;
}

sub run_bib2gls_alt {
    return Run_subst( 'internal run_bib2gls %Y%R' );
}


###############################################
# memoize_latexmk
###############################################

print "============= I am memoize's latexmkrc.  John Collins 2024-03-29\n";

# This rc file shows how to use latexmk with the memoize package.
#
# The memoize package (https://www.ctan.org/pkg/memoize) implements
# externalization and memoization of sections of code in a TeX document.
# It allows the compilation of the document to reuse results of
# compilation-intensive code, with a consequent speeding up of runs of
# *latex.  Such compilation intensive code is commonly encountered, for
# example, in making pictures by TikZ.
#
# When a section of code to be memoized is encountered, an extra page is
# inserted in the document's pdf file containing the results of the
# compilation of the section of code. Then a script, memoize-extract.pl or
# memoize-extract.py, is run to extract the extra parts of the the
# document's pdf file to individual pdf files (called externs).  On the
# next compilation by *latex, those generated pdf files are used in place
# of actually compiling the corresponding code (unless the section of code
# has changed).
#
# This latexmkrc file supports this process by configuring latexmk so that
# when a compilation by *latex is done, a memoize-extract script is run
# immediately afterwards.  If any new externs are generated, latexmk
# notices that and triggers a new compilation, as part of its normal mode
# of operation.
#
# The memoize package itself also runs memoize-extract at the start of each
# compilation. If latexmk has already run memoize-extract, that extra run
# of memoize-extract finds that it has nothing to do.  The solution here is
# more general: (a) It handles the case where the memoize package is
# invoked in the .tex file with the external=no option.  (b) It handles the
# situation where the aux and out directories are different, which is not
# the case for the built-in invocation.  (c) It nicely matches with
# latexmk's general methods of determining how many runs of *latex are
# needed.
#
#  Needs latexmk v. >= 4.84, memoize >= 1.2.0 (2024/03/15).
#  TeX Live 2024 (or later, presumably).
#  Tested on TeX Live 2024 on macOS, Ubuntu, Windows,
#      with pdflatex, lualatex, and xelatex.
#  Needs perl module PDF::API2 to be installed.
#  On TeXLive on Windows, also put
#      TEXLIVE_WINDOWS_TRY_EXTERNAL_PERL = 1
#  in the texmf.cnf file in the root directory of the TeX Live installation.

# ==> However, there are some anomalies on Windows, which haven't been sorted out
#     yet.  These notably concern memoize-clean
#
# ==> Fails on MiKTeX on Windows: memoize-extract refuses to create pdf file????
#            I haven't yet figured out the problem.
# ==> Also trouble on MiKTeX on macOS: the memoize-extract.pl.exe won't run.

# You can have separate build and output directories, e.g., by
    #$out_dir = 'output';
    #$aux_dir = 'build';
# or they can be the same, e.g., by
     # $out_dir = $aux_dir = 'output';


# Which program and extra options to use for memoize-extract and memoize-clean.
# Note that these are arrays, not simple strings.
our @memoize_extract = ( 'memoize-extract.pl' );
our @memoize_clean = ( 'memoize-clean.pl' );

# Specification of the basic memoize files to delete in a clean-up
# operation. The generated .memo and .pdf files have more specifications,
# and we use memoize-clean to delete those, invoked by a cleanup hook.
push @generated_exts, 'mmz', 'mmz.log';

# Subroutine mmz_analyzes analyzes .mmz file, if it exists **and** was
# generated in current compilation, to determine whether there are new
# extern pdfs to be generated from memo files and pdf file.  Communicate
# to subtroutine mmz_extract_new a need to make new externs by setting the
# variable to a non-zero value for $mmz_has_new.  Let the value be the
# name of the mmz file; this is perhaps being too elaborate, since the
# standard name of the mmz file can be determined

add_hook( 'after_xlatex_analysis', \&mmz_analyze );
add_hook( 'after_main_pdf', \&mmz_extract_new );

# !!!!!!!!!!!!!!!!!!!! Uncomment the following line **only** if you really
# want latexmk's cleanup operations to delete Memoize's memoization
# files. In a document where these files are time-consuming to make, i.e.,
# in the main use case for the memoize package, the files are precious and
# should only need deleted when that is really needed. 
#
# add_hook( 'cleanup', \&mmz_cleanup );

# Whether there are new externs to be made:
my $mmz_has_new = '';
#     Scope of this variable: private, from here to end of file.


#-----------------------------------------------------

sub mmz_analyze {
    use strict;
    print "============= I am mmz_analyze \n";
    print "  Still to deal with provoking of rerun if directory made\n";

    # Analyzes mmz file if generated on this run.
    # Then 1. Arranges to trigger making of missing extern pdfs, if needed.
    #      2. Sets dependencies on the extern pdfs. This ensures that, in
    #         the case that one or more extern pdfs does not currently
    #         exist, a rerun of *latex will triggered after it/they get
    #         made. 
    # Return zero on success (or nothing to do), and non-zero otherwise.

    # N.B. Current (2024-03-11) hook implementation doesn't use return
    #      values from hook subroutines. Future implementation might.
    #      So I'll provide a return value.

    my $base = $$Pbase;
    my $mmz_file = "$aux_dir1$base.mmz";

    # Communicate to subroutine mmz_extract_new about whether new extern
    #   pdf(s) are to be made.  Default to assuming no externs are to be
    #   made:
    $mmz_has_new = '';
    
    if (! -e $mmz_file) {
        print "mmz_analyze: No mmz file '$mmz_file', so memoize is not being used.\n";
        return 0;
    }

    # Use (not-currently-documented) latexmk subroutine to detemine 
    #   whether mmz file was generated in current run: 
    if ( ! test_gen_file_time( $mmz_file) ) {
        warn "mmz_analyze: Mmz file '$mmz_file' exists, but wasn't generated\n",
             "  on this run so memoize is not **currently** being used.\n";
        return 0;
    }

    # Get dependency information.
    # We need to cause not-yet-made extern pdfs to be trated as source
    # files for *latex.
    my $mmz_fh = undef;
    if (! open( $mmz_fh, '<', $mmz_file ) ) {
        warn "mmz_analyze: Mmz file '$mmz_file' exists, but I can't read it:\n",
        "  $!\n";
        return 1;
    }
    my @externs = ();
    my @dirs = ();
    while ( <$mmz_fh> ) {
         s/\s*$//;           # Remove trailing space, including new lines
         if ( /^\\mmzNewExtern\s+{([^}]+)}/ ) {
             # We have a new memo item without a corresponding pdf file.
             # It will be put in the aux directory. 
             my $file = "$aux_dir1$1";
             print "mmz_analyze: new extern for memoize: '$file'\n";
             push @externs, $file;
         }
         elsif ( /^\\mmzPrefix\s+{([^}]+)}/ ) {
             # Prefix.
             my $prefix = $1;
             if ( $prefix =~ m{^(.*)/[^/]*} ) {
                 my $dir = $1;
                 push @dirs, "$aux_dir1$1";

             }
         }
    }
    close $mmz_fh;
    foreach (@dirs) {
        if ( ! -e ) {
            my @cmd = ( @memoize_extract, '--mkdir', $_ ); 
            print "mmz_analyze: Making directory '$_' safely by running\n",
                  " @cmd\n";
            mkdir $_;
        }        
    }

    rdb_ensure_files_here( @externs );
    
    # .mmz.log is read by Memoize package after it does an internal
    # extract, so it appears as an INPUT file in .fls.  But it was created
    # earlier in the same run by memoize-extract, so it's not a true
    # dependency, and should be removed from the list of source files:
    rdb_remove_files( $rule, "$mmz_file.log" );

    if (@externs ) {
        $mmz_has_new = $mmz_file;
    }
    return 0; 
}

#-----------------------------------------------------

sub mmz_extract_new {
    use strict;
    print "============= I am mmz_extract_new \n";

    # If there are new extern pdf files to be made, run memoize-extract to
    #    make them.
    # Situation on entry:
    #   1. I'm in the context of a rule for making the document's pdf file.
    #      When new extern pdf files are to be made, the document's pdf
    #      file contains the pages to be extracted by memoize-extract.
    #      Given the rule context, the name of the document's pdf file is
    #      $$Pdest.
    #   2. $mmz_has_new was earlier set to the name of the mmz file with
    #      the information on the files used for memoization, but only if
    #      there are new extern pdf(s) to be made.
    #   3. If it is empty, then no extern pdfs are to be made.  This covers
    #      the case that the memoize package isn't being used.
    # Return zero on success (or nothing to do), and non-zero otherwise.
    
    if ( $mmz_has_new eq '' ) { return 0; }

    my $mmz_file = $mmz_has_new;
    my ($mmz_file_no_path, $path) = fileparse( $mmz_file );
    my $pdf_file = $$Pdest;

    # The directory used by memoize-extract for putting the generated
    #   extern pdfs is passed in the TEXMF_OUTPUT_DIRECTORY environment
    #   variable.  (The need for this way of passing information is
    #   associated with some security restrictions that apply when
    #   memoize-extract is called directly from the memoize package in a
    #   *latex compilation.)  
    local $ENV{TEXMF_OUTPUT_DIRECTORY} = $aux_dir;
    for ('TEXMF_OUTPUT_DIRECTORY') {
        print "mmz_extract_new : ENV{$_} = '$ENV{$_}'\n";
    }
    # So we should give the name of the mmz_file to memoize-extract without
    #   the directory part.    
    my @cmd = (@memoize_extract, '--format', 'latex',
                    '--pdf', $pdf_file, $mmz_file_no_path ); 

    if ( ! -e $pdf_file ) {
        warn "mmz_extract_new: Cannot generate externs here, since no pdf file generated\n";
        return 1;
    }
    elsif ( ! test_gen_file($pdf_file) ) {
        warn "mmz_extract_new: Pdf file '$pdf_file' exists, but wasn't\n",
             "  generated on this run.  I'll run memoize-extract.  Pdf file may contain\n",
             "  extra pages generated by the memoize package.\n";
        return 1;
    }
    print "make_extract_new: Running\n @cmd\n";
    return system @cmd;
}

#-----------------------------------------------------

sub mmz_cleanup {
    use strict;
    print "============= I am mmz_cleanup \n";
    my @cmd = ( @memoize_clean, '--all', '--yes',
                      '--prefix', $aux_dir, 
                      "$aux_dir1$$Pbase.mmz" );
    print "mmz_cleanup: Running\n @cmd\n";
    my $ret = system @cmd;
    say "Return code $ret";
    return $ret;
}

#-----------------------------------------------------

###############################################
# PERSO
###############################################

# # modify $pdflatex to use custom format
# $pdflatex = 'pdflatex -fmt mwe %B %O %S';
$pdflatex= 'pdflatex -synctex=1 --shell-escape -file-line-error %O %S';
# -synctex=1 -interaction=nonstopmode --shell-escape -file-line-error %O

# $aux_dir = 'buildmk'; # change localization of aux files
# $out_dir = 'outdir'; # change localization of final outputs


$clean_ext = "%R.bbl glg glstex %R-1.glstex loc %R.memo.dir/* %R.memo.dir mmz mmz.log soc synctex.gz synctex.gz(busy)";
