# Maven Versioning #
The Devbox runs `mvn` commands in a Maven docker container instead of having it
installed on the `localhost`. This enables the developer to use whichever version
of Maven they want without having to manually install/upgrade to/downgrade to that version.

In order to change the Maven version you're running as, edit the `MVN_VERSION` variable
inside the `~/.bashrc` in the running Devbox.

Running `mvn` commands will still look the same as running locally due to the `mvn`
function inside the `~/.bashrc`.
