#!/bin/bash

# Install devtools
R -e "install.packages('devtools', dependencies = TRUE, repos = 'https://cloud.r-project.org/')"

# Get all dependencies except mineMS2
dependencies=$(grep 'requirement.*type="package.*>' mineMS2_config.xml | grep -vi mineMS2 | sed 's!^.*>r-\([^<>]*\)</.*$!\1!')

# Install dependencies
for dep in $dependencies ; do

	# Get version
	version=$(grep "requirement.*type=\"package.*>r-$dep.*R_VERSION=" mineMS2_config.xml | sed 's/^.*R_VERSION="\([^"]*\)".*$/\1/')
	if [[ -z $version ]] ; then
		version=$(grep "requirement.*type=\"package.*>r-$dep" mineMS2_config.xml | sed 's/^.*version="\([^"]*\)".*$/\1/')
	fi

	# Install package
	R -e "devtools::install_version('$dep', version = '$version', repos = 'https://cloud.r-project.org/')"
done

# Install right version of mineMS2
version=$(grep r-minems2 mineMS2_config.xml | sed 's/^.*version="\([^"]*\)".*$/\1/')
R -e "devtools::install_github('adelabriere/mineMS2', ref = 'v$version')"

