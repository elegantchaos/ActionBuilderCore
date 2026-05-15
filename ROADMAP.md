# ROADMAP

Ideas / tasks for later consideration.

## Github Action

Move most of the work to a github action?
The generated workflow becomes much simpler, and invokes the action to do most of the heavy lifting.

## Swift Scripts

Replace the embedded bash scripts with Swift code / command line tools.

Have the workflow fetch and build the tools (probably by cloning this repo), then run them.

The tools would need to compile on all supported platforms, and using the earliest supported Swift version.

Alternatively we could download pre-compiled binaries, but that is likely to cause a maintenance headache.
