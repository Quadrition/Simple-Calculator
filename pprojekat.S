# Petar Cerovic sw26-2017

.section .data
unos_poruka:
	.ascii "Unesite izraz: "
unos_poruka_len = . - unos_poruka
zbir_poruka:
	.ascii "Rezultat: "
zbir_poruka_len = . - zbir_poruka
gr_prekoracenje:
	.ascii "Prekoracenje!"
gr_prekoracenje_len = . - gr_prekoracenje
gr_cifra:
	.ascii "Pogresna cifra!"
gr_cifra_len = . - gr_cifra
gr_prazan:
	.ascii "Prazan izraz!"
gr_prazan_len = . - gr_cifra
uneti_izraz_max = 101
uneti_izraz:
	.fill uneti_izraz_max, 1, 0
baza:
	.long 16
niz:
	.fill 50, 4, 0
niz_len:
	.long 0
niz_operacija:
	.fill 50, 4, 0
niz_operacija_len:
	.long 0
negativ:
	.long 1
minus_jedan:
	.long -1
rezultat:
	.long 0
rezultat_string:
	.fill 10, 1, 0

.section .text
.globl main
						#ispis gresaka
pogresan_karakter:
	movl $4, %eax
	movl $1, %ebx
	leal gr_cifra, %ecx
	movl $gr_cifra_len, %edx
	int $0x80
	jmp kraj_greska

prazan_izraz:
	movl $4, %eax
	movl $1, %ebx
	leal gr_prazan, %ecx
	movl $gr_prazan_len, %edx
	int $0x80
	jmp kraj_greska

prekoracenje:
	movl $4, %eax
	movl $1, %ebx
	leal gr_prekoracenje, %ecx
	movl $gr_prekoracenje_len, %edx
	int $0x80
	jmp kraj_greska
						#konverzija izraza u nizove
konverzija_izraza:
	pushl %ebp
	movl %esp, %ebp
	movl 8(%ebp), %ebx
	movl $1, %esi
	xorl %eax, %eax
	xorl %edx, %edx
     xorl %edi, %edi

karakter:
	cmpb $0, (%ebx)
	je zavrsi_proveru
	cmpb $10, (%ebx)
	je ukloni_novi_red
	cmpb $32, (%ebx)
	je sledeci_karakter
	cmpb $48, (%ebx)
	jb znak
	jae broj_ili_slovo

ukloni_novi_red:
	movb $0, (%ebx)
	jmp karakter

znak:
	cmpb $45, (%ebx)
	je minus
     cmpl $0, %edi
     ja pogresan_karakter
     incl %edi
     cmpl $0, niz_len
     je pogresan_karakter
	cmpb $42, (%ebx)
	je dodaj_puta
	cmpb $43, (%ebx)
	je dodaj_plus
	cmpb $47, (%ebx)
	je dodaj_podeljeno
	jmp pogresan_karakter

minus:
	cmpb $48, 1(%ebx)
	jae minus_ispred
     cmpl $1, %edi
     ja pogresan_karakter
     incl %edi
     cmpl $0, niz_len
     je pogresan_karakter
	jmp dodaj_minus

minus_ispred:
	movl $-1, %esi
	jmp sledeci_broj_slovo

dodaj_plus:
     movl niz_operacija_len, %ecx
     movl $43, niz_operacija(, %ecx, 4)
     incl niz_operacija_len
	jmp sledeci_karakter

dodaj_minus:
     movl niz_operacija_len, %ecx
     movl $45, niz_operacija(, %ecx, 4)
     incl niz_operacija_len
	jmp sledeci_karakter

dodaj_puta:
     movl niz_operacija_len, %ecx
     movl $42, niz_operacija(, %ecx, 4)
     incl niz_operacija_len
	jmp sledeci_karakter

dodaj_podeljeno:
     movl niz_operacija_len, %ecx
     movl $47, niz_operacija(, %ecx, 4)
     incl niz_operacija_len
	jmp sledeci_karakter

broj_ili_slovo:
     cmpl $0, %edi
     je dodaj_prazan_plus
	cmpb $57, (%ebx)
	jbe broj
	cmpb $70, (%ebx)
	jbe veliko_slovo
	cmpb $102, (%ebx)
	jbe malo_slovo
	jmp pogresan_karakter

sledeci_broj_slovo:
	incb %bl
	jmp broj_ili_slovo

sledeci_karakter:
	incb %bl
	jmp karakter

dodaj_prazan_plus:
     cmpl $0, niz_len
     je pocetak_se_ne_racuna
     movl niz_operacija_len, %ecx
     movl $43, niz_operacija(, %ecx, 4)
     incl niz_operacija_len
     incl %edi
	jmp broj_ili_slovo

