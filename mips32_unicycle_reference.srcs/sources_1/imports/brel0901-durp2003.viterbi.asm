.data 0x10010000
	N : .word 4
	L : .word 12
	Metriques : .word 4,3,3,2 ,2,5,3,2 ,2,1,5,4 ,2,5,3,2

.text 0x400000

main :

addi $sp,$sp,-32 # va permettre de stocker les si et so

la $a0,Metriques
addi $a1,$sp,4
addi $a2,$sp,20

jal CalculSurvivants


addi $t0,$sp,20 # mettre breakpoint pour aller voir les valeurs de so
addi $sp,$sp,32
addi $v0,$zero,10
syscall


CalculSurvivants :

#a0 -> metrique
#a1 -> si
#a2 -> so



# copy en memoire de $ra
addi $sp,$sp,-20
sw $ra,4($sp)

#copie en mem de metrique
sw $a0,8($sp)
#copie en mem de si
sw $a1,12($sp)
#copie en mem de so
sw $a2,16($sp)

sw $zero,20($sp) # i dans sp[20]


boucle_calcul :


addi $t0,$sp,20
lw $t0,($t0)

sll $t0,$t0,2 # i en multiple de 4
lw $t1,16($sp)
add $t1,$t1,$t0
addi $t2, $zero,250
sw $t2,0($t1)

#met [i*N]
sll $t0,$t0,2
lw $t1,8($sp)
add $a0,$t1,$t0
srl $t0,$t0,2

lw $a1,12($sp)

lw $t1,16($sp)
add $a2,$t1,$t0
	
jal acs

srl $t0,$t0,2 # i en  multiple de 1

la $t1,N
lw $t1,($t1)
addi $t0,$sp,20
lw $t0,($t0)
addi $t0,$t0,1
sw $t0,20($sp)
blt $t0,$t1,boucle_calcul

lw $ra,4($sp)
addi $sp,$sp,20
jr $ra

acs :
#a0 -> met
#a1 -> sinput
#a2 -> soutput

add $t0,$zero,$zero # t0 est j


boucle_acs :

sll $t0,$t0,2

add $t1,$a0,$t0
lw $t1,($t1)
add $t2,$a1,$t0
lw $t2,($t2)
add $t3,$t2,$t1

lw $t4,($a2)
slt $t5,$t3,$t4 # t5 = 1 si temp < soutput 

beqz $t5,endif # if t5 =0 skip to endif

add $t4,$zero,$t3 # else


endif : 

sw $t4,($a2)

srl $t0,$t0,2


addi $t0,$t0,1
la $t1,N
lw $t1,($t1)
blt $t0,$t1,boucle_acs


jr $ra