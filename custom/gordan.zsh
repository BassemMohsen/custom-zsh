#
# A collection of useful commands and aliases
#

export PATH=$PATH:${HOME}/bin:/usr/local/bin

export EDITOR=vim

alias grep='grep --color=auto'

alias chx='chmod 755'
alias chr='chmod 644'

alias yolo="sudo"
alias svim="sudo vim"

alias gk='gitk --all .'
alias bbake='time bitbake -k'

# Prints command history and finds a specific command if specified 
# Usage: showhist [command]
showhist () {
    history | grep -i "$1"
    return;
}

# Prints running processes and finds a specific process if specified 
# psg [process name]
psg () {
    ps aux | grep $1
}

# Prints available packages and finds a specific string if specified 
# Usage: showpkg [pkg]
showpkg () {
      apt-cache pkgnames | grep -i "$1" | sort | grep -i "$1"
      return;
}

# Prints dd progress every 2 seconds
# Usage: dd_progress <dd args>...
dd_progress() {
    set +m
    dd "$@" 2>&1 > /dev/null &
    DDPID=$!
    while kill -0 "$DDPID" &> /dev/null; do
        sleep 2
        kill -USR1 "$DDPID" &> /dev/null
    done
    set -m
}

# Find files with a specific string in their name. Ignore dot files. 
# Usage: fn <string> [dir]
fn() {
    DIR="."
    if [ -n $2 ]; then 
        DIR=$2
    fi
    find -L $DIR -iname "*$1*" -not -path '*/\.*' | grep --ignore-case --color=always "$1"
}

# Recursively search through files in directories to find a specific string in a file.
# Usage: fs <string> [dir]
fs() {
    DIR="."
    if [ -n $2 ]; then
        DIR=$2
    fi
    grep -Ri --color=always "$1" $DIR
}

# Print usage helper function for yocto-recipe-bump
__yocto-recipe-bump-print-usage() {
    echo
    echo "Create a Yocto recipe bump which will containt all the commit subjects!"
    echo "Usage: yocto-recipe-bump -y <path-to-recipe> -r <path-to-repository>"
    echo "Example: yocto-recipe-bump -y demo.bb -r /path/to/demo"
    return
}

# Command line tool to perform a Yocto recipe bump.
# The commit message will contain subjects of all diff commits.
# Usage: yocto-recipe-bump -y <path-to-recipe> -r <path-to-repository>
yocto-recipe-bump() {
    while getopts ":h:y:r:" opt; do
        case $opt in
        y)
            RECIPE=`basename $OPTARG`
            RECIPE_DIR=`dirname $OPTARG`
            ;;
        r)
            REPOSITORY_DIR=$OPTARG
            ;;
        h)
            __yocto-recipe-bump-print-usage
            return;
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            __yocto-recipe-bump-print-usage
            return;
            ;;
        esac
    done

    CURRENT_DIR=$PWD

    echo "Recipe: $RECIPE"
    echo "Path to recipe: $RECIPE_DIR"
    echo "Path to repository: $REPOSITORY_DIR"

    if [ ! -f "$RECIPE_DIR/$RECIPE" ];
        then
        echo "$RECIPE_DIR/RECIPE doesn't exist! Exiting!"
        __yocto-recipe-bump-print-usage
        return;
    fi

    if [ ! -d "$REPOSITORY_DIR" ];
        then
        echo "$REPOSITORY_DIR doesn't exist! Exiting!"
        __yocto-recipe-bump-print-usage
    fi

    cd $REPOSITORY_DIR

    # Sanity check 
    if [ ! -d ".git" ]; 
        then
        echo "Sanity check failed!"
        echo "$REPOSITORY_DIR is not a git repository! Exiting!"
        __yocto-recipe-bump-print-usage
        return;
    fi

    REPOSITORY_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    echo "Current repository branch: $REPOSITORY_BRANCH"
    if [ "$REPOSITORY_BRANCH" != "master" ];
        then
        read -p "The repository ($REPOSITORY_DIR) is not on master. Continue? [y|N]: " CHOICE
        if [ "$CHOICE" = "y" ] || [ "$CHOICE" = "Y" ]; then
            echo "Continue..."
        else
            echo "Exiting!"
            return;
        fi
    fi
     
    echo 

    # Get previous commit hash from the recipe
    COMMIT_OLD=`grep "SRCREV =" $RECIPE_DIR/$RECIPE | grep -o '".*"' | sed 's/"//g'`
    # Get current HEAD commit hash from the repository
    COMMIT_NEW=`git rev-parse HEAD`

    COMMIT_HEADINGS=`git log --format=%s $COMMIT_OLD..$COMMIT_NEW`
    # Print commit diff subjects 
    git log --format=%s $COMMIT_OLD..$COMMIT_NEW 

    echo

    cd $RECIPE_DIR
    # Replace recipe commit hash
    sed -i "/$COMMIT_OLD/c\SRCREV = \"$COMMIT_NEW\"" $RECIPE
    git add $RECIPE

    # Commit message; modify to your own needs
    echo "$RECIPE: Recipe bump" > .commit_message
    echo "" >> .commit_message
    echo "$COMMIT_HEADINGS" >> .commit_message
    echo "" >> .commit_message

    git commit --file .commit_message
    rm -f .commit_message
    echo "Done!"

    return;
}
