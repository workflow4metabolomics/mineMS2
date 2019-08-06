all:

install_deps:
	R -e 'remotes::install_github("https://github.com/adelabriere/mineMS2", ref="v0.9.2")'

test:
	Rscript "mineMS2_wrapper.R" spectra_mgf "test-data/ex_mgf.mgf" network_graphml "test-data/ex_gnps_network.graphml" thresholdVn "" annotation_graphml "test_output.graphml" figure_pdf "test_output.pdf" information_txt "test_output.txt"
	diff "test_output.graphml" "test-data/ex_annotated_gnps_network.graphml"

clean:

.PHONY: all clean test install_deps
