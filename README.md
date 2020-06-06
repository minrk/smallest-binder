# smallest-binder

Attempts at different versions of the "smallest" image for [Binder](https://mybinder.org)

Try it out: [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/minrk/smallest-binder/master)


## Strategies

- use alpine linux for base image (not the alpine-based python images!)
- two-stage builds to avoid installer files in runtime image (runtime has no pip)
- PYTHONOPTIMIZE=2
- pyc-wheel to include only .pyc files in installed packages
- remove .dist-info package metadata (small savings)
- remove `__pycache__` for stdlib (ideally, we would keep only .opt-2, but I haven't figured that out yet)
Result (analyzed [dive](https://github.com/wagoodman/dive)): 81MB total

- 5.6MB for alpine base image
- 27MB for apk-installed python, pyzmq
- 48MB for pip-installed packages

## Simple version

A much simpler version can be found in [the simple branch](https://github.com/minrk/smallest-binder/blob/simple/Dockerfile),
which only does the simplest version of installation based on alpine.
This version has:

- 48MB to install python from api (not post-slimmed)
- 52MB to install notebook with pip ()

totalling out to 105MB, so the slimming strategy saves ~20MB
at the expense of being much more complicated and actually slower to build and slower at runtime.

## Why this might not make sense

The main reason to make a tiny image is launch time,
but the removal of `__pycache__` for the stdlib should
actually greatly *increase* launch time of everything after image pull,
in exchange for an only slightly reduced image size (~20-25MB saved).
