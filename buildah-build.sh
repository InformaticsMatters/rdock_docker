#!/bin/bash

set -x

# build a centos image
newcontainer=$(buildah from tdudgeon/centos-base:latest)
scratchmnt=$(buildah mount $newcontainer)
echo "Creating container $newcontainer using $scratchmnt"

# install the packages
yum -y install popt perl\
  --installroot $scratchmnt --releasever 7\
  --setopt install_weak_deps=false --setopt=tsflags=nodocs\
  --setopt=override_install_langs=en_US.utf8 &&\
  yum -y clean all --installroot $scratchmnt --releasever 7 &&\
  rm -rf $scratchmnt/var/cache/yum

# th efinal location of rdoc in the target container
RDOCK_LOC=/rDock_2013.1

# build rdock

cd $RDOCK_SRC/build/
make linux-g++-64

mkdir $scratchmnt/$RDOCK_LOC
cp -r $RDOCK_SRC/lib $RDOCK_SRC/bin $scratchmnt/$RDOCK_LOC

# set some config info
buildah config\
  --label name=rdock\
  --env RBT_ROOT=$RDOCK_LOC\
  --env LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$RDOCK_LOC/lib\
  --env PATH=$PATH:$RDOCK_LOC/bin\
  $newcontainer

# commit the image
buildah unmount $newcontainer
buildah commit $newcontainer informaticsmatters/rdock-mini
