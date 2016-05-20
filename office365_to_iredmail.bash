                                    #!/bin/bash

loginadm = 'your@login.adm'
passwordadm = 'youadmpassword'

password_user_default = 'default_passord_user'


function do_backup() {

	if [ -e $LOCKFILE ] ; then
	echo "already running"
	exit
	else
	touch $LOCKFILE
	doveadm mailbox list -A | cut -d " " -f 1  | uniq | sort $sort_seq  >  $userlist

	date=`date +%X_-_%x`

	echo "" >> $logfile
	echo "------------------------------------" >> $logfile
	echo "IMAPSync started..  $date" >> $logfile
	echo "" >> $logfile

	{ while  read  u1 ; do

		echo "Syncing User $user"
		date=`date +%X_-_%x`
		echo "Start Syncing User $u1"
		echo "Starting $u1 $date" >> $logfile


		imapsync --maxmessagespersecond 4 --nofoldersizes --nocheckmessageexists --useuid --tmpdir /var/vmail/cache_imapsync  --nosyncacls --subscribe --syncinternaldates --skipsize  \
		--host1 outlook.office365.com       --port1 993 --ssl1 --user1 "$u1"                --authuser1 $loginadm     --password1  $passwordadm --noauthmd5 --useheader 'Message-ID'  \
		--host2 127.0.0.1 --authmech2 PLAIN --port2 993 --ssl2 --user2 "$u1"                --authuser2 "$u1"  --password2  $password_user_default \
		--exclude '^Anota&AOcA9Q-es'  \
		--exclude '^Calend&AOE-rio' \
		--exclude 'Sugeridos' \
		--exclude 'Lync' \
		--exclude '^Hist&APM-rico' \
		--exclude '^Journal' \
		--exclude '^Lixo' \
		--exclude '^Problemas' \
		--exclude '^RSS' \
		--exclude '^Rascunhos' \
		--exclude '^Tarefas' \
		--exclude 'Exclu&AO0-dos' \
		--exclude 'Sa&AO0-da' \
		--exclude '^Contatos' \
		--regextrans2 's,^Itens Enviados,Sent,g' \
		--regextrans2 's,\.,_,g'
		--nocheckselectable


		date=`date +%X_-_%x`
		echo "User $user done"
		echo "Finished $user $date" >> $logfile
		echo "" >> $logfile

	done ; } < $userlist

	date=`date +%X_-_%x`

	echo "" >> $logfile
	echo "IMAPSync Finished..  $date" >> $logfile
	echo "------------------------------------" >> $logfile
	fi
}



function do_clean() {
	# make sure the lockfile is removed when we exit and then claim it
	trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
	echo $$ > ${LOCKFILE}

	# do stuff
	sleep 10

	rm -f ${LOCKFILE}
}


case "$1" in
	normal)
		logfile="backupemailsSeqNormal.log"
		userlist="userlistackupemailsSeqNormal.txt"
		LOCKFILE='/scripts/tmp/lock_normal.txt'
		touch $logfile
		touch $userlist
		sort_seq=" -V"
		sort_seq=" -V"
		do_backup
		do_clean
	;;
	reverso)
		logfile="backupemailsSeqReverso.log"
		userlist="userlistackupemailsSeqReverso.txt"
		LOCKFILE='/scripts/tmp/lock_reverso.txt'
		touch $logfile
		touch $userlist
		sort_seq=" -r"
		do_backup
		do_clean
	;;
	random)
		logfile='log/backupemailsSeqiRandom.log'
		userlist="userlistackupemailsSeqRamdom.txt"
		LOCKFILE='/scripts/tmp/lock_random.txt'
		touch $logfile
		touch $userlist
		sort_seq="  -R"
		do_backup
		do_clean
	;;
	*)
		echo "Usage: IMAPSYNC  {normal | reverso | random }" >&2
		exit 3
	;;
esac
