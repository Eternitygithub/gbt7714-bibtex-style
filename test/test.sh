testfiledir="test/testbst"
testsuppdir="$testfiledir/support"
unpackdir="build/unpacked";
testdir="build/test";
texoptions="-file-line-error -halt-on-error -interaction=nonstopmode"
unpackexe="xetex $texoptions"
checkexe="xelatex $texoptions -no-pdf"
bibtexexe="bibtex"


if [ ! -d "$unpackdir" ]; then
    mkdir -p "$unpackdir";
fi
cp -f "gbt7714.dtx" "$unpackdir";


if [ ! -d "$testdir" ]; then
    mkdir -p "$testdir";
fi
cp -f "$testfiledir/support/test.aux" "$testdir";
cp -f "$testfiledir/support/standard.bib" "$testdir";


if [ -z "$1" ]; then
    succuss=true;
    echo "Running checks on";

    for file in $testfiledir/*.dtx; do
        filename=$(basename $file);
        testname=$(basename $filename .dtx);
        echo "  $testname";

        cp -f "$file" "$unpackdir";  # test bib file

        ( cd "$unpackdir"; $unpackexe $filename > /dev/null; )
        cp -f "$unpackdir/test.bst" "$testdir"
        cp -f "$unpackdir/test.bib" "$testdir"

        ( cd $testdir; $bibtexexe test > /dev/null; )

        bblfile="$testdir/test.bbl";
        stdfile="$testfiledir/$testname.bbl";
        if ! diff -q "$bblfile" "$stdfile" 2> /dev/null; then
            echo "fails";
            succuss=false;
        fi
    done

    if $succuss; then
        echo "";
        echo "All checks passed";
        echo "";
    else
        exit 1;
    fi

else
    cp -f "$testfiledir/support/test.tex" "$testdir";
    cp -f "gbt7714.sty" "$testdir";
    testname="$1";
    filename="$testname.dtx";
    file="$testfiledir/$testname.dtx";

    cp -f "$file" "$unpackdir";  # test bib file

    ( cd "$unpackdir"; $unpackexe $filename > /dev/null; )
    cp -f "$unpackdir/test.bst" "$testdir";
    cp -f "$unpackdir/test.bib" "$testdir";

    ( cd "$testdir"; latexmk -xelatex test > /dev/null; )

    bblfile="$testdir/test.bbl";
    stdfile="$testfiledir/$testname.bbl";
    if ! diff -q "$bblfile" "$stdfile" > /dev/null; then
        cp -f "$bblfile" "$stdfile";
    fi
fi
