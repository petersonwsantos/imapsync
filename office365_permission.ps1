$mbxs = Get-user 

$loginadm = your@login.com.br 

foreach ($mbx in $mbxs) {
    Add-MailboxPermission       -identity $($mbx.UserPrincipalName)  -user  $loginadm -accessrights fullaccess -inheritancetype all
    sleep 1
}

foreach ($mbx in $mbxs) {
    echo " -------------------------"
    echo "  $($mbx.UserPrincipalName)"
    echo " -------------------------"	
    get-MailboxPermission       -identity $($mbx.UserPrincipalName)  -user $loginadm
    echo "      " 
    echo "      " 
    sleep 1
}
