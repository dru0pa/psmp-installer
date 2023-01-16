#!/bin/bash
#This script it to automat the installation of the PSMP server on RHEL /CentOS /ROcky Linux
#The script will install CyberArk PSMP for 12.x
#Place script in smame folder as the psmpparms.sample, vault.ini, CARKpsmp
#Working on the version file names for RPMs
#Script is written by Andrew 
#email dru0pa@gmail.com
echo Setting the IP address of the Vault server
echo Type the ip address of the Vault server
read IPA
sed -i s/'1.1.1.1'/$IPA/g vault.ini

echo setting the Installation Folder for the file psmpparms.sample
pwd > folder.txt
FOLDER=`cat folder.txt`
echo $FOLDER
sed -i '5d' psmpparms.sample
sed -i '5 i InstallationFolder='$FOLDER'' psmpparms.sample


echo Edit the psmpparms.sample and save to /var/tmp/psmpparms
sed -i s/AcceptCyberArkEULA=No/AcceptCyberArkEULA=Yes/g psmpparms.sample
cp -f psmpparms.sample /var/tmp/psmpparms


echo chmod CreateCredFile
chmod 755 CreateCredFile

echo Create the administrator account to do the installation the file is called user.cred and user.cred.entropy
echo Type the password for the Administrator account for the installation
read pass
./CreateCredFile user.cred Password -Username administrator -Password $pass -EntropyFile


echo Disable NSCD
systemctl stop nscd.service nscd.socket
systemctl disable nscd.service nscd.socket

echo install CARKpsmp-infra
rpm -ivh IntegratedMode/CARKpsmp-infra-*.rpm
echo install CARKpsmp
rpm -ivh CARKpsmp-*.rpm

echo Clean Up after install
echo  return vault.ini back to default
sed -i '2d' vault.ini
sed -i '2 i ADDRESS=1.1.1.1' vault.inils

echo return psmpparms.sample back to default
sed s/AcceptCyberArkEULA=Yes/AcceptCyberArkEULA=No/g psmpparms.sample
sed -i '5d' psmpparms.sample
sed -i '5 i InstallationFolder=<Folder Path>' psmpparms.sample

echo remove psmpparms from temp folder
rm -rf /var/tmp/psmpparms

echo remove user.cred and user.cred.entropy files
rm -rf user.cred
rm -rf user.cred.entropy
echo remove folder.txt
rm -rf folder.txt

echo Check for the following by scrolling up.
echo Machine hardening was completed successfully.
echo Installation process was completed successfully.

echo If not check password and run the following command to uninstall the components listed
echo rpm -qa | grep CAR

echo Reboot server now if all successfully.
