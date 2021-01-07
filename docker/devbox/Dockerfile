FROM vanilla

RUN yum -y clean all && \
    yum -y groupinstall "Server with GUI" --skip-broken && \
    yum -y groupinstall "MATE" && \ 
    yum -y clean all
    
#Breaking up since the groupinstalls take forever and dont change often.
RUN yum -y install tigervnc-server firefox zsh && \
    echo "mate-session" >~/.Xclients && \
    chmod +x ~/.Xclients && \
    pip3 install grip && \
    yum -y clean all

# Add users limits and comment out max logins (from pam_limits) in limits.conf
ARG LIMITS_CONF="/etc/security/limits.d/98-users.conf"
RUN touch ${LIMITS_CONF} && \
    echo '@users   - nproc 65536' >>${LIMITS_CONF} && \
    echo '@users   - nofile 65536'>>${LIMITS_CONF} && \
    sed -i.bak '/^#/! {/maxlogins/ s/^/#/}' /etc/security/limits.conf && \
    sed -i.bak '/X11DisplayOffset/s/^#//g' /etc/ssh/sshd_config && \
    sed -i.bak '/X11UseLocalhost/s/^#//g' /etc/ssh/sshd_config

# ============================================= #
# Preconfigure a developer user...              #
# ID will be changed to ID of devbox owner when #
# they initialize their devbox                  #
# ============================================= #

ARG TEMP_USER="changeme"
ARG GROUP="developers"
RUN groupadd ${GROUP} && \
    echo "%${GROUP} ALL=(ALL)    NOPASSWD: ALL" >> /etc/sudoers && \
    useradd -g ${GROUP} ${TEMP_USER} -s /bin/zsh && \
    usermod -aG docker ${TEMP_USER}

# ============================================= #
# Install development support software packages #
# ============================================= #

# Copy files to mounted /datashare directory
ARG PACKAGE_DIR="/datashare/software"
ADD software ${PACKAGE_DIR}



# Replace vncserver with wrapper
RUN mv /usr/bin/vncserver /etc/vncserver && \
    cp ${PACKAGE_DIR}/vncserver_wrapper.sh /usr/bin/vncserver && \
    chmod 755 /usr/bin/vncserver && \
    ln -s /usr/bin/Xvnc /etc/Xvnc && \
    ln -s /usr/bin/vncpasswd /etc/vncpasswd && \
    ln -s /usr/bin/vncconfig /etc/vncconfig && \
    ln -s /usr/bin/x0vncserver /etc/x0vncserver
    
# Install IntelliJ
ARG IDEA_DIR="/opt/idea"
ARG IDEA_INSTALL_NAME="idea-IC-202.6397.94"
RUN mkdir ${IDEA_DIR} && \
    tar zxf ${PACKAGE_DIR}/idea/*.tar.gz -C ${IDEA_DIR} && \
    ln -snf ${IDEA_DIR}/${IDEA_INSTALL_NAME} ${IDEA_DIR}/current && \
    find ${PACKAGE_DIR}/idea/plugins -name "*.zip" -exec unzip -o {} -d ${IDEA_DIR}/current/plugins \; && \
    chown -R root:users ${IDEA_DIR} && \
    chmod -R 755 ${IDEA_DIR}
# Install Postman
ARG POSTMAN_DIR="/opt/postman"
ARG POSTMAN_INSTALL_NAME="Postman"
RUN mkdir ${POSTMAN_DIR} && \
    tar zxf ${PACKAGE_DIR}/postman/*.tar.gz -C ${POSTMAN_DIR} && \
    ln -snf ${POSTMAN_DIR}/${POSTMAN_INSTALL_NAME} ${POSTMAN_DIR}/current && \
    chown -R root:users ${POSTMAN_DIR} && \
    chmod -R 755 ${POSTMAN_DIR}

# Add compose root ssh key
RUN cp ${PACKAGE_DIR}/ssh_keys/* /tmp

# ================================================================= #
# Simple smoke testing:
# vncserver -- cannot run with '-SecurityTypes None' (as TEMP_USER)
# intellij -- can start up the process (as TEMP_USER)
# postman -- can start up the process (as TEMP_USER)
# ================================================================= #

USER ${TEMP_USER}
RUN vncserver -SecurityTypes None 2>&1 >/dev/null|| exit 0&& \
    ${IDEA_DIR}/current/bin/idea.sh \& && \
    ps -ef | grep idea && \
    ${POSTMAN_DIR}/current/bin/Postman \& && \
    ps -ef | grep Postman

USER root

# Copy in devbox scripts  # Do this last to avoid rebuilding most of the image

ARG SETUP_DEST="/opt"
ADD devbox.tar.gz ${SETUP_DEST}
RUN chown -R root:users ${SETUP_DEST}/devbox && \
    chmod 777 -R ${SETUP_DEST}/devbox

ENTRYPOINT ["/bin/zsh"]