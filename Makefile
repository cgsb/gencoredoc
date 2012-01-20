.PHONY: doc install uninstall clean fresh

all: customdoc

M4_HTML=m4 -P _build/include.m4
OCAMLDOCHTML=ocamlfind ocamldoc -html -colorize-code

_build/include.m4: _build/
	echo 'm4_changequote(<@,@>)' > $@
	echo "m4_changecom(\`@@')" >> $@
	echo 'm4_define(hitscore_doc_path,../../../hitscore/_doc)' >> $@
	echo 'm4_define(sequme_doc_path,../../../sequme/sequmedoc.docdir)' >> $@

COMMON_DEPS= _build/include.m4 _build/

_build/intro.pp: src/intro.txt
	$(M4_HTML) $< > $@

_build/doc/index.html: $(COMMON_DEPS) _build/intro.pp
	$(OCAMLDOCHTML) -d _build/doc/ -intro _build/intro.pp

_build/:
	mkdir -p _build/doc/

customdoc: _build/doc/index.html

clean:
	rm -fr _build


# clean everything and uninstall
fresh: clean uninstall


