R	:= R 
RSCRIPT	:= Rscript
DELETE	:= rm -fR
PKG := parallelMap

.SILENT:
.PHONEY: clean roxygenize package windows install test check

usage:
	echo "Available targets:"
	echo ""
	echo " clean         - clean everything up"
	echo " roxygenize    - roxygenize skel/ into pkg/"
	echo " package       - build source package"
	echo " install       - install the package"
	echo " test          - run tests"
	echo " check         - run R CMD check on the package"
	echo " check-rev-dep - run reverse dependency checks"
	echo " html          - generate static html doc pages"

clean:
	echo "Cleaning up ..."
	${DELETE} parallelMap.Rcheck
	${DELETE} .RData .Rhistory

roxygenize: clean
	echo "Roxygenizing package ..."
	${RSCRIPT} ./tools/roxygenize
	echo "Setting version ..."
	${RSCRIPT} ./tools/set-version
  
package: roxygenize
	echo "Building package file ..."
	${R} CMD build ${PKG}
 
install: roxygenize
	echo "Installing package ..."
	${R} CMD INSTALL ${PKG}

test: install
	echo "Testing package ..."
	${RSCRIPT} ./test_all.R

check: roxygenize
	echo "Running R CMD check ..."
	${R} CMD check ${PKG}

check-rev-dep: install
	echo "Running reverse dependency checks ..."
	${RSCRIPT} ./tools/check-rev-dep

html: install
	echo "Generating html docs..."
	${DELETE} html
	mkdir html
	${RSCRIPT} ./tools/generate-html-docs
 
