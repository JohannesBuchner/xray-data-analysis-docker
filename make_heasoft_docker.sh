set -euxo pipefail


HEASOFT_VERSION=$1
if [[ "$HEASOFT_VERSION" == "" ]]; then
HEASOFT_VERSION=$(wget -q -O - 'https://heasarc.gsfc.nasa.gov/lheasoft/download.html' |grep '<title'|sed 's,.*(Version \([^\)]*\)).*,\1,g')
fi

mkdir -p heasoft-${HEASOFT_VERSION}
pushd heasoft-${HEASOFT_VERSION}

wget --continue -nv http://heasarc.gsfc.nasa.gov/FTP/software/lheasoft/release/heasoft-${HEASOFT_VERSION}src.tar.gz

{
echo FROM ubuntu:latest
echo 
echo MAINTAINER JohannesBuchner
echo 
echo 'LABEL HEASoft_version="'${HEASOFT_VERSION}'" description="HEASoft software https://heasarc.gsfc.nasa.gov/docs/software/lheasoft/"'

cat << EOF
# Install HEASoft prerequisites

RUN apt-get update && \
    apt-get install -y \
	gcc \
	gfortran \
	g++ \
	libncurses5-dev \
	libreadline6-dev \
	ncurses-dev \
	perl-modules \
	python3-dev \
	wget \
	xorg-dev \
	libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/

EOF

echo "COPY heasoft-${HEASOFT_VERSION}src.tar.gz /opt/"
echo "RUN tar -xzvf /opt/heasoft-${HEASOFT_VERSION}src.tar.gz"
echo "RUN ln -s /opt/heasoft-${HEASOFT_VERSION} /opt/heasoft-src"

cat << EOF

# execute install script

RUN cd /opt/heasoft-src/BUILD_DIR/ && PYTHON=/usr/bin/python3 ./configure --prefix=/opt/heasoft/ 2>&1 | tee config.out && make 2>&1 | tee build.log && make install 2>&1 | tee install.log && rm -rf /opt/heasoft-*/

RUN ls /opt/

# Simple test
# In most other cases, CMD should be given an interactive shell
CMD source /opt/heasoft/x86_64-pc-linux-gnu-libc*/headas-init.sh; fhelp xspec
EOF
} > Dockerfile

docker build -t heasoft-${HEASOFT_VERSION} .


