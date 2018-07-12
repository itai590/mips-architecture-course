# Computer Architecture
#Question 1:        	
# Input: 1)in buf (in the data segment) string of exactly 10 chars  
#        
# 
# Output:     1)swap each pair chars in the string
#	    (if the pair identical change the second to '*' )
#		2)print buf in reverse
##
## 
# Example
# buf=		 "aabb456788"
#
#After swap buf= "a*b*54768*
#
# in reverse  = "*86745*b*a"

################# Data segment #####################
.data
buf:    .ascii "aabb456788"	

################# Code segment #####################
.text
.globl main
main:	# main program entry
li $t1,'*'
#answer
li $s0,0
swap:
	lb $s1,buf($s0)
	lb $s2,buf+1($s0)
	bne $s1,$s2,not_equal
	sb $t1,buf+1($s0)
	
	j continue
not_equal:
	sb $s2,buf($s0)
	sb $s1,buf+1($s0)
	
continue:
	addi $s0, $s0,2
	bne $s0,10,swap
	
	la $a0,buf
	li $v0,4
	syscall
	
	li $a0,'\n'
	li $v0,11
	syscall
	
	li $s0,10
reverse:
	addi $s0, $s0,-1
	lb $a0,buf($s0)
	syscall
	bne $s0,$0,reverse
		
# end of program
exit:	
	li $v0,10
	syscall
