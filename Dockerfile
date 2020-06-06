FROM alpine:3.12 as builder

RUN apk --no-cache add \
    python3 \
    python3-dev \
    py3-pip \
    py3-wheel \
    py3-pyzmq

# build wheels
RUN python3 -mpip wheel \
    -w wheels \
    notebook || echo "pyzmq failed, that's okay"

ENV PYTHONOPTIMIZE=2
# slim installed python to only level-2 optimized files
RUN python3 -mpip install pyc_wheel
RUN for whl in wheels/*.whl; do \
      python3 -m pyc_wheel $whl; \
    done

RUN python3 -m pip install \
    --no-warn-script-location \
    --no-cache \
    --ignore-installed \
    --no-deps \
    --user \
    wheels/*.whl

# remove pip metadata. No turning back!
RUN find $HOME/.local -name '*.dist-info' | xargs rm -r

FROM alpine:3.12

# omit pip, save 10MB
# remove all __pycache__ files
# these make startup faster, but are technically redundant
# it would be better to omit all .py files and keep only .opt-2.pyc instead,
# but I can't quite figure that out
RUN apk --no-cache add \
    python3 \
    py3-pyzmq \
 && find /usr/lib/python3.8 -name '__pycache__' | xargs rm -r


# create user with a home directory
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV HOME /home/${NB_USER}
ENV PATH /home/${NB_USER}/.local/bin:${PATH}

# COPY install files since we are installing without pip!
COPY --from=builder --chown=$NB_UID:$NB_UID /root/.local $HOME/.local

RUN adduser -D \
    -g "Default user" \
    -u ${NB_UID} \
    ${NB_USER}
WORKDIR ${HOME}
USER ${USER}
