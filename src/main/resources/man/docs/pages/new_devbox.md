# Run a New Devbox #
Follow these steps to start up a new devbox on a machine that is able to run Docker
containers:
1. Run `./scripts/start-dev-box.sh` (Optional: you can specify the version with `-v`
   and the name with `-n`)
1. Exec into the devbox `docker exec -it <devbox_name> bash`
1. Disable screen locking: `xset s off; xset s noblank`
1. Startup vncserver session `vncserver`
1. Log in over VNC
1. Generate ssh key `ssh-keygen`
1. Run `devbox doctor` to [validate setup](#verify-my-devbox-setup)

# Verify My Devbox Setup #
The `devbox doctor` command verifies that the Devbox is set up fully. Once the
developer has created their ssh keys, it will automatically clone the necessary
repositories (as specified in the `doctor.env` file) inside the `~/git` folder.

Feel free to read through the `/opt/devbox/doctor/doctor.sh` script for more information.
