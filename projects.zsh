file=~/.projects
hook='nvim .'
if [[ ! -e "$file" ]]; then
    touch "$file"
fi

names=() descriptions=() paths=()
names_max_len=0 descriptions_max_len=0 paths_max_len=0
total=0 lines=0

reset="\033[0m"
red="\033[0;31m"
yellow="\033[1;33m"
green="\033[0;32m"
blue="\033[0;34m"

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

    if ((lines % 3 != 0)); then
        return 1
    fi
}

function list_projects() {
    if [[ $total == 0 ]]; then
        echo 'No projects yet'
    else
        echo 'Projects:'
        for line in {1..$total}; do
            echo -n    "    $line. "
            echo -n -e "${yellow}${(r($names_max_len)(  ))names[$line]} "
            echo -n -e "${green}${(r($descriptions_max_len)(  ))descriptions[$line]} "
            echo    -e "${blue}${(r($paths_max_len)(  ))paths[$line]}${reset}"
        done
    fi
}

function add_project() {
    for i in {1..$total}; do
        if [[ $1 == ${names[i]} ]]; then
            echo 'Project with the same name already exists'
            return
        elif [[ $PWD == ${paths[i]} ]]; then
            echo 'Project with the same path already exists'
            return
        fi
    done

    echo "$1"   >> "$file"
    echo "$2"   >> "$file"
    echo "$PWD" >> "$file"
}

function delete_project() {
    for i in {1..$total}; do
        if [[ $1 == ${names[i]} ]]; then
            line=$((1 + 3*(i-1)))
            sed -i "${line}d" "$file"
            sed -i "${line}d" "$file"
            sed -i "${line}d" "$file"
            return
        fi
    done

    echo 'No such project'
}

function go_to_project() {
    if [[ -z "$1" ]]; then
        echo 'No project name'
    else
        finded=0
        for i in {1..$total}; do
            if [[ $1 == ${names[i]} ]]; then
                finded=1
                cd -q ${paths[i]}
                eval $hook
            fi
        done
        if [[ $finded == 0 ]]; then
            echo 'No such project'
        fi
    fi
}

function reset_projects() {
    truncate --size 0 "$file"
}

function help_projects() {
    echo 'Usage: p [<name>] [-l] [-a <name> <description>] [-d <name>] [-R] [-h]'
    echo 'List, Add, Delete and Go to projects.'
    echo '      :   go to project'
    echo '    -l:   list projects'
    echo '    -a:   add project'
    echo '    -d:   delete project'
    echo '    -R:   reset projects file'
    echo '    -h:   help'
}

function projects() {
    if ! read_projects; then
        echo "${red}File $file is corrupted${reset}"
        return
    fi

    if [[ $1 == '-l' ]]; then
        list_projects
    elif [[ $1 == '-a' ]]; then
        add_project $2 $3
    elif [[ $1 == '-d' ]]; then
        delete_project $2
    elif [[ $1 == '-R' ]]; then
        reset_projects
    elif [[ $1 == '-h' ]]; then
        help_projects
    else
        go_to_project $1
    fi
}

alias p=projects
