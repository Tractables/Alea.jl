default:

install:
	python3 -m pip install -r tool/requirements.txt; \
	python3 -m pip install -e tool

uninstall:
	python3 -m pip uninstall benchtool
	rm -rf tool/benchtool.egg-info
	rm -rf tool/build
	rm -rf tool/dist
	rm -rf temp

DATA = data
FIGURES = figures

collect4.1:
	mkdir -p $(DATA)/4.1
	python3 experiments/haskell-experiments/4.1/Collect.py --data=$(DATA)/4.1

analyze4.1:
	python3 experiments/haskell-experiments/4.1/Analysis.py --data=$(DATA)/4.1 --figures=$(FIGURES)/fig1

collect4.2:
	mkdir -p $(DATA)/4.2
	python3 experiments/haskell-experiments/4.2/Collect.py --data=$(DATA)/4.2

analyze4.2:
	python3 experiments/haskell-experiments/4.2/Analysis.py --data=$(DATA)/4.2 --figures=$(FIGURES)

collect4.3:
	mkdir -p $(DATA)/4.3
	python3 experiments/haskell-experiments/4.3/Collect.py --data=$(DATA)/4.3

analyze4.3:
	python3 experiments/haskell-experiments/4.3/Analysis.py --data=$(DATA)/4.3 --original=$(DATA)/4.1

switchnew:
	git -C ../QuickChick switch etna
	make -C ../QuickChick clean
	make -C ../QuickChick install

collect5.1:
	python3 qc-checker.py use_new_qc
	python3 bounds-switch.py to_max
	mkdir -p $(DATA)/5.1
	python3 experiments/coq-experiments/5.1/Collect.py --data=$(DATA)/5.1
	python3 experiments/coq-experiments/5.1/CollectIFC.py --data=$(DATA)/5.1

analyze5.1:
	python3 experiments/coq-experiments/5.1/Analysis.py --data=$(DATA)/5.1 --figures=$(FIGURES)/fig3

# tmp:
collectnew:
	python3 qc-checker.py use_new_qc
	python3 bounds-switch.py to_max
	mkdir -p $(DATA)/new
	python3 experiments/coq-experiments/new/Collect.py --data=$(DATA)/new
# tmp:
# timeout 15 python3 experiments/coq-experiments/new/Collect.py --data=$(DATA)/new || true
# (cd workloads/Coq/STLC/ && make clean && coq_makefile -f _CoqProject -o Makefile && make)

analyzenew:
	python3 experiments/coq-experiments/new/Analysis.py --data=$(DATA)/new --figures=$(DATA)/newfigures
# python3 experiments/coq-experiments/new/Analysis.py --data=data-02-22-tb-stlc/new --figures=data-02-22-tb-stlc/newfigures

collectbstnew:
	python3 qc-checker.py use_new_qc
	python3 bounds-switch.py to_max
	mkdir -p $(DATA)/bstnew
	timeout 3 python3 experiments/coq-experiments/bstnew/Collect.py --data=$(DATA)/bstnew || true
	(cd workloads/Coq/BST/ && make clean && coq_makefile -f _CoqProject -o Makefile && make)
	python3 experiments/coq-experiments/bstnew/Collect.py --data=$(DATA)/bstnew 

analyzebstnew:
	python3 experiments/coq-experiments/bstnew/Analysis.py --data=$(DATA)/bstnew --figures=$(DATA)/bstnewfigures

collectrbtnew:
	python3 qc-checker.py use_new_qc
	python3 bounds-switch.py to_max
	mkdir -p $(DATA)/bstnew
	timeout 3 python3 experiments/coq-experiments/rbtnew/Collect.py --data=$(DATA)/rbtnew || true
	(cd workloads/Coq/RBT/ && make clean && coq_makefile -f _CoqProject -o Makefile && make)
	python3 experiments/coq-experiments/rbtnew/Collect.py --data=$(DATA)/rbtnew

analyzerbtnew:
	python3 experiments/coq-experiments/rbtnew/Analysis.py --data=$(DATA)/rbtnew --figures=$(DATA)/rbtnewfigures

collectifcnew:
	python3 qc-checker.py use_new_qc
	python3 bounds-switch.py to_max
	mkdir -p $(DATA)/bstnew
	python3 experiments/coq-experiments/ifcnew/CollectIFC.py --data=$(DATA)/ifcnew

analyzeifcnew:
	python3 experiments/coq-experiments/ifcnew/Analysis.py --data=$(DATA)/ifcnew --figures=$(FIGURES)

switchold:
	git -C ../QuickChick switch etna-experiment-5.2
	make -C ../QuickChick clean
	make -C ../QuickChick install

collect5.2:
	python3 qc-checker.py use_old_qc
	python3 bounds-switch.py to_small
	mkdir -p $(DATA)/5.2/fix-reverted
	python3 experiments/coq-experiments/5.2/Collect.py --data=$(DATA)/5.2/fix-reverted

analyze5.2:
	python3 experiments/coq-experiments/5.2/Analysis.py --data=$(DATA)/5.2/fix-reverted --original=$(DATA)/5.1 --figures=$(FIGURES)/fig5

