DC=dmd
D=$(DC) -O -release -J.
BINS=d1 d1_inline d_py1 d_bignum1 d_rust1 d_rust2

all: $(BINS)

N=3
bench:: all
	for x in $(BINS); do echo $$x; getr $N ./$$x; echo; done
	-getr $N python2 py1.py

clean::
	rm -fv $(BINS) d1_inline.d
	rm -fv *.o

d1_inline.d: d1_inline_head.d input.txt
	cat $< input.txt > $@

d1_inline: d1_inline.d
	$D -of$@ $<

%: %.d
	$D -of$@ $<
