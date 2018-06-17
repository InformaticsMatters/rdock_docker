# Docker builds for rDock docking program

For details about rDock look [here](http://rdock.sourceforge.net/)

## Code changes

Note: the rDock source code is modified slightly to remove the check that the ligand structures are 3D structures. 
The way that rDock does this check is very picky and often real 3D structures fail this check.
A better solution is needed for this. See [this commit](https://github.com/InformaticsMatters/rdock_docker/commit/c07a70f4e4b7113203aa7ceceb177205da59977b) for the changes.

## Kitchen sink image

This was the original rDock image that we created. We call it a `kitchen sink` image as the image contains not only the rDock binaries but also the entire
build infrastructure that was needed to compile it. This includes gcc, make and a raft of other things. It also includes runtime tools such as Python
and OpenBabel. The consequence of this is that whilst you end up with an image that contains lots of useful goodies and might be useful for hacking, it
comes in at ~500MB in size, which not only means it takes a long time to pull over the internet, but it has a large attack surface for hackers to
try to get into, and so it makes a poor image for running production systems that will be public facing. See below for the more recent buildah-based images 
that are much better suited to production use.

* `Dockerfile` is a build for rdock. Find image on Dockerhub at [informaticsmatters/rdock](https://hub.docker.com/r/informaticsmatters/rdock).
* nextflow/Dockerfile also contains [Nextflow](http://nextflow.io) which is useful for running more complex pipelines. Find image on Dockerhub at 
[informaticsmatters/rdock_nextflow](https://hub.docker.com/r/informaticsmatters/rdock_nextflow).


## Buildah images

In contrast to the kitchen sink images we also create minimal images using the [buildah](https://github.com/projectatomic/buildah) tool.
These images are named `informaticsmatters/rdock-mini`.
The general concept has been described in the [smaller containers](https://www.informaticsmatters.com/category/containers/index.html) series of posts
on the [Informatics Matters blog](https://www.informaticsmatters.com/blog.html).

These images contain only a minimal centos:7 operating system, a few standard Linux utilities (bash and the coreutils packages), the `popt` runtime library
needed by rDock and Perl as rDock includes some Perl scripts. The result is an image that is only ~100MB in size, ~5x smaller than the kitchen sink image.

To build this image:

### Step 1
Build the Docker image from which we are going to build the `buildah-mini` image. This is based on a Centos7 image and contains all the build infrastructure
that is needed to build rDock from the source code.
```
docker build -f Dockerfile-buildah -t informaticsmatters/rdock-buildah .
```

### Step 2
Use this image to build the buildah binaries and load these into a minimal Centos7 based image:
```
sudo ./build.sh
```

This does 2 things:

1. Fires up the container and executes the `buildah-build.sh` script that compiles the code and uses `buildah` to create a new image containing the `rdlock` binaries.
2. Push that buildah image to a local Docker image named `informaticsmatters/rdock-mini` so that it can also be run from `docker`.

``` 

### Step 3 
Optionally push the image to Docker Hub:

```
docker push informaticsmatters/rdock-mini:latest
```
You need the necessary privileges for this. The image can be found on Docker Hub at 
[informaticsmatters/rdock-mini/](https://hub.docker.com/r/informaticsmatters/rdock-mini/).

### Running the image

To run the image you might want to allow to access your current directory and run as your user ID.
Try something like this:

```
$ docker run -it --rm -u $(id -u):$(id -g) -v $PWD:$PWD:Z -w $PWD informaticsmatters/rdock-mini bash
bash-4.2# rbdock
***********************************************
The rDock program is licensed under GNU-LGPLv3.0. http://rdock.sourceforge.net/
Executable:	rbdock ($Id: //depot/dev/client3/rdock/2013.1/src/exe/rbdock.cxx#4 $)
Library:	libRbt.so/2013.1/901 2013/11/27
RBT_ROOT:	/rDock_2013.1
RBT_HOME:	/root
Current dir:	/
Date:		Sun Jun 17 13:08:51 2018
***********************************************

Usage:
rbdock -i <sdFile> -o <outputRoot> -r <recepPrmFile> -p <protoPrmFile> [-n <nRuns>] [-ap] [-an] [-allH]
       [-t <targetScore|targetFilterFile>] [-c] [-T <traceLevel>] [-s <rndSeed>]

Options:	-i <sdFile> - input ligand SD file
		-o <outputRoot> - root name for output file(s)
		-r <recepPrmFile> - receptor parameter file 
		-p <protoPrmFile> - docking protocol parameter file
		-n <nRuns> - number of runs/ligand (default=1)
		-ap - protonate all neutral amines, guanidines, imidazoles (default=disabled)
		-an - deprotonate all carboxylic, sulphur and phosphorous acid groups (default=disabled)
		-allH - read all hydrogens present (default=polar hydrogens only)
		-t - score threshold OR filter file name
		-c - continue if score threshold is met (use with -t <targetScore>, default=terminate ligand)
		-T <traceLevel> - controls output level for debugging (0 = minimal, >0 = more verbose)
		-s <rndSeed> - random number seed (default=from sys clock)
bash-4.2# 
```

By default the container runs as the root user but you can (and should) run the container as a non-priviledged user.
Any user ID can be used, including a randomly assigned ID. 

