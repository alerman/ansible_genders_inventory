TODO

## Datawave Repo ##
The purpose of the Devbox is to support [Datawave](TODO) development, so of course
this repo will need to be cloned locally! :)


## Datawave Deployment ##
The Datawave repository will contain `docker-compose` yaml files for starting up a
Datawave deployment inside a `docker-compose` network. It will also contain scripts
to support easy start up / tear down of different deployment components via the
Datawave quickstart.

For more information on how to use the `docker-compose` deployment, navigate to the
[docker-compose](./compose.md) page.

## Ansible Repo ##
The [Ansible repository](TODO) will have various Ansible scripts for controlling
software within the `docker-compose` cluster. For example:
- starting / stopping Datawave ingest
- starting / stopping Accumulo
- starting / stopping Hadoop
- etc.