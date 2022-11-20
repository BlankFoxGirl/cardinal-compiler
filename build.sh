#!/bin/bash
CWD=$(pwd)

install_submodules_manually() {
    CONTENTS=$(cat src/.gitmodules | grep -E '(path|url).*' | cut -d " " -f 3)
    CWD=$(pwd)

    LAST=""
    for item in ${CONTENTS[@]};
    do
    cd $CWD/src
    STRINGHEAD=$( echo "$item" | cut -d '/' -f 1)
        if [[ "$STRINGHEAD" == "vendor" ]]
        then
            if [[ -d "$CWD/src/$item" ]]
            then
                LAST=$(echo "$item")
                echo "$item already exists."
                continue
            fi
            mkdir -p "$item"
            cd $item
            LAST=$(echo "$item")
        else
            if [[ -d "$CWD/src/$LAST/.git" ]]
            then
                echo "$LAST already installed."
                continue
            fi
            cd "$CWD/src/$LAST"
            echo "Installing $item"
            git init .
            git remote add origin $item
            res=$(git pull origin master 2>&1)
            if [[ "$res" == "fatal: couldn't find remote ref master" ]]
            then
                git pull origin main
            fi
        fi
    done
}

install_modules () {
    CWD=$(pwd)
    if [[ ! -d "$CWD/src/vendor" ]]
    then
        mkdir $CWD/src/vendor
        git submodule init
        git submodule update
    fi
    if [[ ! -d "$CWD/src/vendor/crashoz" ]]
    then
        echo "Unable to auto-install using GIT, trying another route."
        install_submodules_manually
    else
        echo "Submodules installed."
    fi
}

if [[ ! -d "$CWD/src" ]]
then
    mkdir "$CWD/src"
    git clone https://github.com/sarahjabado/cardinal-cpp.git "$CWD/src"
    install_modules
fi
if [[ ! -f "$CWD/src/vendor/crashoz/uuid_v4/build/Makefile" ]]
then
    cd src/vendor/crashoz/uuid_v4/
    mkdir build
    cd build
    cmake ..
    make
    cd $CWD
fi
if [[ ! -f "$CWD/src/vendor/sewenew/redis-plus-plus/build/Makefile" ]]
then
    cd $CWD/src/vendor/sewenew/redis-plus-plus/build && cmake .. && make
    cd $CWD
fi

cd $CWD/src/vendor/sewenew/redis-plus-plus/build && make install
cd $CWD

if [[ -d "$CWD/src/build/" ]]
then
    rm -rf $CWD/src/build/*
else
    mkdir $CWD/src/build
fi

cd $CWD/src/build && cmake .. && make

if [[ ! -f "$CWD/src/build/bin/libredis++.so.1" ]]
then
    cp $CWD/src/vendor/sewenew/redis-plus-plus/build/libredis++.so.1.3.6 $CWD/src/build/bin/libredis++.so.1
fi