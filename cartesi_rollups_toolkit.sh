#!/bin/bash

shopt -s expand_aliases

SCRIPT_VERSION="0.4"
SCRIPT_TITLE="Cartesi Rollups ToolKit"
SCRIPT_FILE="cartesi_rollups_toolkit.sh"
SCRIPT_ALIAS_CMD="crt"

DOCKER_VER=""
DOCKER_VER_MIN="20.10.13"

DAPP_ISVALID=0
DAPP_ISEXAMPLE=0
DAPP_ROLLUPS_VER=""
DAPP_LANG=""
DAPP_ISLOWLEVEL=0
DAPP_STARTUP_POINT=""

ARG_ENV_ADDR='ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004"'


NC="\e[0m"
C_LOGO="\e[93m"
C_LBL_VER="\e[96m"
C_LBL_NAME="\e[93m"
C_LBL_CMD="\e[94m"
C_LBL_RUN="\e[96m"
C_LBL_MODE="\e[95m"
C_COMMENT="\e[90m"
C_H_TOPIC="\e[1;97m"
C_H_ARG="\e[96m"
C_H_NOTE="\e[3mNote: "
C_H_EX="\e[93m"
C_H_UC="\e[3;90m(not yet available) - "
C_H_UD="\e[3;90m(in development, still some issues) - "
C_ERR1="\e[91;40m"
C_ERR2="\e[91m"

WD=`pwd`

# Help and Info

LOGO_SIGN0="$C_LOGO _ _$NC"
LOGO_SIGN1="$C_LOGO\\_X_\\ $SCRIPT_TITLE: $NC"
show_logo() {
	echo -e "$C_LOGO _/\\_$NC"
	echo -e "$C_LOGO \\_X_\\  -- $SCRIPT_TITLE --$NC"
	echo -e "$C_LOGO   \\/$NC"
}

