# Computer Architecture
#Question 2:        	
# 
## 
# Example 

#output:  0 ( palindrome ) as a result  buf is cleared from mem

################# Data segment #####################
.data
buf:    .ascii "helloworlddlrowolleh"	

################# Code segment #####################
.text
.globl main
main:	# main program entry

#answer
	li $s0,0 #start pointer
	li $s1,19 #end pointer
	li $a0,0 #counter
	
checkPalindrom:	
	lb $t0,buf($s0)
	lb $t1,buf($s1)
	beq $t0,$t1,equal
	addi $a0,$a0,1
equal:
	addi $s0,$s0,1
	addi $s1,$s1,-1
	bgt $s1,$s0,checkPalindrom
	
	li $v0,1
	syscall
	bnez $a0, exit
	
	li $a0,'\n'
	li $v0,11
	syscall
	

	#reset
		li $s0,0 #start pointer
setZero:	sb $0,buf($s0)
		addi $s0,$s0,1
		bne $s0,20,setZero


# end of program
exit:	
	li $v0,10
	syscall
