# Pre-process markdown before generating output.
IN="$1"
OUT="$2"
IN_CONTENT=0
IN_CHAPTER=0
IN_PASSAGE=0
IN_PARAGRAPH=0
IN_SENTENCE=0
IN_QUOTE=0
IN_NOTES=0
END_GROUP=0
END_PARAGRAPH=0
END_PASSAGE=0
DEBUG=0

function escape_quotes() {
    if [[ "$line" =~ ‘“ ]]; then
        line=$(echo "${line//‘“/‘ “}")
    fi
    if [[ "$line" =~ ”’ ]]; then
        line=$(echo "${line//”’/” ’}")
    fi
    if [[ "$line" =~ “ ]]; then
        line=$(echo "${line//“/\\“}")
    fi
    if [[ "$line" =~ ” ]]; then
        line=$(echo "${line//”/\\”}")
    fi
    if [[ "$line" =~ ‘ ]]; then
        line=$(echo "${line//‘/\\‘}")
    fi
    if [[ "$line" =~ ’ ]]; then
        line=$(echo "${line//’/\\’}")
    fi
}

function is_hanzi() {
    if [[ "$line" =~ ^[[:upper:]] ]]; then
        return 0
    fi
    if [[ "$line" =~ ^[[:lower:]] ]]; then
        return 0
    fi
    if [[ "$line" =~ ^\\‘ ]]; then
        return 0
    fi
    if [[ "$line" =~ ^\\“ ]]; then
        return 0
    fi
    if [[ "$line" =~ ^_ ]]; then
        return 0
    fi
    if [[ "$line" =~ ^\( ]]; then
        return 0
    fi
    if [[ "$line" =~ ^--- ]]; then
        return 0
    fi
    if [[ "$line" =~ ^\. ]]; then
        return 0
    fi
    if [[ "$line" =~ ^\[ ]]; then
        return 0
    fi
    if [[ "$line" =~ ^\\\[ ]]; then
        return 0
    fi
    return 1
}

function is_note() {
    if [[ "$line" =~ ^\[\^ ]]; then
        return 1
    elif [[ "$line" =~ ^[[:space:]]{4} ]]; then
        return 1
    else
        return 0
    fi
}

function is_quote() {
    if [[ "$line" =~ ^\>[[:space:]] ]]; then
        return 1
    else
        return 0
    fi
}

function process_h1_start() {
    if [[ $IN_NOTES -eq 1 ]]; then
        IN_NOTES=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--NOTES-EXIT-->"; fi
    fi
    if [[ $IN_PASSAGE -eq 1 ]]; then
        if [[ $END_PASSAGE -eq 1 ]]; then
            print_passage_break
        fi
        if [[ $END_GROUP -eq 1 ]]; then
            end_group
            END_GROUP=0
        fi
        if [[ $END_PASSAGE -eq 1 ]]; then
            end_passage
            END_PASSAGE=0
            END_PARAGRAPH=0
        fi
        IN_PASSAGE=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--PASSAGE-EXIT-->"; fi
    fi
    if [[ $IN_PARAGRAPH -eq 1 ]]; then
        IN_PARAGRAPH=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--PARAGRAPH-EXIT-->"; fi
    fi
    if [[ $IN_CHAPTER -eq 1 ]]; then
        IN_CHAPTER=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--CHAPTER-EXIT-->"; fi
    fi
    if [[ $IN_CONTENT -eq 1 ]]; then
        IN_CONTENT=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--CONTENT-EXIT-->"; fi
    fi
    if ! [[ "$line" =~ "Foreward" ]] && ! [[ "$line" =~ "Appendix" ]]; then
        echo "$line"
        IN_CONTENT=1
        if [[ $DEBUG -eq 1 ]]; then echo "<!--CONTENT-ENTER-->"; fi
        IN_PASSAGE=1
        if [[ $DEBUG -eq 1 ]]; then echo "<!--PASSAGE-ENTER-->"; fi
    else
        echo "$line"
    fi
}

function process_h2_start() {
    if [[ $IN_NOTES -eq 1 ]]; then
        IN_NOTES=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--NOTES-EXIT-->"; fi
    fi
    if [[ $IN_PARAGRAPH -eq 1 ]]; then
        IN_PARAGRAPH=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--PARAGRAPH-EXIT-->"; fi
    fi
    if [[ $IN_PASSAGE -eq 1 ]]; then
        if [[ $END_PASSAGE -eq 1 ]]; then
            print_passage_break
        fi
        if [[ $END_GROUP -eq 1 ]]; then
            end_group
            END_GROUP=0
        fi
        if [[ $END_PASSAGE -eq 1 ]]; then
            end_passage
            END_PASSAGE=0
            END_PARAGRAPH=0
        fi
        IN_PASSAGE=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--PASSAGE-EXIT-->"; fi
    fi
    if [[ $IN_CHAPTER -eq 1 ]]; then
        IN_CHAPTER=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--CHAPTER-EXIT-->"; fi
    fi
    if [[ $IN_CONTENT -eq 1 ]]; then
        echo "$line"
        IN_CHAPTER=1
        if [[ $DEBUG -eq 1 ]]; then echo "<!--CHAPTER-ENTER-->"; fi
        IN_PASSAGE=1
        if [[ $DEBUG -eq 1 ]]; then echo "<!--PASSAGE-ENTER-->"; fi
    else
        echo "$line"
    fi
}

function process_paragraph_break() {
    if [[ $IN_NOTES -eq 1 ]]; then
        IN_NOTES=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--NOTES-EXIT-->"; fi
    fi
    if [[ $IN_PARAGRAPH -eq 1 ]]; then
        if [[ $END_PARAGRAPH -eq 1 ]]; then
            print_paragraph_break
            END_PARAGRAPH=0
        fi
        if [[ $END_GROUP -eq 1 ]]; then
            end_group
            END_GROUP=0
        fi
        IN_PARAGRAPH=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--PARAGRAPH-EXIT-->"; fi
    fi
    if [[ $IN_PASSAGE -eq 0 ]] || [[ $DEBUG -eq 1 ]]; then echo "$line"; fi
}

function process_passage_break() {
    if [[ $IN_NOTES -eq 1 ]]; then
        IN_NOTES=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--NOTES-EXIT-->"; fi
    fi
    if [[ $IN_PARAGRAPH -eq 1 ]]; then
        IN_PARAGRAPH=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--PARAGRAPH-EXIT-->"; fi
    fi
    if [[ $IN_PASSAGE -eq 1 ]]; then
        print_passage_break
        if [[ $END_GROUP -eq 1 ]]; then
            end_group
            END_GROUP=0
        fi
        if [[ $END_PASSAGE -eq 1 ]]; then
            end_passage
            END_PASSAGE=0
            END_PARAGRAPH=0
        fi
        IN_PARAGRAPH=0
        IN_PASSAGE=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--PASSAGE-EXIT-->"; fi
    fi
    if [[ $IN_CONTENT -eq 0 ]] || [[ $DEBUG -eq 1 ]]; then echo "$line"; fi
    if [[ $IN_CHAPTER -eq 1 ]]; then
        IN_PASSAGE=1
        if [[ $DEBUG -eq 1 ]]; then echo "<!--PASSAGE-ENTER-->"; fi
    fi
}

function process_notes_start() {
    if [[ $IN_CONTENT -eq 0 ]]; then return; fi
    IN_NOTES=1
    if [[ "$OUT" = "html" ]]; then echo; fi
    if [[ $DEBUG -eq 1 ]]; then echo "<!--NOTES-ENTER-->"; fi
}

function process_quote_start() {
    if [[ $IN_CONTENT -eq 0 ]]; then return; fi
    if [[ $END_GROUP -eq 1 ]]; then
        end_group
        END_GROUP=0
    fi
    if [[ $DEBUG -eq 1 ]]; then echo "<!--QUOTE-ENTER-->"; fi
    IN_QUOTE=1
    END_GROUP=1
    if [[ $END_PARAGRAPH -eq 0 ]]; then
        END_PARAGRAPH=1
    fi
    if [[ $END_PASSAGE -eq 0 ]]; then
        END_PASSAGE=1
    fi
    start_group
    if [[ "$OUT" = "latex" ]]; then line=$(echo "${line:2}")
    elif [[ "$OUT" = "html" ]]; then echo; fi
}

function process_empty_line() {
    if [[ $IN_SENTENCE -eq 1 ]]; then
        IN_SENTENCE=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--SENTENCE-EXIT-->"; fi
    fi
    if [[ $IN_QUOTE -eq 1 ]]; then
        IN_QUOTE=0
        if [[ $DEBUG -eq 1 ]]; then echo "<!--QUOTE-EXIT-->"; fi
        if [[ "$OUT" = "html" ]]; then echo; fi
    fi
    if [[ "$OUT" = "latex" ]]; then echo
    elif [[ "$OUT" = "html" ]]; then
        if [[ $IN_NOTES -eq 1 ]] || [[ $IN_PARAGRAPH -eq 0 ]]; then echo; fi
    fi
}

function process_line() {
    if [[ $IN_CONTENT -eq 0 ]]; then echo "$line"
    elif [[ $IN_NOTES -eq 1 ]] ; then echo "$line"
    else
        if [[ $IN_PARAGRAPH -eq 0 ]]; then
            IN_PARAGRAPH=1
            if [[ $DEBUG -eq 1 ]]; then echo "<!--PARAGRAPH-ENTER-->"; fi
        fi
        if [[ $IN_SENTENCE -eq 0 ]] && [[ $IN_QUOTE -eq 0 ]]; then
            if [[ $END_GROUP -eq 1 ]]; then
                end_group
                END_GROUP=0
            fi
            if [[ $DEBUG -eq 1 ]]; then echo "<!--SENTENCE-ENTER-->"; fi
            IN_SENTENCE=1
            END_GROUP=1
            if [[ $END_PARAGRAPH -eq 0 ]]; then
                END_PARAGRAPH=1
            fi
            if [[ $END_PASSAGE -eq 0 ]]; then
                END_PASSAGE=1
            fi
            start_group
        fi
        if [[ "$OUT" = "html" ]]; then
            echo "$line"
        elif [[ "$OUT" = "latex" ]]; then
            is_hanzi
            IS_HANZI=$?
            if [[ $IN_QUOTE -eq 1 ]]; then
                quotify_latex_line
            else
                vertify_latex_line
            fi
        fi
    fi
}

function quotify_latex_line() {
    if [[ $DEBUG -eq 1 ]]; then echo "$line"; fi
    if [[ $IS_HANZI -eq 0 ]]; then
        line=$(echo "_${line}_")
    fi
    vertify_latex_line
}

function vertify_latex_line() {
    if [[ $DEBUG -eq 1 ]]; then echo "$line"; return; fi
    if [[ $IS_HANZI -eq 1 ]]; then
        echo "\\Large $line  "
    else
        echo "\\small $line  "
    fi
}

function start_group() {
    if [[ $DEBUG -eq 1 ]]; then return; fi
    if [[ "$OUT" = "latex" ]]; then
        echo "\\begingroup\\centering\\filbreak"
        echo
    fi
}

function end_group() {
    if [[ $DEBUG -eq 1 ]]; then return; fi
    if [[ "$OUT" = "latex" ]]; then
        echo "\\endgroup"
        echo
    fi
}

function print_paragraph_break() {
    if [[ $DEBUG -eq 1 ]]; then echo "$line"; return; fi
    if [[ "$OUT" = "latex" ]]; then
        echo ""\\ast$~$\\ast$~$\\ast
        echo
    fi
}

function print_passage_break() {
    if [[ $DEBUG -eq 1 ]]; then echo "$line"; return; fi
    if [[ "$OUT" = "html" ]]; then
        echo
        echo "<p class=\"passage-break\">☯&nbsp;☯&nbsp;☯</p>"
    elif [[ "$OUT" = "latex" ]]; then
        echo "\\text{\\small\\char\"262F$~$\\char\"262F$~$\\char\"262F}"
        echo
    fi
}

function end_passage() {
    if [[ $DEBUG -eq 1 ]]; then return; fi
    if [[ "$OUT" = "latex" ]]; then
        echo "\\clearpage"
        echo
    fi
}

while IFS= read -r line; do

    escape_quotes

    if [[ "$line" =~ ^#[[:space:]] ]]; then
        process_h1_start
        continue
    fi

    if [[ "$line" =~ ^##[[:space:]] ]]; then
        process_h2_start
        continue
    fi

    if [[ "$line" = "***" ]]; then
        process_paragraph_break
        continue
    fi

    if [[ "$line" = "---" ]]; then
        process_passage_break
        continue
    fi

    if [[ "$line" = "" ]]; then
        process_empty_line
        continue
    fi

    is_note
    IS_NOTE=$?
    if [[ $IS_NOTE -eq 1 ]]; then
        if [[ $IN_NOTES -eq 0 ]]; then
            process_notes_start
        fi
    fi

    is_quote
    IS_QUOTE=$?
    if [[ $IS_QUOTE -eq 1 ]]; then
        process_quote_start
    fi

    process_line

done < "$IN"
