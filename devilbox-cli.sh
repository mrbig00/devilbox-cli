#!/bin/bash
#
# Devilbox-cli v0.0.2: A minimal cli tool to interact with devilbox from anywhere
# https://github.com/louisgab/devilbox-cli
#

DEVILBOX_PATH="$HOME/devilbox"
ENV_FILE=".env"
PHP_CONFIG="PHP_SERVER="
APACHE_CONFIG="HTTPD_SERVER=apache-"
MYSQL_CONFIG="MYSQL_SERVER=mysql-"
DOCROOT_CONFIG="HTTPD_DOCROOT_DIR="
WWWPATH_CONFIG="HOST_PATH_HTTPD_DATADIR="
DBPATH_CONFIG="HOST_PATH_MYSQL_DATADIR="
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;32m"
COLOR_YELLOW="\033[0;33m"
COLOR_DEFAULT="\033[0m"

################################################################################
## FORMATING HELPERS
################################################################################

error() {
    echo -e "${COLOR_RED}Error! ${COLOR_DEFAULT}${1}" >&2
    exit 1
}

success() {
    echo -e "${COLOR_GREEN}Done! ${COLOR_DEFAULT}${1}"
}

info() {
    echo -e "${COLOR_YELLOW}Info: ${COLOR_DEFAULT}${1}"
}

################################################################################
## GENERIC VERSIONS HELPERS
################################################################################

isVersionExisting () {
    local config=$1
    local version=$2
    if grep -qF "$config$version" "$ENV_FILE" ;then
        echo 0
    else
        echo 1
    fi
}

getCurrentVersion () {
    local config=$1
    local current
    current=$(grep -Eo "^$config+[.0-9]*" "$ENV_FILE" | sed "s/.*$config//g")
    echo "$current"
}

getAllVersions () {
    local config=$1
    local all
    all=$(grep -Eo "^#*$config+[.0-9]*" "$ENV_FILE" | sed "s/.*$config//g")
    echo "$all"
}

setVersion () {
    local config=$1
    local new=$2
    local current
    local isvalid
    current="$(getCurrentVersion "$config")"
    isvalid="$(isVersionExisting "$new")"
    if [[ $isvalid -eq 0 ]]; then
        sed -i -e "s/\(^#*$config$current\).*/#$config$current/" "$ENV_FILE"
        sed -i -e "s/\(^#*$config$new\).*/$config$new/" "$ENV_FILE"
        if [[ "$(getCurrentVersion "$config")" = "$new" ]]; then
            echo 0
        else
            echo 1
        fi
    else
        echo 1
    fi
}

################################################################################
## CONFIG HELPERS
################################################################################

getCurrentConfig () {
    local config=$1
    local current
    current=$(grep -Eo "^$config+[/.a-z0-9]*" "$ENV_FILE" | sed "s/.*$config//g")
    echo "$current"
}

setConfig () {
    local config=$1
    local new=$2
    local current
    current="$(getCurrentConfig "$config")"
    sed -i -e "s/\(^#*$config${current//\//\\\/}\).*/$config${new//\//\\\/}/" "$ENV_FILE"
    if [[ "$(getCurrentConfig "$config")" = "$new" ]]; then
        echo 0
    else
        echo 1
    fi
}

################################################################################
## READABLE HELPERS
################################################################################

isReadableVersionExisting () {
    local type=$1
    local config=$2
    local version=$3
    if [[ "$(isVersionExisting "$config" "$version")" -eq 0 ]] ;then
        success "$type version $version is available"
    else
        error "$type version $version does not exists"
    fi
}

getReadableCurrentVersion () {
    local type=$1
    local config=$2
    local current
    current=$(getCurrentVersion "$config")
    if [[ -n "$current" ]]; then
        info "$type current version is $current"
    else
        error "Couldnt retrieve current version of $type"
    fi
}

getReadableAllVersions () {
    local type=$1
    local config=$2
    local all
    all=$(getAllVersions "$config")
    if [[ -n "$all" ]]; then
        info "$type available versions:"
        echo "$all"
    else
        error "Couldnt retrive available versions of $type"
    fi
}

setReadableVersion () {
    local type=$1
    local config=$2
    local new=$3
    if [[ "$(setVersion "$config" "$new")" = "0" ]]; then
        success "$type version updated to $new"
    else
        error "$type version change failed"
    fi
}

getReadableCurrentConfig () {
    local type=$1
    local config=$2
    local current
    current=$(getCurrentConfig "$config")
    if [[ -n "$current" ]]; then
        info "$type current config is $current"
    else
        error "Couldnt retrieve current config of $type"
    fi
}

setReadbleConfig () {
    local type=$1
    local config=$2
    local new=$3
    if [[ "$(setConfig "$config" "$new")" = "0" ]]; then
        success "$type config updated to $new"
    else
        error "$type config change failed"
    fi
}

################################################################################
## APACHE FUNCTIONS
################################################################################


getCurrentApacheVersion () {
    getReadableCurrentVersion "Apache" "$APACHE_CONFIG"
}

getAllApacheVersions () {
    getReadableAllVersions "Apache" "$APACHE_CONFIG"
}

setApacheVersion () {
    local new=$1
    setReadableVersion "Apache" "$APACHE_CONFIG" "$new"
}

################################################################################
## PHP FUNCTIONS
################################################################################


getCurrentPhpVersion () {
    getReadableCurrentVersion "PHP" "$PHP_CONFIG"
}

getAllPhpVersions () {
    getReadableAllVersions "PHP" "$PHP_CONFIG"
}

