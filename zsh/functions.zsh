if [[ "$os" = "$linux_str" ]]; then
    # Open the specified directory in nautilus or other provided program
    open() {
        if [ "$#" -eq 0 ]; then
            xdg-open . &>/dev/null &
        elif [ "$#" -eq 1 ]; then
            xdg-open "$1" &>/dev/null &
        else
            nohup "$1" "$2" &>/dev/null &
        fi
    }

    # Notify after a process has completed
    notify() {
        $@
        notify-send $opt "Process Completed" "$*"
        print -n '\a'
    }

    # Run pacman, prompting for password if needed
    run_pacman() {
        case $1 in
            -S | -D | -S[^sih]* | -R* | -U*)
                /usr/bin/sudo /usr/bin/pacman "$@" ;;
        *)      /usr/bin/pacman "$@" ;;
        esac
    }

    # Gets current brightness
    get_brightness() {
        local outstr=$(ddcutil getvcp 10)
        local nums=$(echo -e $outstr | sed -e 's/[^0-9]/ /g' -e 's/^ *//g' -e 's/ *$//g' | tr -s ' ')
        echo $nums | cut -d " " -f 3
    }
    
    # Set brightness to given value
    set_brightness() {
        if [ "$#" -eq 1 ]; then
            ddcutil setvcp 10 $1
        else
            print "Invalid number of arguments"
        fi
    }

    # Set brightness relative to current value
    set_brightness_rel() {
        if [ "$#" -eq 1 ]; then
            local curr=$(get_brightness)
            if [ "${1:0:1}" = "+" ]; then
                set_brightness $(( curr + ${1:1} ))
            elif [ "${1:0:1}" = "-" ]; then
                set_brightness $(( curr - ${1:1} ))
            else
                print "Invalid argument"
            fi
        else 
           print "Invalid number of arguments" 
        fi  
    }

    gcip() {
        if [ "$#" -eq 1 ]; then
            gcloud compute instances describe $1 | grep "natIP" | awk '{print $2}' | xargs echo -n
        else
            print "Invalid number of arguments" 
        fi  
    }

    syncd() {
        if [ "$#" -eq 2 ]; then
            local remote_ip=$1
            shift
            local abs_path=$(realpath $1)
            local local_dir=$(dirname $abs_path)
            ssh $remote_ip "mkdir -p $local_dir"
            lsyncd -nodaemon -delay 0 -rsyncssh $abs_path $remote_ip $abs_path
        else 
            print "Invalid number of arguments"
        fi
    }
fi

# Start ssh daemon
startssh() {
    if [[ "$os" = "$linux_str" ]]; then
        systemctl start sshd
    elif [[ "$os" = "$osx_str" ]]; then
        sudo systemsetup -f -setremotelogin on
    fi
}

# Stop ssh daemon
stopssh() {
    if [[ "$os" = "$linux_str" ]]; then
        systemctl stop sshd
    elif [[ "$os" = "$osx_str" ]]; then
        sudo systemsetup -f -setremotelogin off
    fi
}

run_man() {
    env LESS_TERMCAP_mb=$'\E[01;31m' \
    LESS_TERMCAP_md=$'\E[01;38;5;74m' \
    LESS_TERMCAP_me=$'\E[0m' \
    LESS_TERMCAP_se=$'\E[0m' \
    LESS_TERMCAP_so=$'\E[38;5;246m' \
    LESS_TERMCAP_ue=$'\E[0m' \
    LESS_TERMCAP_us=$'\E[04;38;5;146m' \
    /usr/bin/man "$@"
}

refresh() {
    source "$CONFIG_LOCATION/source-all.zsh"
}

# Create a directory and cd into it
mkcd() {
    if [[ "$#" -eq 0 ]]; then
        print "No arguments"
    else
        if [[ "$#" -gt 1 ]]; then
            print "Only creating $1"
        fi
        mkdir "$1"
        cd "$1"
    fi
}

