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
	mkdir -p _build/doc/img/
	echo 'm4_changequote(<@,@>)' > $@
	echo "m4_changecom(\`@@')" >> $@
	echo 'm4_define(__hitscore_doc_path,./hitscore)' >> $@
	echo 'm4_define(__sequme_doc_path,./sequme)' >> $@
	echo 'm4_define(__biocaml_doc_path,./biocaml)' >> $@

COMMON_DEPS= _build/include.m4 

_build/%.pp: src/%.txt $(COMMON_DEPS)
	$(M4_HTML) $< > $@

_build/%.ppml: src/%.html $(COMMON_DEPS)
	$(M4_HTML) $< > $@

IMG_SOURCES = $(basename $(shell find src/img/ -name "*.svg" -exec basename {} \;))
TXT_SOURCES = $(basename $(shell find src/ -name "*.txt" -exec basename {} \;))
HTM_SOURCES = $(basename $(shell find src/ -name "*.html" -exec basename {} \;))
SOURCES= $(TXT_SOURCES) $(HTM_SOURCES)

PNG_FILES= $(addprefix _build/doc/img/, $(addsuffix .png, $(IMG_SOURCES)))
HTML_OF_HTM_FILES= $(addprefix _build/doc/, $(addsuffix .html, $(HTM_SOURCES)))
HTML_OF_TXT_FILES= $(addprefix _build/doc/, $(addsuffix .html, $(TXT_SOURCES)))
HTML_FILES = $(HTML_OF_TXT_FILES) $(HTML_OF_HTM_FILES)

_build/doc/gdcstyle.css: src/style.css
	$(M4_HTML) $< > $@

_build/doc/hitscore/:
	mkdir -p $@
	cp -r $(HITSCORE_DOC)/* $@
	$(M4_HTML)  -D __library_doc=hitscore src/style.css > $@/lib/style.css

_build/doc/biocaml/:
	mkdir -p $@
	cp -r $(BIOCAML_DOC)/* $@
	$(M4_HTML) -D __library_doc=biocaml src/style.css > $@/style.css

_build/doc/sequme/:
	mkdir -p $@
	cp -r $(SEQUME_DOC)/* $@
	$(M4_HTML) -D __library_doc=sequme  src/style.css > $@/style.css

$(HTML_OF_TXT_FILES):_build/doc/%.html: _build/%.pp $(COMMON_DEPS) 
	$(OCAMLDOCHTML) -d _build/doc/ -t "GCD:$*" -css-style gdcstyle.css -intro $< -o $*

$(HTML_OF_HTM_FILES):_build/doc/%.html: src/%.html templates/page_template.tmpl
	awk -vf2="$$(cat $<)" '/GCD_HTML_TEMPLATE_BODY/{print f2;print;next}1' \
		templates/page_template.tmpl > $@

_build/doc/img/%.png: src/img/%.svg
	inkscape -z -e $@ $<

slides_SM01: src/slides_SM01.html templates/slides/index.html
	rm -fr _build/slides/ && cp -r templates/slides/ _build/doc/
	awk -vf2="$$(cat $<)" '/GCD_HTML_TEMPLATE_BODY/{print f2;print;next}1' \
		templates/slides/index.html > _build/doc/slides/SM01.html

slides: slides_SM01

customdoc: $(HTML_FILES) $(PNG_FILES) _build/doc/gdcstyle.css slides \
  _build/doc/hitscore/ _build/doc/sequme/ _build/doc/biocaml/

clean:
	rm -fr _build


# clean everything and uninstall
fresh: clean uninstall


