CONDA_PREFIX=$(HOME)/.plncnd

all:

install_deps:
	R -e 'remotes::install_github("https://github.com/adelabriere/mineMS2", ref="v0.9.2")'

test:
	Rscript "mineMS2_wrapper.R" spectra_mgf "test-data/ex_mgf.mgf" network_graphml "test-data/ex_gnps_network.graphml" thresholdVn "" annotation_graphml "test_output.graphml" figure_pdf "test_output.pdf" information_txt "test_output.txt"
#	diff "test_output.graphml" "test-data/ex_annotated_gnps_network.graphml"
#	TODO Not possible to check output. Lines "<data key="v_id">P83</data>" are changed on each run. The P??? id is changed. Find a way to have it fixed.

planemo-venv/bin/planemo: planemo-venv
	. planemo-venv/bin/activate && pip install "pip>=7"
	. planemo-venv/bin/activate && pip install planemo

planemo-venv:
	virtualenv planemo-venv

planemolint: planemo-venv/bin/planemo
	. planemo-venv/bin/activate && planemo lint --no_xsd

planemotest: R_LIBS_USER=
planemotest: planemo-venv/bin/planemo
	. planemo-venv/bin/activate && planemo test --conda_dependency_resolution --conda_prefix "$(CONDA_PREFIX)" --galaxy_branch release_19.05

planemo-testtoolshed-diff: dist/minems2/ planemo-venv/bin/planemo
	. planemo-venv/bin/activate && cd $< && planemo shed_diff --shed_target testtoolshed

planemo-testtoolshed-update: dist/minems2/ planemo-venv/bin/planemo
	. planemo-venv/bin/activate && cd $< && planemo shed_update --check_diff --shed_target testtoolshed

planemo-toolshed-diff: dist/minems2/ planemo-venv/bin/planemo
	. planemo-venv/bin/activate && cd $< && planemo shed_diff --shed_target toolshed

planemo-toolshed-update: dist/minems2/ planemo-venv/bin/planemo
	. planemo-venv/bin/activate && cd $< && planemo shed_update --check_diff --shed_target toolshed

dist/minems2/:
	mkdir -p $@
	cp -r README.md mineMS2_wrapper.R mineMS2_config.xml test-data $@

clean:
	$(RM) -r dist
	$(RM) -r planemo-venv
	$(RM) -r planemotest.log
	$(RM) -r $(HOME)/.planemo
	$(RM) -r $(CONDA_PREFIX)
	$(RM) tool_test_output.*

.PHONY: all clean test install_deps