setPhpVersion () {
    local new=$1
    setReadableVersion "PHP" "$PHP_CONFIG" "$new"
}

################################################################################
## MYSQL FUNCTIONS
################################################################################

getCurrentMysqlVersion () {
    getReadableCurrentVersion "MySql" "$MYSQL_CONFIG"
}

getAllMysqlVersions () {
    getReadableAllVersions "MySql" "$MYSQL_CONFIG"
}

setMysqlVersion () {
    local new=$1
    setReadableVersion "MySql" "$MYSQL_CONFIG" "$new"
}

################################################################################
## DOCUMENT ROOT FUNCTIONS
################################################################################

getCurrentDocumentRoot () {
    getReadableCurrentConfig "Document root" "$DOCROOT_CONFIG"
}

setDocumentRoot () {
    local new=$1
    setReadbleConfig "Document root" "$DOCROOT_CONFIG" "$new"
}

################################################################################
## PROJECTS PATH FUNCTIONS
################################################################################

getCurrentProjectsPath () {
    getReadableCurrentConfig "Projects path" "$WWWPATH_CONFIG"
}

setProjectsPath () {
    local new=$1
    setReadbleConfig "Projects path" "$WWWPATH_CONFIG" "$new"
}

################################################################################
## DATABASES PATH FUNCTIONS
################################################################################

getCurrentDatabasesPath () {
    getReadableCurrentConfig "Databases path" "$DBPATH_CONFIG"
}

setDatabasesPath () {
    local new=$1
    setReadbleConfig "Databases path" "$DBPATH_CONFIG" "$new"
}

################################################################################
## GENERAL FUNCTIONS
################################################################################

showUsage () {
	red='\033[0;31m'
	green='\033[1;32m'
	NC='\033[0m' # No Color
	bold=$(tput bold)
	normal=$(tput sgr0)    
    
    echo ""
    echo -e "Usage: $0 [OPTION]..."
    echo ""
    echo -e "${bold}${green}-a=[x.x],--apache=[x.x]${normal}     Set a specific apache version"
    echo -e "${bold}${green}-p=[x.x],--php=[x.x]${normal}        Set a specific php version"
    echo -e "${bold}${green}-m=[x.x],--mysql=[x.x]${normal}      Set a specific mysql version"
    echo -e "${bold}${green}-a=*,--apache=*${normal}             Get all available apache versions"
    echo -e "${bold}${green}-p=*,--php=*${normal}                Get all available php versions"
    echo -e "${bold}${green}-m=*,--mysql=*${normal}              Get all available mysql versions"
    echo -e "${bold}${green}-p,--php${normal}                    Get current php version"
    echo -e "${bold}${green}-a,--apache${normal}                 Get current apache version"
    echo -e "${bold}${green}-m,--mysql${normal}                  Get current mysql version"
    echo -e "${bold}${green}-r=[path],--root=[path]${normal}     Set the document root"
    echo -e "${bold}${green}-r,--root${normal}                   Get the current document root"
    echo -e "${bold}${green}-w=[path],--www=[path]${normal}      Set the path to projects"
    echo -e "${bold}${green}-w,--www${normal}                    Get the current path to projects"
    echo -e "${bold}${green}-d=[path],--database=[path]${normal} Set the path to databases"
    echo -e "${bold}${green}-d,--database${normal}               Get the current path to databases"
    echo -e "${bold}${green}-s,--start${normal}                  Start the devilbox docker containers"
    echo -e "${bold}${green}--shell${normal}                     Enter in the devilbox docker shell"
    echo -e "${bold}${green}-k,--kill${normal}                   Kill all docker containers ${red}${bold}(NOT JUST DEVILVOX)${normal}"
    echo ""
}

startDevilbox () {
    docker-compose up -d httpd php mysql mailhog
}

stopDevilbox () {
	docker kill $(docker ps -q)
}

enterShell () {
	cmd="$DEVILBOX_PATH/shell.sh"
	$cmd
}

main () {
    if [[ ! -d "$DEVILBOX_PATH" ]]; then
        error "Devilbox not found, please make sure it is installed in your home directory."
    fi
    cd "$DEVILBOX_PATH" || return
    for i in "$@"; do
        case $i in
            -h|--help) showUsage; shift;;
            -a=\*|--apache=\*) getAllApacheVersions; shift;;
            -a=*|--apache=*) setApacheVersion "${i#*=}"; shift;;
            -a|--apache) getCurrentApacheVersion; shift;;
            -p=\*|--php=\*) getAllPhpVersions; shift;;
            -p=*|--php=*) setPhpVersion "${i#*=}"; shift;;
            -p|--php) getCurrentPhpVersion; shift;;
            -m=\*|--mysql=\*) getAllMysqlVersions; shift;;
            -m=*|--mysql=*) setMysqlVersion "${i#*=}"; shift;;
            -m|--mysql) getCurrentMysqlVersion; shift;;
            -r=*|--root=*) setDocumentRoot "${i#*=}"; shift;;
            -r|--root) getCurrentDocumentRoot; shift;;
            -w=*|--www=*) setProjectsPath "${i#*=}"; shift;;
            -w|--www) getCurrentProjectsPath; shift;;
            -d=*|--database=*) setDatabasesPath "${i#*=}"; shift;;
            -d|--database) getCurrentDatabasesPath; shift;;
            -s|--start) startDevilbox; shift;;
            -k|--kill) stopDevilbox; shift;;
			--shell) enterShell; shift;;
            *) error "Unknown command $i"; exit 1;;
        esac
    done
}

################################################################################
## MAIN
################################################################################
main "$@"
