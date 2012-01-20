.PHONY: doc install uninstall clean fresh customdoc

HITSCORE_DOC = ../hitscore/_doc
BIOCAML_DOC = ../biocaml/doclib.docdir
SEQUME_DOC = ../sequme/sequmedoc.docdir

setup_data_file := $(wildcard setup.data)
ifeq ($(strip $(setup_data_file)),)

else
include setup.data
endif

all: customdoc

M4_HTML=m4 -P _build/include.m4
OCAMLDOCHTML=ocamlfind ocamldoc -html -colorize-code -charset utf8 -index-only

_build/include.m4:
	mkdir -p _build/doc/
	echo 'm4_changequote(<@,@>)' > $@
	echo "m4_changecom(\`@@')" >> $@
	echo 'm4_define(__hitscore_doc_path,./hitscore)' >> $@
	echo 'm4_define(__sequme_doc_path,./sequme)' >> $@
	echo 'm4_define(__biocaml_doc_path,./biocaml)' >> $@

COMMON_DEPS= _build/include.m4

_build/%.pp: src/%.txt $(COMMON_DEPS)
	$(M4_HTML) $< > $@

HTML_FILES= _build/doc/index.html  _build/doc/ocaml_links.html _build/doc/hitscore_migration.html

_build/doc/gdcstyle.css: src/style.css
	$(M4_HTML) $< > $@

_build/doc/hitscore/:
	mkdir -p $@
	cp -r $(HITSCORE_DOC)/* $@

_build/doc/biocaml/:
	mkdir -p $@
	cp -r $(BIOCAML_DOC)/* $@

_build/doc/sequme/:
	mkdir -p $@
	cp -r $(SEQUME_DOC)/* $@

_build/doc/%.html: _build/%.pp $(COMMON_DEPS) 
	$(OCAMLDOCHTML) -d _build/doc/ -t "GCD:$*" -css-style gdcstyle.css -intro $< -o $*


customdoc: $(HTML_FILES) \
  _build/doc/hitscore/ _build/doc/sequme/ _build/doc/biocaml/ \
  _build/doc/gdcstyle.css

clean:
	rm -fr _build


# clean everything and uninstall
fresh: clean uninstall


