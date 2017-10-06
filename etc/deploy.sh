#!/bin/sh

[ "$SSH" = "" ] && SSH=ssh
[ "$RSYNC" = "" ] && RSYNC=rsync
[ "$USERNAME" = "" ] && USERNAME=$USER

ROLE_NAME="play_microservice"
APP_ID="play-microservice"
CLUSTER_NAME="all"
INVENTORY="/opt/kashoo/ops/deploy.properties"
TIMESTAMP=`TZ=UTC date '+%Y-%m-%d_%H%M%S'`
REMOTE_USER="kashoo"
REMOTE_BASE="/opt/kashoo/$APP_ID"
REMOTE_RELEASES="$REMOTE_BASE/releases"
SSH_USER=$USERNAME

function usage() {
  echo "

  usage: $0 -e SERVERS [-i INVENTORY] [-c COMMAND] [-u REMOTE_USER] [-s SSH_USER]

  where:

    SERVERS  : <staging|production|development|util|\"list of machine names\">
    INVENTORY: Inventory file          (using: $INVENTORY)
    COMMAND  : <deploy|release>        (default: deploy and release)
    REMOTE_USER: name of user on remote system (default: kashoo)
    SSH_USER: name of user to issue rsync and ssh commands with (ie ssh server@$SSH_USER.  default: $USER)

  "
}

function log() {
  echo $(date '+%F %X') $1
}

function deploy() {
  log "DEPLOY: $1 $2"
  log "Deploying as $USERNAME to $2"
  $RSYNC -avz ./target/universal/$PACKAGE_NAME.tgz $1:/tmp/ || exit
  echo "Executing: $SSH -n $1 'chown $REMOTE_USER:$REMOTE_USER /tmp/$PACKAGE_NAME.tgz'"
  $SSH -n $1 "sudo chown $REMOTE_USER:$REMOTE_USER /tmp/$PACKAGE_NAME.tgz"
  [ $? -ne 0 ] && log "Failure syncing" && exit 1
}

# This is still under dev.
function release() {
  CMDS=( "sudo su $REMOTE_USER -c 'tar -xzvf /tmp/$PACKAGE_NAME.tgz -C $REMOTE_RELEASES'"
         "sudo su $REMOTE_USER -c 'mv $REMOTE_RELEASES/$PACKAGE_NAME $REMOTE_RELEASES/$TIMESTAMP'"
         "sudo su $REMOTE_USER -c 'rm /tmp/$PACKAGE_NAME.tgz'"
         "sudo su $REMOTE_USER -c '$REMOTE_BASE/shared/bin/$APP_ID-tanuki stop'"
         "sudo su $REMOTE_USER -c '$REMOTE_BASE/shared/bin/mark_release.sh latest'"
         "sudo su $REMOTE_USER -c '$REMOTE_BASE/shared/bin/$APP_ID-tanuki start'"
         "sudo su $REMOTE_USER -c '$REMOTE_BASE/shared/bin/mark_deploy.sh'")

  # now run through all commands and FAIL if any one fails
  for CMD in "${CMDS[@]}"; do
    log "Executing CMD: $SSH -n $1 \"$CMD\""
    $SSH -n $1 "$CMD";
    RETVAL=$?
    [ $RETVAL -ne 0 ] && log "Failure: exiting" && exit 1
    sleep 5
  done
}

function servers() {
  SERVERS=""

  case $ENV in
    production|staging|development|util)
      SERVERS=`grep "$ENV.$CLUSTER_NAME.$ROLE_NAME" $INVENTORY  | cut -d '=' -f 2`
      log "SERVERS:    $SERVERS"
      ;;
  esac
}

function getPackageName() {
  local filename=$(ls ./target/universal/*.tgz)
  if [[ ! -f $filename ]] ; then
    echo
  else
    basename $filename .tgz
  fi
}

function remote_cmd() {
  for server in $1 ; do
    NODE=`echo $server | cut -d: -f1`
    IP=`echo $server | cut -d: -f2`
    log "Run $2 on $NODE"
    if [[ $server =~ "@" ]] ; then
      $2 $IP $NODE
    else
      $2 $SSH_USER@$IP $NODE
    fi
  done
}

# Now we parse cmd line options
while getopts ":e:i:c:u:n:s:" opt; do
  case $opt in
    e)
      ENV=$OPTARG
      ;;
    c)
      cmd=$OPTARG
      ;;
    i)
      INVENTORY=$OPTARG
      ;;
    u)
      REMOTE_USER=$OPTARG
      ;;
    n)
      CLUSTER_NAME=$OPTARG
      ;;
    s)
      SSH_USER=$OPTARG
      ;;
  esac
done

PACKAGE_NAME=$(getPackageName)
if [ -z "$PACKAGE_NAME" ] ; then
  log "Error: Could not find a deployment package in ./target/universal/, exiting"
  exit 1
fi

if [ -z "$INVENTORY" -o ! -f "$INVENTORY" ] ; then
  INVENTORY=./etc/deploy.properties
fi

servers
if [ -z "$SERVERS" -o "$SERVERS" == " " ] ; then
  log "No servers defined, exiting"
  usage
  exit 1
else
  log "Using servers '$SERVERS'"
fi

case $cmd in
  deploy)
    remote_cmd "$SERVERS" deploy
  ;;
  release)
    remote_cmd "$SERVERS" release
  ;;
  *)
    remote_cmd "$SERVERS" deploy
    remote_cmd "$SERVERS" release
  ;;
esac

# If we get here, then lets ensure we exit with a valid code
log "Completed run of $0"
exit 0
