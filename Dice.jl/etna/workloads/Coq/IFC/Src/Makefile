.PHONY: compile tests clean

compile: Makefile.coq
	$(MAKE) -f Makefile.coq

Makefile.coq: _CoqProject
	coq_makefile -f _CoqProject -o Makefile.coq

tests:
	coqc -R . IFC Driver.v

clean:
         # This might not work on macs, but then not my problem
	find . -regex ".*\.vo\|.*\.d\|.*\.glob\|.*\.o\|.*\.cmi\|.*\.cmx\|.*\.cmxs\|.*\.cmo\|.*\.bak\|.*~\|.*.aux" -type f -delete
	rm -f Makefile.coq