show_help() {
	show_logo
	echo
	echo -e "${C_H_TOPIC}DESCRIPTION${NC}"
	echo -e "\t$SCRIPT_TITLE is a tool that provides unified and simplified way of executing all of the task related to Cartesi rollups dapp."
	echo -e "\tThe tasks are: creating, building, deploying a dapp and also starting and stoping the rollup in both 'host' and 'prod' mode."
	echo -e "\tThis tool wraps all the required commands and provides easy to remember syntax to call them."
	echo -e "\tThe tool works equally with both custom dapps and Cartesi examples."
	echo
	echo -e "\tBefore using the script it must be installed with this command:"
	echo
	echo -e "\t\t${C_H_EX}./$SCRIPT_FILE install${NC}"
	echo
	echo -e "${C_H_TOPIC}EXAMPLES${NC}"
	echo
	echo -e "\t\t${C_H_EX}$SCRIPT_ALIAS_CMD -v${NC}"
	echo -e "\t\t\tShows information about the dapp in the current directory."
	echo
	echo -e "\t\t${C_H_EX}$SCRIPT_ALIAS_CMD prod start${NC}"
	echo -e "\t\t\tStarts the rollup in production mode."
	echo
	echo -e "\t\t${C_H_EX}$SCRIPT_ALIAS_CMD host stop${NC}"
	echo -e "\t\t\tStops the rollup from host mode."
	echo
	echo -e "\t\t${C_H_EX}$SCRIPT_ALIAS_CMD build all --hint${NC}"
	echo -e "\t\t\tShows the commands needed to build all (both rollup and machine) without actually executing them."
	echo
	echo -e "${C_H_TOPIC}ARGUMENTS${NC}"
	echo -e "\t${C_H_ARG}-h, --help${NC}"
	echo -e "\t\tShows this help page."
	echo
	echo -e "\t${C_H_ARG}-v, --version${NC}"
	echo -e "\t\tShows version and information about the dapp located in current directory."
	echo -e "\t\tAlso shows the current version of docker and if it meets the minimum requirements."
	echo
	echo -e "\t${C_H_ARG}install${NC}"
	echo -e "\t\tAllows this script to operate in any directory. It is set as alias and it can be called by typing '$SCRIPT_ALIAS_CMD'"
	echo -e "\t\tNote: Installation will take effect in newly opened shells."
	echo
	echo -e "\t${C_H_ARG}uninstall${NC}"
	echo -e "\t\t${C_H_UC}Remove the alias to this script.${NC}"
	echo
	echo -e "\t${C_H_ARG}-b, build${NC}"
	echo -e "\t\tBuilds the dapp. Build target must be specified after this argument."
	echo -e "\t\tBuild targets are:"
	echo -e "\t\t\t'rollup' or 'r' - builds the Cartesi rollup"
	echo -e "\t\t\t'machine' or 'm' - builds the Cartesi machine for the current dapp"
	echo -e "\t\t\t'all' or 'a' - builds both 'rollup' and 'machine' targets"
	echo
	echo -e "\t${C_H_ARG}-u, up, start${NC}"
	echo -e "\t\tStarts the rollup in 'host' or 'prod' mode."
	echo -e "\t\t${C_H_NOTE}The mode needs to be specified using the -m argument.$NC"
	echo
	echo -e "\t${C_H_ARG}-d, down, stop${NC}"
	echo -e "\t\tStops the rollup from 'host' or 'prod' mode."
	echo -e "\t\t${C_H_NOTE}The mode needs to be specified using the -m argument.$NC"
	echo
	echo -e "\t${C_H_ARG}-r, restart${NC}"
	echo -e "\t\tRestarts the rollup by stopping and then starting."
	echo -e "\t\tAlso works if both 'stop' and 'start' arguments are provided."
	echo -e "\t\t${C_H_NOTE}The mode needs to be specified using the -m argument.$NC"
	echo
	echo -e "\t${C_H_ARG}-g, go${NC}"
	echo -e "\t\tSame as 'start' then after user interrupt (Ctr+C) automatically calls 'stop'."
	echo
	echo -e "\t${C_H_ARG}-m, --mode${NC}"
	echo -e "\t\tSpecifies in what mode the dapp will run. Supported modes are 'host', 'prod', 'deploy', 'testnet'."
	echo
	echo -e "\t${C_H_ARG}host${NC}"
	echo -e "\t\tSpecifies that the docker images will be run as for 'host' mode."
	echo -e "\t\tSame as '-m host'"
	echo
	echo -e "\t${C_H_ARG}prod, production${NC}"
	echo -e "\t\tSpecifies that the docker images will be run as for 'prod' mode."
	echo -e "\t\tSame as '-m prod'"
	echo
	echo -e "\t${C_H_ARG}deploy${NC}"
	echo -e "\t\tSpecifies that the docker images will be run as step of the deployment process on a test network."
	echo -e "\t\tSame as '-m deploy'."
	echo
	echo -e "\t${C_H_ARG}testnet${NC}"
	echo -e "\t\tSpecifies that the docker images will be run for already deployed dapp on a test network."
	echo -e "\t\tSame as '-m testnet'."
	echo
	echo -e "\t${C_H_ARG}-c, create${NC}"
	echo -e "\t\t${C_H_UC}Creates new dapp at current directory.${NC}"
	echo
	echo -e "\t${C_H_ARG}--hint${NC}"
	echo -e "\t\tOnly shows command used to execute specified task without actually executing it."
	echo -e "\t\tWorks with: build, start, stop, restart, env-init"
	echo
	echo -e "\t${C_H_ARG}--bg${NC}"
	echo -e "\t\tStarts docker in detached mode (background) so no opened terminal is required to keep it running."
	echo
	echo -e "\t${C_H_ARG}-l, --log${NC}"
	echo -e "\t\tCreates log file with the ouput of the executed task. Log files are located in directory /logs."
	echo -e "\t\tWorks with: build, start, stop, restart"
	echo -e "\t\tNote: The executed command is piped to 'tee', so it outputs both on the screen and in a log file."
	echo
	echo -e "\t${C_H_ARG}dp-show${NC}"
	echo -e "\t\tShows the environment variables required for deployment and running a testnet."
	echo
	echo -e "\t${C_H_ARG}--ei, env-init${NC}"
	echo -e "\t\tInitializes host mode for the dapp by creating virtual environment and installing the required libraries."
	echo -e "\t\t${C_H_NOTE}Python only.${NC}"
	echo
	echo -e "\t${C_H_ARG}--er, env-run${NC}"
	echo -e "\t\t${C_H_UD}Runs the dapp in virtual environment when the rollup operates in host mode.${NC}"
	echo
	echo; echo;
}

