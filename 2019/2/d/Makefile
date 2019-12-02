DC=dmd
D=$(DC) -O -release
BINS=d1

all: $(BINS)

N=3
bench:: all
	for x in $(BINS); do echo $$x; getr $N ./$$x; echo; done

clean::
	rm -fv $(BINS)
	rm -fv *.o

%: %.d
	$D -of$@ $<
