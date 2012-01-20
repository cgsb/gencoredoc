.PHONY: doc install uninstall clean fresh

all: customdoc

M4_HTML=m4 -P _build/include.m4
OCAMLDOCHTML=ocamlfind ocamldoc -html -colorize-code -charset utf8

_build/include.m4: _build/
	echo 'm4_changequote(<@,@>)' > $@
	echo "m4_changecom(\`@@')" >> $@
	echo 'm4_define(hitscore_doc_path,../../../hitscore/_doc)' >> $@
	echo 'm4_define(sequme_doc_path,../../../sequme/sequmedoc.docdir)' >> $@

COMMON_DEPS= _build/include.m4 _build/

_build/%.pp: src/%.txt $(COMMON_DEPS)
	$(M4_HTML) $< > $@

HTML_FILES= _build/doc/ocaml_links.html

_build/doc/index.html:  _build/intro.pp $(HTML_FILES)
	$(OCAMLDOCHTML) -d _build/doc/ -intro _build/intro.pp

_build/doc/%.html: _build/%.pp $(COMMON_DEPS) 
	$(OCAMLDOCHTML) -d _build/doc/ -intro $< -o $*

_build/:
	mkdir -p _build/doc/

customdoc: _build/doc/index.html

clean:
	rm -fr _build


# clean everything and uninstall
fresh: clean uninstall