pocetak_se_ne_racuna:
     incl %edi
     jmp broj_ili_slovo

broj:
     xorl %ecx, %ecx
	movb (%ebx), %cl
	subb $48, %cl
	jmp proveri_kraj_broja

veliko_slovo:
	cmpb $65, (%ebx)
	jb pogresan_karakter
     xorl %ecx, %ecx
	movb (%ebx), %cl
	subb $55, %cl
	jmp proveri_kraj_broja

malo_slovo:
	cmpb $97, (%ebx)
	jb pogresan_karakter
     xorl %ecx, %ecx
	movb (%ebx), %cl
	subb $87, %cl
	jmp proveri_kraj_broja

proveri_kraj_broja:
	mull baza
	addl %ecx, %eax
	cmpl $0, %eax
	jl prekoracenje
	cmpl $0, %edx
	jne prekoracenje
	cmpb $48, 1(%ebx)
	jb zavrsi_broj
	jmp sledeci_broj_slovo

zavrsi_broj:
	xorl %edi, %edi
	mull %esi
	movl $1, %esi
     movl niz_len, %ecx
     movl %eax, niz(, %ecx, 4)
     incl niz_len
	xorl %eax, %eax
	xorl %ecx, %ecx
	jmp sledeci_karakter

zavrsi_proveru:
     cmpl $0, %edi
     ja pogresan_karakter
	cmpl $0, niz_len
	je prazan_izraz
	movl %ebp, %esp
	popl %ebp
	ret
					#Pronalazenje operacija puta i podeljeno
puta_podeljeno:
     pushl %ebp
     movl %esp, %ebp
     xorl %ebx, %ebx
	xorl %edx, %edx

pronadji_operaciju_puta_podeljeno:
	cmpl %ebx, niz_operacija_len
	jbe zavrsi_puta_podeljeno
     cmpl $42, niz_operacija(, %ebx, 4)
     je pomnozi
     cmpl $47, niz_operacija(, %ebx, 4)
     je podeli
     incl %ebx
     jmp pronadji_operaciju_puta_podeljeno

pomnozi:
     movl %ebx, %ecx
     incl %ecx
	movl $1, negativ
	call odredi_znak
	movl niz(, %ebx, 4), %eax
     mull niz(, %ecx, 4)
     jo prekoracenje
	mull negativ
	xorl %edx, %edx
     movl %eax, niz(, %ebx, 4)
     call pomeranje_nizova
	jmp pronadji_operaciju_puta_podeljeno

podeli:
	movl %ebx, %ecx
	incl %ecx
	movl $1, negativ
	call odredi_znak
	movl niz(, %ebx, 4), %eax
	movl niz(, %ecx, 4), %esi
	cmpl $0, niz(, %ecx, 4)
	je prekoracenje
     divl niz(, %ecx, 4)
     jo prekoracenje
	mull negativ
	xorl %edx, %edx
     movl %eax, niz(, %ebx, 4)
     call pomeranje_nizova
	jmp pronadji_operaciju_puta_podeljeno

zavrsi_puta_podeljeno:
     movl %ebp, %esp
     popl %ebp
     ret
					#Odredjivanje znaka
odredi_znak:
	pushl %ebp
	movl %esp, %ebp
	cmpl $0, niz(, %ebx, 4)
	jl obrni_prvi
	cmpl $0, niz(, %ecx, 4)
	jl obrni_drugi
	jmp zavrsi_obrtanje_znaka

obrni_prvi:
	movl niz(, %ebx, 4), %eax
	mull minus_jedan
	movl %eax, niz(, %ebx, 4)
	movl negativ, %eax
	mull minus_jedan
	movl %eax, negativ
	cmpl $0, niz(, %ecx, 4)
	jl obrni_drugi
	jmp zavrsi_obrtanje_znaka

obrni_drugi:
	movl niz(, %ecx, 4), %eax
	mull minus_jedan
	movl %eax, niz(, %ecx, 4)
	movl negativ, %eax
	mull minus_jedan
	movl %eax, negativ
	jmp zavrsi_obrtanje_znaka

zavrsi_obrtanje_znaka:
	movl %ebp, %esp
     popl %ebp
     ret
					#Pronalazenje operacija plus i minus
plus_minus:
     pushl %ebp
     movl %esp, %ebp
     xorl %ebx, %ebx

pronadji_operaciju_plus_minus:
	cmpl %ebx, niz_operacija_len
	jbe zavrsi_plus_minus
     cmpl $43, niz_operacija(, %ebx, 4)
     je saberi
     cmpl $45, niz_operacija(, %ebx, 4)
     je oduzmi
     incl %ebx
     jmp pronadji_operaciju_plus_minus

