file=~/.projects
if [[ ! -e "$file" ]]; then
    touch "$file"
fi

names=() descriptions=() paths=()
names_max_len=0 descriptions_max_len=0 paths_max_len=0
total=0 lines=0

function read_projects() {
    names=() descriptions=() paths=()
    names_max_len=0 descriptions_max_len=0 paths_max_len=0
    total=0 lines=0

    while read -r line; do
        case $((lines % 3)) in
            0)
                names+=("$line")
                if ((${#line} > names_max_len)); then
                    names_max_len=${#line}
                fi
            ;;
            1)
                descriptions+=("$line")
                if ((${#line} > descriptions_max_len)); then
                    descriptions_max_len=${#line}
                fi
            ;;
            2)
                paths+=("$line")
                if ((${#line} > paths_max_len)); then
                    paths_max_len=${#line}
                fi
                ((total++))
            ;;
        esac
        ((lines++))
    done < "$file"
}

reset="\033[0m"
yellow="\033[1;33m"
green="\033[0;32m"
blue="\033[0;34m"
function list() {
    read_projects
    if [[ $total == 0 ]]; then
        echo "No projects yet"
    else
        echo "Projects:"
        for line in {1..$total}; do
            echo -n    "    $line. "
            echo -n -e "${yellow}${(r($names_max_len)(  ))names[$line]} "
            echo -n -e "${green}${(r($descriptions_max_len)(  ))descriptions[$line]} "
            echo    -e "${blue}${(r($paths_max_len)(  ))paths[$line]}${reset}"
        done
    fi
}

function add() {
    read_projects
    if [[ -z $1 ]]; then
        echo "Usage: projects add <name> <description>"
    else
        for i in {1..$total}; do
            if [[ $1 == ${names[i]} ]]; then
                echo "Project with the same name already exists"
                return
            elif [[ $PWD == ${paths[i]} ]]; then
                echo "Project with the same path already exists"
                return
            fi
        done

        echo "$1"   >> "$file"
        echo "$2"   >> "$file"
        echo "$PWD" >> "$file"
    fi
}

function delete() {
    read_projects
    line=-1
    if [[ -z $1 ]]; then
        echo "Usage: projects delete <name>"
    else
        for i in {1..$total}; do
            if [[ $1 == ${names[i]} ]]; then
                line=$((1 + 3*(i-1)))
                sed -i "${line}d" "$file"
                sed -i "${line}d" "$file"
                sed -i "${line}d" "$file"
                break
            fi
        done
        if [[ $line == -1 ]]; then
            echo "No such project"
        else
            ((lines-=3))
            ((total--))
            read_projects
        fi
    fi
}

alias p=list
alias pa=add
alias pd=delete
