# Storing sensitive data in GPG encrypted documents

This tool is for the storage of sensitive data (e.g. passwords, account names, etc...) in a location not generally desirable for storing such things insecurely.  

The process is that a document is created in the `data/` directory (recursion OK) and then `encrypt.sh` is run by an administrator who has their public key already in the `pubkeys` directory. 

This will decrypt and re-encrypt all files in the `data/` directory with all keys in the `pubkeys/` directory as valid for decryption.

Likewise, if a key needs to be added or removed (e.g. new hire, separation), this key can be added to or removed from the `pubkeys/` directory and then the `encrypt.sh` can be run again to decrypt and re-encrypt all of the content.

# Using GPG

## How do I run GPG

The easiest/native way to use GPG is to do so from a UNIX-based TTY such as connected to a Linux server.  Secondly, one can use docker and the `centos:latest` iimage and map in a directory from your local system for the `.gnupg`.  The following example should work relatively well for Windows provided Docker for Windows is already installed and `Shared Drives` are configured.  See [Docker for Windows sharing host volumes](https://willi.am/blog/2016/07/30/docker-for-windows-sharing-host-volumes/).  

```
docker run -it -v %HOMEDRIVE%/%HOMEPATH%:.gnupg centos:latest /bin/bash
```

There are also native windows packages and the Cygwin based approach, both of which go beyond the scope of this document.


## Generate a GPG key

Whichever approach you choose to use, the next step is to generate a key.

It's quite straight forward.  You will generally run `gpg --gen-key` and it will take you through a series of questions including `Full Name` and `E-Mail Address`.  Please be sure to use your `amwater.com` E-Mail address.

Once you have done this, you can run the following command to generate an ASCII Armored export of your public key:

```
gpg --export --armor YOUR_EMAIL@amwater.com
```

The contents of this will start with:

```
-----BEGIN PGP PUBLIC KEY BLOCK-----
```

## Branch, commit, push, and create a PR

Next, you will need to clone the GIT repo, create a branch, place the output of the above command into the `pubkeys/` directory with the filename of your E-Mail address.  

Then you will do a `git commit` and a `git push`.

Subsequently, you will need to login to Github and create a Pull Request and add current project admin(s) to the reviewers list.  You should also reach out to them and ask them to PTAL (Please take a look).  

## Meanwhile...

The admin will then, provided all is well, pull down a clone of the branch you just created, run the `encrypt.sh` routine to re-encrypt all of the documents with all of the public keys and the one that was just added.

After this, the admin will `git commit -a` and `git push` followed by merging the PR in the Github project.

## Finally

Once the changes are merged into `master`, you can check that branch out and issue a `git pull` to update your local copy of the content.  You can do this either using GPG natively on a UNIX-based system, in Docker, or whatever other process you feel works best.  

Once this is done, the files in the `data/` directory will be decryptable with your private key.  

To test this, execute `gpg -d data/testfile.txt.asc` and follow the prompts.  Ultimately the output should end with:

```
the content in this file is being used to test the encryption and decryption.
```

