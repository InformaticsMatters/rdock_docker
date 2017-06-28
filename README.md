# Docker builds for rDock docking program

For details about rDock look [here](http://rdock.sourceforge.net/)

Contents:

* Dockerfile is a build for rdock. Find image on Dockerhub at [informaticsmatters/rdock](https://hub.docker.com/r/informaticsmatters/rdock).
* nextflow/Dockerfile also contains [Nextflow](http://nextflow.io) which is useful for running more complex pipelines. Find image on Dockerhub at [informaticsmatters/rdock_nextflow](https://hub.docker.com/r/informaticsmatters/rdock_nextflow).

Note: the rDock source code is modified slightly to remove the check that the ligand structures are 3D structures. 
The way that rDock does this check is very picky and often real 3D structures fail this check.
A better solution is needed for this. See [this commit](https://github.com/InformaticsMatters/rdock_docker/commit/c07a70f4e4b7113203aa7ceceb177205da59977b) for the changes.

