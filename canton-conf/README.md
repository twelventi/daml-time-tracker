> To showcase, start a minimal Canton ledger (1 participant node, 1 domain node, single config file) and use the Navigator to show how the template can be used.

# How I launched the canton network

Start the Canton network using the command:

From the directory where I have canton:
`bin/canton -c ../../canton-conf/canton-conf.conf --bootstrap connect.canton`

This will use the the `canton-conf.conf` file to setup a canton network with one participant, and one domain node.

A party can be created for our first user in the canton console by running
`@ participant1.parties.enable("user1")`

Then, in order to use the navigator to view the network and the deployed templates, run
`@ utils.generate_navigator_conf(participant1)`

This will create a file that can be passed to the command:
```
                        # this is where the ledger api
                        # is running
$ damn navigator server localhost 5011 -c /path/to/backend-participant.conf
```

to launch the navigator