saberi:
     movl %ebx, %ecx
     movl niz(, %ecx, 4), %eax
     incl %ecx
     addl niz(, %ecx, 4), %eax
     jo prekoracenje
     movl %eax, niz(, %ebx, 4)
     call pomeranje_nizova
	jmp pronadji_operaciju_plus_minus

oduzmi:
     movl %ebx, %ecx
     movl niz(, %ecx, 4), %eax
     incl %ecx
     subl niz(, %ecx, 4), %eax
     jo prekoracenje
     movl %eax, niz(, %ebx, 4)
     call pomeranje_nizova
	jmp pronadji_operaciju_plus_minus

zavrsi_plus_minus:
     movl %ebp, %esp
     popl %ebp
     ret
					#Pomeranje nizova
pomeranje_nizova:
	pushl %ebp
	movl %esp, %ebp
	movl %ebx, %ecx
	incl %ecx
	incl %ecx

pomeri_niz:
     cmpl %ecx, niz_len
     jbe zavrsi_pomeranje_niza
     movl niz(, %ecx, 4), %eax
     decl %ecx
     movl %eax, niz(, %ecx, 4)
     incl %ecx
     incl %ecx
     jmp pomeri_niz

zavrsi_pomeranje_niza:
	movl %ebx, %ecx
	incl %ecx

pomeri_niz_operacija:
     cmpl %ecx, niz_operacija_len
     jbe zavrsi_pomeranje_nizova
     movl niz_operacija(, %ecx, 4), %eax
     decl %ecx
     movl %eax, niz_operacija(, %ecx, 4)
     incl %ecx
     incl %ecx
     jmp pomeri_niz_operacija

zavrsi_pomeranje_nizova:
	decl niz_len
	decl niz_operacija_len
	movl %ebp, %esp
	popl %ebp
	ret
						#ispis rezultata
ispisi_rezultat:
	pushl %ebp
	movl %esp, %ebp
	movl 8(%ebp), %eax
	movl 12(%ebp), %edi
	xorl %ebx, %ebx
	cmpl $0, %eax
	jl nula
	jmp hex_cifra

nula:
	mull minus_jedan
	movl $1, %ebx

hex_cifra:
	xorl %edx, %edx
	divl baza
	cmpl $9, %edx
	ja slovo
	addb $48, %dl
	movb %dl, (%edi)
	incl %edi
	andl %eax, %eax
	jnz hex_cifra
	movl 12(%ebp), %esi
	movb $0, (%edi)
	decl %edi
	cmpl $1, %ebx
	je minus_na_kraju
	jmp obrni

minus_na_kraju:
	incl %edi
	movb $45, (%edi)
	incl %edi
	movb $0, (%edi)
	decl %edi
	jmp obrni

slovo:
	addb $55, %dl
	movb %dl, (%edi)
	incl %edi
	andl %eax, %eax
	jnz hex_cifra
	movl 12(%ebp), %esi
	movb $0, (%edi)
	decl %edi
	cmpl $1, %ebx
	je minus_na_kraju
	jmp obrni

obrni:
	cmpl %edi, %esi
	jae zavrsi_ispis
	movb (%esi), %ah
	movb (%edi), %al
	movb %al, (%esi)
	movb %ah, (%edi)
	decl %edi
	incl %esi
	jmp obrni

zavrsi_ispis:
	movl $4, %eax
	movl $1, %ebx
	leal rezultat_string, %ecx
	movl $10, %edx
	int $0x80
	movl %ebp, %esp
	popl %ebp
	ret
					#Main
main:
	movl $4, %eax
	movl $1, %ebx
	leal unos_poruka, %ecx
	movl $unos_poruka_len, %edx
	int $0x80

	movl $3, %eax
	movl $0, %ebx
	leal uneti_izraz, %ecx
	movl $uneti_izraz_max, %edx
	int $0x80

	pushl $uneti_izraz
	call konverzija_izraza
	addl $4, %esp

     call puta_podeljeno
     call plus_minus

	movl $0, %eax
	movl niz(, %eax, 4), %ebx
	movl %ebx, rezultat

	movl $4, %eax
	movl $1, %ebx
	leal zbir_poruka, %ecx
	movl $zbir_poruka_len, %edx
	int $0x80

	pushl $rezultat_string
	pushl rezultat
	call ispisi_rezultat
	addl $8, %esp
kraj:
	movl $1, %eax
	movl $0, %ebx
	int $0x80

kraj_greska:
	movl $1, %eax
	movl $1, %ebx
	int $0x80
