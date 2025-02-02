
# Save cores on a remote AWS instances

This executes tg-save-kg-core in the background, disconnected from the
terminal.  It uses standard terminal mechanisms and isn't very user-
friendly.

## Prepare the environment

Use `ssh` to access the host.  You need the TrustGraph CLI environemnt set
up...

```
. /usr/local/trustgraph/env/bin/activate
```

Also make sure you have an appropriate place to store the data e.g.
ubuntu's home direcory.

## Start the core save

The command looks like this...
```
nohup tg-save-kg-core -o cats.core > cats.log 2>&1 </dev/null &
```

Where `cats.core` is the core file you want to save.
and `cats.log` is an output log file, useful to inspect errors if something
fails.

## Log out of SSH

This will disconnect the background job from the shell.

## Load data

You probably need to log back in to set up port 8888 port forward.

Load a document and check that you can see the core file growing.
If it's growing, all good leave it to work.

## Stop the save

Monitor Grafana, and when the queues are empty it is safe to stop the core
save.

Find the process ID using `ps -ef | grep tg-save-kg-core`.

```
ubuntu@ip-172-38-60-38:~$ ps -ef | grep tg-save-kg-core
ubuntu     20461       1  0 20:00 ?        00:00:00 /usr/local/trustgraph/env/bin/python3 /usr/local/trustgraph/env/bin/tg-save-kg-core -o cats.core
ubuntu     21738   20655  0 20:04 pts/0    00:00:00 grep --color=auto tg-save-kg-core
```

The process we want is the first in the list, the command line should
match what you entered earlier.  The process ID is the second column i.e.
20461 in this case.  To end the process:

```
kill 20461
```

Check the process is no more:

```
ubuntu@ip-172-38-60-38:~$ ps -ef | grep tg-save-kg-core
ubuntu     21738   20655  0 20:04 pts/0    00:00:00 grep --color=auto tg-save-kg-core
```

and it safe to use the core file.

## Copy the core

Use ssh to copy the file e.g. you can use the `scp` command (part of ssh)
to access the file:
```
scp -i ssh-private.key ubuntu@x.x.x.x:cats.core local-cats.core
```

