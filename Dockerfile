FROM alpine:3.12

RUN apk --no-cache add \
    python3 \
    py3-pip \
    py3-pyzmq

RUN python3 -mpip install --no-cache notebook

# create user with a home directory
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}
ENV PATH /home/${NB_USER}/.local/bin:${PATH}

RUN adduser -D \
    -g "Default user" \
    -u ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}
USER ${USER}
