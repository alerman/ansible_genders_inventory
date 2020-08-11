# The Datawave Docker-Compose Cluster #

## Docker-Compose Dockerfiles ##
It actually isn't necessary to know where these live when using the Devbox.
However, if you would like to know more about the `docker-compose` cluster and how
it has been set up / maintained, please navigate to [this repository](TODO).

## How do I... ##

### Do a new Datawave deployment? ###

Inside the `datawave` project, there is a script that does the build, setup, and deployment for you
automatically. This script can either deploy the current version of the `datawave` project
in your local git repo, or you can specify a specific version of `datawave` by the tag.

Steps performed by the script when deploying the `datawave` project on your localhost:
1. Build the new RPM
1. Stage that RPM in the compose cluster's yum repository
1. Start up the cluster
1. Install the new RPM to the `ingestmaster`
1. Start up ingest

Steps performed by the script when deploying a specific `datawave` version tag:
1. Pull that tag's docker image from the registry
1. Determine what stack versions the `datawave` tag depends on
1. Start up the full stack with the tagged `datawave` image specified by the user 

### control the compose cluster? ###

There are two different ways to control the compose cluster depending on what you're trying to
accomplish. You can either control the running containers or the software running on the containers.
For example, do you want to restart the Docker containers running the Accumulo processes?
Or do you want to ssh into those containers and restart the Accumulo processes running there? You can
think of this as either restarting the *servers* or the *processes* running on the servers.

#### Controlling Containers ####

Inside the `datawave` project, there is a `compose-ctl.sh` script that enables developers to easily get
set up with a fresh `datawave` deployment. This script controls the containers running the various
components of the software stack which is architected by the various `docker-compose*.yml` files stored
alongside the script in the `datawave` project.

You can use this script to start, stop, and get the status of the different components of the compose cluster.
See the following for an example sequence of commands using that script:
```bash
# Start up the full stack
./compose-ctl.sh stack up
# Get the status of the full stack
./compose-ctl.sh stack status
# Stop the ingest conainer
./compose-ctl.sh ingest down
# Start the ingest container
./compose-ctl.sh ingest up
# View the status of the ingest container
./compose-ctl.sh ingest status
```
NOTE: Restarting containers like above will also rerun the startup process from square one. The container state will
be erased doing this...so if you're actively working on the `ingestmaster` to try to debug something, restarting the
container will result in losing the current state of the `ingestmaster` container. If you wish to restart only the ingest
processes on the `ingestmaster`, you should run the Ansible playbook that does that instead.

#### Controlling Processes ####

We have a collection of Ansible playbooks available for running common operations in the compose cluster.

TODO

### SSH into a container? ###

We've configured the docker-compose cluster to use password-less SSH. This has been accomplished
by generating a root ssh key used across the entire cluster and adding it to your devbox's ssh
keys. We have also added a DNS service inside the cluster to enable your devbox to resolve
compose containers by hostname.

Try it out!

1. Start up your compose cluster (TODO -- how do we do this?)
2. ssh into one of the containers
```
ssh root@zoo1
```