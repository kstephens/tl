
all : t t.c

t : t.c
t.c : t.scm
	csi -s scheme-to-c.scm < t.scm | tee $@

clean:
	rm -f t t.c
