#!/bin/bash
CWD=$(pwd)

install_submodules_manually() {
    CONTENTS=$(cat .gitmodules | grep -E '(path|url).*' | cut -d " " -f 3)
    CWD=$(pwd)

    LAST=""
    for item in ${CONTENTS[@]};
    do
    cd $CWD
    STRINGHEAD=$( echo "$item" | cut -d '/' -f 1)
        if [[ "$STRINGHEAD" == "vendor" ]]
        then
            if [[ -d "$CWD/$item" ]]
            then
                LAST=$(echo "$item")
                echo "$item already exists."
                continue
            fi
            mkdir -p "$item"
            cd $item
            LAST=$(echo "$item")
        else
            if [[ -d "$CWD/$LAST/.git" ]]
            then
                echo "$LAST already installed."
                continue
            fi
            cd "$CWD/$LAST"
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
    if [[ ! -d "$CWD/vendor" ]]
    then
        mkdir $CWD/vendor
        git submodule init
        git submodule update
    fi
    if [[ ! -d "$CWD/vendor/crashoz" ]]
    then
        echo "Unable to auto-install using GIT, trying another route."
        install_submodules_manually
    else
        echo "Submodules installed."
    fi
}

if [[ ! -d "$CWD/Cardinal" ]]
then
    echo "This container must be ran within a Cardinal Context."
    exit 1
fi

install_modules

if [[ ! -f "$CWD/vendor/crashoz/uuid_v4/build/Makefile" ]]
then
    cd src/vendor/crashoz/uuid_v4/
    mkdir build
    cd build
    cmake ..
    make
    cd $CWD
fi
if [[ ! -f "$CWD/vendor/sewenew/redis-plus-plus/build/Makefile" ]]
then
    cd $CWD/vendor/sewenew/redis-plus-plus/build && cmake .. && make
    cd $CWD
fi

cd $CWD/vendor/sewenew/redis-plus-plus/build && make install
cd $CWD

if [[ -d "$CWD/build/" ]]
then
    rm -rf $CWD/build/*
else
    mkdir $CWD/build
fi

cd $CWD/build && cmake .. && make

if [[ ! -f "$CWD/build/bin/libredis++.so.1" ]]
then
    cp $CWD/vendor/sewenew/redis-plus-plus/build/libredis++.so.1.3.6 $CWD/build/bin/libredis++.so.1
fi

if [[ ! -f "$CWD/build/bin/libcardinal.so" ]]
then
    cp "$CWD/build/lib/libcardinal.so" "$CWD/build/bin/libcardinal.so"
fi