# Build the ebook. Check build.md to prep build environment.

# Check arg.
case $1 in
    epub) echo "Building $1" ;;
    pdf) echo "Building $1" ;;
    *) echo "Usage: $0 [epub|pdf]" > /dev/stderr && exit 1
esac

# Pre-process foreward template version.
if [[ -n $(git status -s) ]]; then
    COMMIT="#######"
    EPOCH=$(date +%s)
else
    COMMIT=$(git log -1 --format=%h)
    EPOCH=$(git log -1 --format=%ct)
    TAG=$(git describe --tags --candidates=0 $COMMIT 2>/dev/null)
    if [[ -n $TAG ]]; then
        COMMIT=$TAG
    fi
fi
DATE="@$EPOCH"
VERSION="Commit $COMMIT, $(date -d $DATE +'%B %d, %Y')."
sed "s/{{ version }}/$VERSION/g" foreward.tpl.md > foreward.md
echo "${VERSION}"

# Pre-process input files.
MD="Liezi-$COMMIT.md"
sed -s '$G' -s \
    foreward.md \
    title.md \
    01.md \
    02.md \
    03.md \
    04.md \
    05.md \
    06.md \
    07.md \
    08.md \
    README.md > "$MD"

# Build epub.
if [ $1 = "epub" ]; then
    EPUB="Liezi-$COMMIT.epub"
    HTML="Liezi-$COMMIT.html.md"
    CJK_FONT="/usr/share/fonts/opentype/noto/NotoSerifCJK-Light.ttc"
    CJK_OUT="epub-fonts/CJK.ttf"
    python epub_fonts.py "$MD" "$CJK_FONT" "$CJK_OUT" cjk
    bash pre-process.bash "$MD" html > "$HTML"
    pandoc "$HTML" \
        --defaults epub-defaults.yaml \
        --output "${EPUB}"
    echo Built "${EPUB}"
fi

## Or build pdf.
if [ $1 = "pdf" ]; then
    PDF="Liezi-$COMMIT.pdf"
    TEX="Liezi-$COMMIT.tex.md"
    bash pre-process.bash "$MD" latex > "$TEX"
    pandoc "$TEX" \
        --defaults pdf-defaults.yaml \
        --output "${PDF}"
    echo Built "${PDF}"
fi
