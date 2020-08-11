# The Datawave Devbox #

This project contains the source for building the Datawave Devbox docker image.
This is the docker-compose version of the devbox, meaning the container will
support running Datawave in a docker-compose network. Since all the supporting
Datawave stack will be running inside docker-compose containers, the Devbox 
itself will be stripped down (no Accumulo, Hadoop, Zookeeper, etc.). It will
only have software installed that support development, not running local test
deployments.

What's left TODO in this repo?
NOW:
- Write manual
- Debug the .gitlab-ci.yml
  - Push to docker hub
LATER:
- Create prepackaged queries for Postman
- Mirror repo

Read more about how to use the Devbox in the [devbox manual](src/main/resources/man/docs/devbox_manual.md).

# How to... #

## Build the Devbox ##
When building a new version of the Devbox, you will need to:
1. Build the vanilla docker image
1. Build the maven project
1. Build the devbox docker image (it depends on the vanilla image)

We have automated this process in the helper script (`scripts/build.sh`). If you
would like to build a new version, simply run: `./scripts/build.sh all`

The script has some different options to enable to runner to tag and push the built
images. Run `./scripts/build.sh help` for more information about these options.

The command format must be as follows (the options should always come *before* the
specified command with a `--` delimiting them:
- `./scripts/build.sh [<opt1> <opt2> ... --] <cmd>`

## Deploy a new Devbox Version ##
We have a GitLab job that automatically deploys new Devbox versions to the registry
on `master` branch tags. See `.gitlab-ci.yml` for how this is done. However, if you
would like to do it manually (this is not recommended), you will use the build script.

Before running `build.sh`, change the version of the Maven project to match the new
release. After doing so, commit and push the changes to the repository.

When running `build.sh`, specify the version you would like to tag the image as via the
`-v` option and add the `-p` option as well to tell the script to push the images to the
registry after they have been built.
```bash
./scripts/build.sh -v <ver1> -v <ver2> <ver3> ... -p -- all
```

## Access the Devbox Manual ##
The Devbox comes shipped with a manual to enable developers to read various
pieces of documentation if they have questions about how to do something.

Run `devbox man open` to access it.