# Version comparision
vercomp () {
    if [[ $1 == $2 ]]
    then
        echo 0
		return
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            echo 1
			return
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            echo 2
			return
        fi
    done
    echo 0
}

# Dapp, Rollups, Docker versions

get_docker_ver() {
	if [ -z "$DOCKER_VER" ]
		then DOCKER_VER=`docker version --format '{{.Server.Version}}'`
	fi
	echo "$DOCKER_VER";
}

is_vaild_dapp() {
	if test -f "docker-compose.override.yml"; then echo 1; else echo 0; fi;
}

is_example_dapp() {
	if [ $(is_vaild_dapp) = "1" ] && [ -f "../docker-compose.yml" ] && [ ! -f "docker-compose.yml" ] ; then echo 1; else echo 0; fi;
}

extract_rollups_version() {
	RES_extract_rollups_version=`cat $1 | grep 'image: cartesi/rollups-hardhat'`
	RES_extract_rollups_version=${RES_extract_rollups_version#*rollups-hardhat:}
	echo $RES_extract_rollups_version
}

count_files() {
	echo `find . -name "$1" | wc -l`
}


check_dapp_versions() {
	if [ $(is_vaild_dapp) = "1" ]; then
		DAPP_ISVALID=1;
		
		# find docker-compose file and determine dapp type
		FILE_DOCKER_COMPOSE="docker-compose.yml"
		if [ $(is_example_dapp) = "1" ]; then
			FILE_DOCKER_COMPOSE="../docker-compose.yml"
			DAPP_ISEXAMPLE=1
		fi
		
		# determine rollups version
		DAPP_ROLLUPS_VER=$(extract_rollups_version "$FILE_DOCKER_COMPOSE")
		
		# dertermine dapp language
		if [ $(count_files "*.py") != 0 ]; then DAPP_LANG="python"; fi;
		if [ $(count_files "*.lua") != 0 ]; then DAPP_LANG="lua"; fi;
		if [ $(count_files "*.cpp") != 0 ]; then DAPP_LANG="cpp"; fi;
		if [ $(count_files "*.rs") != 0 ]; then DAPP_LANG="rust"; fi;
		
		# determine if dapp is low level
		rollup_entry_point=`cat entrypoint.sh |  grep -v '^#' | grep "rollup-init "`
		if [ -z "$rollup_entry_point" ]; then DAPP_ISLOWLEVEL=1; else DAPP_ISLOWLEVEL=0; fi;
		
		#determine dapp startup script
		IFS=' '
		read -ra ADDR <<< $rollup_entry_point
		DAPP_STARTUP_POINT=${ADDR[-1]}
		
		
		# python
		# rollup-init python3 echo.py
		
		# lua
		# rollup-init lua echo.lua
		
		# C++
		# rollup-init ./echo-backend
		
		# Rust
		# rollup-init ./target/riscv64ima-cartesi-linux-gnu/release/echo-backend
		
		# Low level C++
		# ./low-level-backend
	fi	
}

require_dapp() {
	if [ $DAPP_ISVALID != 1 ]; then
		echo -e "${C_ERR2}This directory does not contain valid dapp!$NC"
		exit
	fi
}

show_version() {
	#require_dapp

	# script version
	echo -e "$SCRIPT_TITLE version: ${C_LBL_VER}$SCRIPT_VERSION$NC"

	# dapp/rollups version
	if [ $DAPP_ISEXAMPLE = 1 ]; then dapp_type="Cartesi example"; else dapp_type="Custom"; fi;
	if [ $DAPP_ISLOWLEVEL = 1 ]; then dapp_lowlevel=" (low level)"; fi;

	echo -e "Dapp type: $C_LBL_NAME$dapp_type$NC"
	echo -e "Dapp language: $C_LBL_NAME$DAPP_LANG$NC$dapp_lowlevel$NC"
	echo -e "Daap main script: $C_LBL_NAME$DAPP_STARTUP_POINT$NC"
	echo -e "Rollups version: $C_LBL_VER$DAPP_ROLLUPS_VER$NC"

	# docker version
	matchv_docker=$(vercomp $DOCKER_VER_MIN $(get_docker_ver))
	if [ $matchv_docker = "1" ]
		then status_docker="$C_ERR1 Mininmum Docker version requirement not met! $NC"
	fi
	echo -e "Docker version: $C_LBL_VER$(get_docker_ver)$NC $C_COMMENT(minimum required: $DOCKER_VER_MIN)$NC $status_docker"

}

# Script installation

is_installed() {
	IS_INSTALLED=`cat ~/.bashrc | grep cartesi_rollups_toolkit.sh`
	if [ -z "$IS_INSTALLED" ]; then echo 0; else echo 1; fi;
}

install() {
	if [ $(is_installed) = "0" ]; then
		echo alias $SCRIPT_ALIAS_CMD="'$WD/$SCRIPT_FILE'" >> ~/.bashrc
		# TODO: add to current terminal
		#alias $SCRIPT_ALIAS_CMD="$WD/$SCRIPT_FILE"
		#alias
		echo "\"$SCRIPT_TITLE\" installed. The changes will take effect in newly opened shell."
		echo "Type \"$SCRIPT_ALIAS_CMD\" to accessit from any directory."
	else
		echo -e "$C_ERR2\"$SCRIPT_TITLE\" is already installed.$NC"
	fi
}

uninstall() {
	if [ $(is_installed) = "1" ]; then
		# TODO: remove from ~/.bashrc
		# TODO: remove from current terminal
		#unalias cst
		echo "\"$SCRIPT_TITLE\" uninstalled."
	else
		echo -e "$C_ERR2\"$SCRIPT_TITLE\" is not installed.$NC"
	fi
}

# deployment profile

dp_show() {
	echo -e "NETWORK=${C_LBL_NAME}$NETWORK${NC}"
	echo -e "RPC_URL=${C_LBL_NAME}$RPC_URL${NC}"
	echo -e "WSS_URL=${C_LBL_NAME}$WSS_URL${NC}"
	echo -e "CHAIN_ID=${C_LBL_NAME}$CHAIN_ID${NC}"
	echo -e "DAPP_NAME=${C_LBL_NAME}$DAPP_NAME${NC}"
	if [ ! -z "$MNEMONIC" ]; then
		echo -e "MNEMONIC=${C_LBL_NAME}******${NC}"
	else
		echo -e "MNEMONIC="
	fi
}

dp_check() {
	DP_ENV_OK=1
	if [ -z "$NETWORK" ]; then
		echo -e "${C_ERR2}Error: Env variable not defined - \"NETWORK\" !${NC}"
		DP_ENV_OK=0
	fi
	if [ -z "$RPC_URL" ]; then
		echo -e "${C_ERR2}Error: Env variable not defined - \"RPC_URL\" !${NC}"
		DP_ENV_OK=0
	fi
	if [ -z "$WSS_URL" ]; then
		echo -e "${C_ERR2}Error: Env variable not defined - \"WSS_URL\" !${NC}"
		DP_ENV_OK=0
	fi
	if [ -z "$CHAIN_ID" ]; then
		echo -e "${C_ERR2}Error: Env variable not defined - \"CHAIN_ID\" !${NC}"
		DP_ENV_OK=0
	fi
	if [ -z "$DAPP_NAME" ]; then
		echo -e "${C_ERR2}Error: Env variable not defined - \"DAPP_NAME\" !${NC}"
		DP_ENV_OK=0
	fi
	if [ -z "$MNEMONIC" ]; then
		echo -e "${C_ERR2}Error: Env variable not defined - \"MNEMONIC\" !${NC}"
		DP_ENV_OK=0
	fi
	if [ $DP_ENV_OK == 0 ]; then
		echo -e "${C_ERR2}Required environment variables missing!${NC}"
		exit
	fi
}

dp_load() {
	if [ ! -f $ARG_DP_FILE ]; then
		echo -e "${C_ERR2}Error: File \"$ARG_DP_FILE\" does not exist!${NC}"
		exit
	fi
	#source "$ARG_DP_FILE"
	#$ARG_DP_FILE
	dp_show
}

# dp_create() {

# }

# dapp operations

verify_rollups_mode() {
	if [ "$ARG_MODE_ROLLUPS" != "host" ] && [ "$ARG_MODE_ROLLUPS" != "prod" ] && [ "$ARG_MODE_ROLLUPS" != "deploy" ] && [ "$ARG_MODE_ROLLUPS" != "testnet" ]; then
		echo -e "${C_ERR2}Invalid mode!${NC} Supported modes are '${C_LBL_MODE}host${NC}', '${C_LBL_MODE}prod${NC}', '${C_LBL_MODE}deploy${NC}', '${C_LBL_MODE}testnet${NC}'.${NC}"
		exit
	fi
}

task_title() {
	echo -e "$LOGO_SIGN0"; echo -e "${LOGO_SIGN1}${C_LBL_CMD}$1${NC}";
}

exec_cmd_piped() {
	$1 | $2
}

exec_cmd() {
	echo -e "${C_LBL_RUN}$ $1${NC}"
	if [ $ARG_HINT == 0 ]; then
		# create log if specified so
		if [ $ARG_LOG == 1 ] && [ ! -z $2 ]; then
			__dirlogs="logs"
			if [ ! -d $__dirlogs ]; then mkdir $__dirlogs; fi;
			__timestamp=$(date +%Y%m%d,%H%M,%S)
			__logfile="log-$__timestamp-$2.log"
			# execute the command piped to "tee" logger
			exec_cmd_piped "$1" "tee $__dirlogs/$__logfile"
		else
			# execute the command
			$1
		fi
	fi
}

dapp_build_rollup() {
	task_title "Building rollup..."
	if [ $DAPP_ISEXAMPLE = 1 ]; then
		cmd="docker buildx bake --load"
	else
		cmd="docker buildx bake -f docker-bake.hcl -f docker-bake.override.hcl --load"
	fi
	exec_cmd "$cmd" "build,rollup"
}

dapp_build_machine() {
	task_title "Building machine..."
	if [ $DAPP_ISEXAMPLE = 1 ]; then
		cmd="docker buildx bake machine --load"
	else
		cmd="docker buildx bake -f docker-bake.hcl -f docker-bake.override.hcl machine --load"
	fi
	exec_cmd "$cmd" "build,machine"
}

dapp_build() {
	task_title "Building dapp (target: $ARG_TARGET_BUILD) ..."
	if [ $ARG_TARGET_BUILD == "rollup" ] || [ $ARG_TARGET_BUILD == "all" ]; then
		dapp_build_rollup
	fi
	if [ $ARG_TARGET_BUILD == "machine" ] || [ $ARG_TARGET_BUILD == "all" ]; then
		dapp_build_machine
	fi
}

dapp_start() {
	verify_rollups_mode
	task_title "Starting dapp in ${C_LBL_MODE}$ARG_MODE_ROLLUPS${C_LBL_CMD} mode..."
	
	if [ $ARG_DOCKER_DETACHED == 1 ]; then _DD_MODE=" -d"; else _DD_MODE=""; fi;
	if [ $DAPP_ISEXAMPLE = 1 ]; then
		if [ $ARG_MODE_ROLLUPS = "host" ]; then
			cmd="docker compose -f ../docker-compose.yml -f ./docker-compose.override.yml -f ../docker-compose-host.yml up$_DD_MODE"
		fi
		if [ $ARG_MODE_ROLLUPS = "prod" ]; then
			cmd="docker compose -f ../docker-compose.yml -f ./docker-compose.override.yml up$_DD_MODE"
		fi
		if [ $ARG_MODE_ROLLUPS = "deploy" ]; then
			dp_check
			cmd="docker compose -f ../deploy-testnet.yml up"
		fi
		if [ $ARG_MODE_ROLLUPS = "testnet" ]; then
			dp_check
			cmd="docker compose -f ../docker-compose-testnet.yml -f ./docker-compose.override.yml up$_DD_MODE"
		fi
	else
		if [ $ARG_MODE_ROLLUPS = "host" ]; then
			cmd="docker compose -f ./docker-compose.yml -f ./docker-compose.override.yml -f ./docker-compose-host.yml up$_DD_MODE"
		fi
		if [ $ARG_MODE_ROLLUPS = "prod" ]; then
			cmd="docker compose up$_DD_MODE"
		fi
		if [ $ARG_MODE_ROLLUPS = "deploy" ]; then
			dp_check
			cmd="docker compose -f ./deploy-testnet.yml up"
		fi
		if [ $ARG_MODE_ROLLUPS = "testnet" ]; then
			dp_check
			cmd="docker compose -f ./docker-compose-testnet.yml -f ./docker-compose.override.yml up$_DD_MODE"
		fi
	fi
	exec_cmd "$cmd" "start,$ARG_MODE_ROLLUPS"
}

dapp_stop() {
	verify_rollups_mode
	task_title "Stopping dapp from ${C_LBL_MODE}$ARG_MODE_ROLLUPS${C_LBL_CMD} mode..."
	if [ $DAPP_ISEXAMPLE = 1 ]; then
		if [ $ARG_MODE_ROLLUPS = "host" ]; then
			cmd="docker compose -f ../docker-compose.yml -f ./docker-compose.override.yml -f ../docker-compose-host.yml down -v"
		fi
		if [ $ARG_MODE_ROLLUPS = "prod" ]; then
			cmd="docker-compose -f ../docker-compose.yml -f ./docker-compose.override.yml down -v"
		fi
		if [ $ARG_MODE_ROLLUPS = "deploy" ]; then
			dp_check
			cmd="docker compose -f ../deploy-testnet.yml down -v"
		fi
		if [ $ARG_MODE_ROLLUPS = "testnet" ]; then
			dp_check
			cmd="docker compose -f ../docker-compose-testnet.yml -f ./docker-compose.override.yml down -v"
		fi
	else
		if [ $ARG_MODE_ROLLUPS = "host" ]; then
			cmd="docker compose -f ./docker-compose.yml -f ./docker-compose.override.yml -f ./docker-compose-host.yml down -v"
		fi
		if [ $ARG_MODE_ROLLUPS = "prod" ]; then
			cmd="docker compose down -v"
		fi
		if [ $ARG_MODE_ROLLUPS = "deploy" ]; then
			dp_check
			cmd="docker compose -f ./deploy-testnet.yml down -v"
		fi
		if [ $ARG_MODE_ROLLUPS = "testnet" ]; then
			dp_check
			cmd="docker compose -f ./docker-compose-testnet.yml -f ./docker-compose.override.yml down -v"
		fi
	fi
	exec_cmd "$cmd" "stop,$ARG_MODE_ROLLUPS"
}

# virtual env tasks
only_python() {
	if [ $DAPP_LANG != "python" ]; then
		echo -e "${C_ERR2}This operation is supported only for dapps written in Pythoin!${NC}"
		exit
	fi
}

env_init() {
	task_title "Initializing environement and installing requirements..."
	only_python
	if [ -d ".env" ] && [ $ARG_HINT == 0 ]; then
		echo -e "${C_ERR2}Environment already initialized!${NC}"
	else
		exec_cmd "python3 -m venv .env"
		exec_cmd ". .env/bin/activate"
		exec_cmd "pip install -r requirements.txt"
		exec_cmd "deactivate"
	fi
}

run() {
	# TODO: Still some issues
	python3 $DAPP_STARTUP_POINT
	#. .env/bin/activate
	#${ARG_ENV_ADDR} python3 ${DAPP_STARTUP_POINT}
	#echo 'ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004" python3 $DAPP_STARTUP_POINT'
	#python3 $DAPP_STARTUP_POINT
	#deactivate
}

env_run_raw() {
	. .env/bin/activate
	ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004" python3 ${DAPP_STARTUP_POINT}
	deactivate
}

env_run() {
	task_title "Starting dapp in environment..."
	only_python
	if [ ! -d ".env" ] && [ $ARG_HINT == 0 ]; then
		echo -e "${C_ERR2}Environment not initialized!${NC} Use '$SCRIPT_ALIAS_CMD --ei' to initialize it."
	else
		if [ $ARG_HINT == 0 ]; then
			#env_run_raw
			ARG_ENV_ADDR="ROLLUP_HTTP_SERVER_URL=\"http://127.0.0.1:5004\""
			exec_cmd "$ARG_ENV_ADDR python3 $DAPP_STARTUP_POINT"
			#exec_cmd "./__run.sh"
			#exec_cmd ". .env/bin/activate"
			#exec_cmd "export ${ARG_ENV_ADDR}"
			#exec_cmd "echo ${ARG_ENV_ADDR}"
			#exec_cmd "python3 ${DAPP_STARTUP_POINT}"
			#exec_cmd "deactivate"

			# TODO: Still some issues
			#ARG_ENV_ADDR="ROLLUP_HTTP_SERVER_URL=\"http://127.0.0.1:5004\""

			#cmd="${ARG_ENV_ADDR} python3 ${DAPP_STARTUP_POINT}"
			#echo -e "${C_LBL_RUN}$ $cmd${NC}"
			#run

			#. .env/bin/activate
			##$cmd
			##${ARG_ENV_ADDR} python3 ${DAPP_STARTUP_POINT}
			#ROLLUP_HTTP_SERVER_URL="http://127.0.0.1:5004" python3 $DAPP_STARTUP_POINT
			#deactivate
		else
			echo -e "${C_LBL_RUN}$ . .env/bin/activate${NC}"
			echo -e "${C_LBL_RUN}$ $ARG_ENV_ADDR python3 $DAPP_STARTUP_POINT${NC}"
			echo -e "${C_LBL_RUN}$ deactivate${NC}"
		fi
	fi
}

#operations flags
ARG_OP_HELP=0
ARG_OP_VER=0
ARG_OP_INSTALL=0
ARG_OP_UNINSTALL=0
ARG_OP_BUILD=0
ARG_OP_DEPLOY=0
ARG_OP_START=0
ARG_OP_STOP=0
ARG_OP_STARTSTOP=0
ARG_OP_RESTART=0
ARG_OP_ENV_INIT=0
ARG_OP_ENV_RUN=0
ARG_HINT=0
ARG_LOG=0
ARG_TARGET_BUILD=""
ARG_MODE_ROLLUPS=""
ARG_DOCKER_DETACHED=0
ARG_DP_SHOW=0
ARG_DP_LOAD=0
ARG_DP_CREATE=0
ARG_DP_FILE=""

POSITIONAL_ARGS=()

# if no arguments
if [ "$#" = 0 ]; then
	show_logo
	echo; echo "Use \"-h\" argument for help"; echo;
	exit
fi

# parse arguments
while [[ $# -gt 0 ]]; do
	case $1 in
		-h|--help)
			ARG_OP_HELP=1
			shift # past argument
			;;
		-v|--version)
			ARG_OP_VER=1
			shift # past argument
			;;
		"install")
			ARG_OP_INSTALL=1
			shift # past value
			;;
		"uninstall")
			ARG_OP_UNINSTALL=1
			shift # past value
			;;
		-m|--mode)
			ARG_MODE_ROLLUPS="$2"
			if [ $ARG_MODE_ROLLUPS = "h" ]; then ARG_MODE_ROLLUPS="host"; fi;
			if [ $ARG_MODE_ROLLUPS = "p" ]; then ARG_MODE_ROLLUPS="prod"; fi;
			if [ $ARG_MODE_ROLLUPS = "d" ]; then ARG_MODE_ROLLUPS="deploy"; fi;
			if [ $ARG_MODE_ROLLUPS = "t" ]; then ARG_MODE_ROLLUPS="testnet"; fi;
			if [ $ARG_MODE_ROLLUPS = "production" ]; then ARG_MODE_ROLLUPS="prod"; fi;
			shift # past argument
			shift # past value
			;;
		"prod"|"production")
			ARG_MODE_ROLLUPS="prod"
			shift # past value
			;;
		"host")
			ARG_MODE_ROLLUPS="host"
			shift # past value
			;;
		"deploy")
			ARG_MODE_ROLLUPS="deploy"
			shift # past value
			;;
		"testnet")
			ARG_MODE_ROLLUPS="testnet"
			shift # past value
			;;
		--bg)
			ARG_DOCKER_DETACHED=1
			shift # past argument
			;;
		-b|"build")
			ARG_OP_BUILD=1
			ARG_TARGET_BUILD="$2"
			if [ $ARG_TARGET_BUILD = "r" ]; then ARG_TARGET_BUILD="rollup"; fi;
			if [ $ARG_TARGET_BUILD = "m" ]; then ARG_TARGET_BUILD="machine"; fi;
			if [ $ARG_TARGET_BUILD = "a" ]; then ARG_TARGET_BUILD="all"; fi;
			shift # past argument
			shift # past value
			;;
		-y|"deploy")
			ARG_OP_DEPLOY=1
			shift # past argument
			;;
		-c|"create")
			shift # past argument
			;;
		-u|"up"|"start")
			ARG_OP_START=1
			shift # past argument
			;;
		-d|"down"|"stop")
			ARG_OP_STOP=1
			shift # past argument
			;;
		-r|"restart")
			ARG_OP_RESTART=1
			shift # past argument
			;;
		-g|"go")
			ARG_OP_STARTSTOP=1
			shift # past argument
			;;
		--ei|"env-init")
			ARG_OP_ENV_INIT=1
			shift # past argument
			;;
		--er|"env-run")
			ARG_OP_ENV_RUN=1
			shift # past argument
			;;
		--hint)
			ARG_HINT=1
			shift # past argument
			;;
		-l|--log)
			ARG_LOG=1
			shift # past argument
			;;
		"dp-show"|"dp-s")
			ARG_DP_SHOW=1
			shift # past argument
			;;
		"dp-load"|"dp-l")
			ARG_DP_LOAD=1
			ARG_DP_FILE=$2
			shift # past argument
			shift # past value
			;;
		"dp-create"|"dp-c")
			ARG_DP_CREATE=1
			shift # past argument
			;;
		-*|--*)
			echo "Unknown option $1"
			exit 1
			;;
		*)
			echo $1
			POSITIONAL_ARGS+=("$1") # save positional arg
			shift # past argument
			;;
	esac
