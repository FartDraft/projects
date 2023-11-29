projects_path=~/.projects
names=() descriptions=() paths=()
names_max_len=0 descriptions_max_len=0 paths_max_len=0
total=0 i=0

function projects_add_line() {
    case $((i % 3)) in
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
        *)
            echo "Error"
        ;;
    esac
    ((i++))
}

function projects_read_file() {
    while read -r line; do
        projects_add_line "$line"
    done < "$projects_path"
    if ((i % 3 != 0)); then
        echo "$i"
        echo "Invalid file format: $projects_path"
    fi
}
projects_read_file

reset="\033[0m"
yellow="\033[1;33m"
red="\033[0;31m"
blue="\033[0;34m"
function projects_list() {
    echo "Projects:"
    for i in {1..$total}; do
        echo -n    "    $i. "
        echo -n -e "${yellow}${(r($names_max_len)(  ))names[$i]} "
        echo -n -e "${red}${(r($descriptions_max_len)(  ))descriptions[$i]} "
        echo    -e "${blue}${(r($paths_max_len)(  ))paths[$i]}${reset}"
    done
}

function projects_add() {
    if [[ -z $1 ]]; then
        echo "Usage: projects add <name> <description>"
    else
        echo "$1" >> "$projects_path"
        projects_add_line "$1"
        echo "$2" >> "$projects_path"
        projects_add_line "$2"
        echo "$PWD" >> $projects_path
        projects_add_line "$PWD"
    fi
}

alias p=projects_list
alias pa=projects_add
