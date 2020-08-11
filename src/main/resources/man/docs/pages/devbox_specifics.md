# What is the Devbox? #
The devbox is a development environment with the specific purpose of 
supporting Datawave development. 

The "Devbox" itself is a docker container running on a host machine.
It only contains software necessary for development support. There is no
software installed that would support deploying Datawave onto the localhost
(e.g. Accumulo, Hadoop, etc.). Instead of installing these locally, they are
run in a [docker-compose datawave environment](./datawave.md#datawave-deployment).

It is easy to [start up a new devbox](./new_devbox.md#run-a-new-devbox) as
the heavy lifting is done by various bash scripts. Once you have your new
devbox running, you can execute a script to
[verify the devbox setup](./new_devbox.md#verify-my-devbox-setup). It will
tell you the next steps needed for having a fully configured devbox.

The Devbox has the following software installed:
- Postman - A REST client that has prepackaged Datawave queries for use with the
  `docker-compose` datawave deployment
- IntelliJ
- Firefox
- Maven - Developers run `mvn` commands via a [Maven docker image](./maven.md)
  in order to enable developers to use whatever maven version they want. See your
  `~/.bashrc` for how this is accomplished.
- `vncserver`
- `git`
- `docker`
- `docker-compose`

## Devbox Helper Scripts ##
The Devbox has a helper script which can be run via the `devbox` command. Run `devbox help`
to see the different operations that are available. Once your Devbox is completely setup, you
should only really need to run the `devbox man open` command to access this manual.

You can take a look at the helper scripts in `/opt/devbox`.