done

#process operations

# Operation: Show help
if [ $ARG_OP_HELP = 1 ]; then
	show_help
	exit
fi


# Operation: Uninstal Cartesi Rollups ToolKit
if [ $ARG_OP_UNINSTALL = 1 ]; then
	uninstall
	exit
fi

# Operation: Install Cartesi Rollups ToolKit
if [ $ARG_OP_INSTALL = 1 ]; then
	install
	exit
fi

check_dapp_versions
require_dapp

# Operation: Show versions
if [ $ARG_OP_VER = 1 ]; then
	show_version
	exit
fi

# Operation: Init host mode
if [ $ARG_OP_ENV_INIT = 1 ]; then
	env_init
	exit
fi

# Operation: Run host mode
if [ $ARG_OP_ENV_RUN = 1 ]; then
	env_run
	exit
fi

# Operation: Build dapp (example and custom)
if [ $ARG_OP_BUILD = 1 ]; then
	dapp_build
	exit
fi

if [ $ARG_OP_DEPLOY = 1 ]; then
	# TODO: 
	exit
fi

# Operation: Stop dapp (example and custom, host and prod modes)
if [[ $ARG_OP_RESTART = 1  ||  ( $ARG_OP_START = 1  &&  $ARG_OP_STOP = 1 ) ]]; then
	task_title "Restarting dapp..."
	dapp_stop
	dapp_start
	exit
fi

# Operation: Start dapp (example and custom, host and prod modes)
if [ $ARG_OP_START = 1 ]; then
	dapp_start
	exit
fi

# Operation: Stop dapp (example and custom, host and prod modes)
if [ $ARG_OP_STOP = 1 ]; then
	dapp_stop
	exit
fi

# Operation: Start, then after user interrupt (Ctr+C) automatically stop
if [ $ARG_OP_STARTSTOP = 1 ]; then
	dapp_start
	dapp_stop
	exit
fi


# Deployment Profile - Show
if [ $ARG_DP_SHOW = 1 ]; then
	dp_show
	dp_check
	exit
fi

# Deployment Profile - Load
if [ $ARG_DP_LOAD = 1 ]; then
	dp_load
	exit
fi

# Deployment Profile - Create
if [ $ARG_DP_CREATE = 1 ]; then
	dp_create
	exit
fi
