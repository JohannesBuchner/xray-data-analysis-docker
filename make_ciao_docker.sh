set -euxo pipefail

CIAO_VERSION=$(wget -q -O - 'http://cxc.cfa.harvard.edu/ciao/download/' |grep '<title'|sed 's,.*CIAO \([0-9.]*\)</title>,\1,g')
CIAO_VERSION_NODOT=${CIAO_VERSION/\./}
mkdir -p ciao-${CIAO_VERSION}

{
echo FROM ubuntu:latest
echo 
echo MAINTAINER JohannesBuchner
echo 
echo 'LABEL CIAO_version="'${CIAO_VERSION}'" description="CIAO software http://cxc.cfa.harvard.edu/ciao/download/"'

cat << EOF
# Install CIAO prerequisites

RUN apt-get update && \
    apt-get install -y \
	gcc \
	gfortran \
	g++ \
	libncurses5-dev \
	libreadline6-dev \
	ncurses-dev \
	python3-dev \
	wget \
	xorg-dev \
	libgl1-mesa-glx \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/

RUN mkdir -p ciao-download ciao
WORKDIR /opt/ciao-download/
EOF

echo "RUN wget http://cxc.cfa.harvard.edu/cgi-gen/ciao/ciao${CIAO_VERSION_NODOT}_install.cgi?standard=true -O ciao-install"

cat << EOF
RUN { \
	echo; \
	echo /opt/ciao/; \
	echo n; \
	yes ""; \
	} | bash ./ciao-install

#alias ciao "source /opt/ciao/bin/ciao.csh"
#CMD source /opt/ciao/bin/ciao.csh
EOF
} > ciao-${CIAO_VERSION}/Dockerfile

docker build ciao-${CIAO_VERSION} 


