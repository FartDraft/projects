file=~/.projects
if [[ ! -e "$file" ]]; then
    touch "$file"
fi

names=() descriptions=() paths=()
names_max_len=0 descriptions_max_len=0 paths_max_len=0
total=0 lines=0

function add_line() {
    case $((lines % 3)) in
        0)
            names+=("$1")
            if ((${#1} > names_max_len)); then
                names_max_len=${#1}
            fi
        ;;
        1)
            descriptions+=("$1")
            if ((${#1} > descriptions_max_len)); then
                descriptions_max_len=${#1}
            fi
        ;;
        2)
            paths+=("$1")
            if ((${#1} > paths_max_len)); then
                paths_max_len=${#1}
            fi
            ((total++))
        ;;
    esac
    ((lines++))
}

# Read from $file
while read -r line; do
    add_line "$line"
done < "$file"

reset="\033[0m"
yellow="\033[1;33m"
red="\033[0;31m"
blue="\033[0;34m"
function list() {
    echo "Projects:"
    for lines in {1..$total}; do
        echo -n    "    $lines. "
        echo -n -e "${yellow}${(r($names_max_len)(  ))names[$lines]} "
        echo -n -e "${red}${(r($descriptions_max_len)(  ))descriptions[$lines]} "
        echo    -e "${blue}${(r($paths_max_len)(  ))paths[$lines]}${reset}"
    done
}

function add() {
    if [[ -z $1 ]]; then
        echo "Usage: projects add <name> <description>"
    else
        echo "$1" >> "$file"
        add_line "$1"
        echo "$2" >> "$file"
        add_line "$2"
        echo "$PWD" >> $file
        add_line "$PWD"
    fi
    fi
}

alias p=list
alias pa=add
