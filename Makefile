# Raspberry Pi Zero 2 W (as/ld nativos)

ASFLAGS = -g -I.

all: at

at: main.o processamento.o conversao.o
	ld -o $@ $^

main.o: main.s macros.inc
	as $(ASFLAGS) -o $@ $<

processamento.o: processamento.s
	as $(ASFLAGS) -o $@ $<

conversao.o: conversao.s
	as $(ASFLAGS) -o $@ $<

clean:
	rm -f *.o at processamento

run: at
	./at
