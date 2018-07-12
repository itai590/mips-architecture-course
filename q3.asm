# Computer Architecture  q3.s
#	 
# Input: array of 10 bytes that represent sign numbers  
#.
# Output: 1)the sum of the 10 numbers (to the screen)
#	2)copy the diffrence of eace pair in array into array1
#	
#
## for example 
# for the array: 23,-2,45,67,89,12,-100,0,120,6
#  the sum is 260 
#  and array1: 25,-47,-22,-22, 77, 112,-100,-120,114
# in mem you sould get
#  

################# Data segment #####################
.data
array: 	.byte   23,-2,45,67,89,12,-100,0,120,6
array1:	.space  9
			
msg1:   .asciiz "\n\n The sum of the numbers in the array is :"

# 
#
################# Code segment #####################
.text
.globl main
main:	# main program entry

#answer
	li  $s0,0 #pointer
	li  $s2,0 #pointer9
	#li $a0,0
	li $s3,0
loop:
	lb $t0,array($s0)
	add $s3,$s3,$t0
	
	lb $t1,array+1($s0)
		
	mul $t1,$t1,-1
	add $a0,$t0,$t1
	bge $s2,9,skip2array
	sb $a0,array1($s2)
	li $v0,1
	syscall
	
	li $a0,','
	li $v0,11
	syscall
	
skip2array:
	addi $s2,$s2,1
	addi $s0,$s0,1
	bne $s0,10,loop
	
	 # print input msg syscall 4
	la $a0,msg1	# The sum of the numbers in the array is :
	li $v0,4		# system call to print
	syscall		# out a string 
	
	move $a0,$s3
	li $v0,1
	syscall

# end of program
exit:	
	li $v0,10
	syscall