#!/bin/bash


data_directory="data/"

available_keys=($(gpg --list-secret-keys --with-colons | awk -F: '$1=="uid" { print $10 }' | sed 's/.*<\([^>]*\)>$/\1/g'))

if [ ! -z ${GPGID} ]; then
  echo "Using specified GPG Key ID ${GPGID}"
  gpgkey=${GPGID}
else
  echo "Using default GPG Key ID ${available_keys[0]}"
  gpgkey=${available_keys[0]}
fi

match=0

for key in ${available_keys[@]}; do
  if [[ ${key} = ${gpgkey} ]]; then
    match=1;
    break
  fi
done

if [[ ${match} = 0 ]]; then
  echo "GPG Key ID ${gpgkey} NOT found"
  exit 1
fi

gpg_passphrase=""

echo -n "Enter passphase for GPG Key ID ${gpgkey}: "
read -s gpg_passphrase
echo

recipient_list="$(ls pubkeys/)"

recipient_args=""

tmpkeyring=$(mktemp)

for recipient in ${recipient_list}; do
  gpg --primary-keyring=${tmpkeyring} --import "pubkeys/${recipient}"

  if [ $? -ne 0 ]; then
    echo "Unable to import key ${recipient} into temporary keyring ${tmpkeyring}, exiting"
    exit 4
  fi

  recipient_args="${recipient_args} --recipient ${recipient}"
done

echo "Decrypting existing files"

for file in $(find ${data_directory} -type f -name '*.asc' -print); do
  echo "Decrypting file ${file}"
  #gpg --passphrase "${gpg_passphrase}" --pinentry-mode loopback --batch --yes -o "$(echo ${file} | sed 's/\.asc$//g')" -d ${file}
  gpg -o "$(echo ${file} | sed 's/\.asc$//g')" -d ${file}

  if [ $? -ne 0 ]; then
    echo "Unable to decrypt file ${file}, exiting"
    exit 2
  fi

  echo "Removing encrypted file ${file}"
  rm ${file}

done

echo "Encrypting all files"

for file in $(find ${data_directory} -type f -not -name '*.asc' -not -name '.gitignore'); do
  echo "Encrypting file ${file}"
  gpg --primary-keyring ${tmpkeyring} --batch $(echo ${recipient_args}) --trust-model always --armor --encrypt ${file}

  if [ $? -ne 0 ]; then
    echo "Unable to encrypt file ${file}, exiting"
    exit 3
  fi

  echo "Removing clear file ${file}"
  rm -f ${file}
done

echo "Finished"

rm ${tmpkeyring}

