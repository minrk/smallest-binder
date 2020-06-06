# smallest-binder

Attempts at different versions of the "smallest" image for [Binder](https://mybinder.org)

Try it out: [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/minrk/smallest-binder/master)


## Strategies

- use alpine linux for base image (not the alpine-based python images!)
- two-stage builds to avoid installer files in runtime image (runtime has no pip)
- PYTHONOPTIMIZE=2
- pyc-wheel to include only .pyc files in installed packages
- remove `__pycache__` for stdlib (ideally, we would keep only .opt-2, but I haven't figured that out yet)
Result (analyzed [dive](https://github.com/wagoodman/dive)): 81MB total

- 5.6MB for alpine base image
- 27MB for apk-installed python, pyzmq
- 48MB for pip-installed packages

### Why this might not make sense

The main reason to make a tiny image is launch time,
but the removal of `__pycache__` for the stdlib should
actually greatly *increase* launch time of everything after image pull,
in exchange for an only slightly reduced image size (~20-25MB saved).
