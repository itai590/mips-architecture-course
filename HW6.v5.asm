# Filename:HW6
# Author:	Itai Cohen
# Version:5
################# Data segment #####################
.data
JumpTable: .word L0, L1, L2, L3, L4, L5, L6, L7, L8
array:  	.word 0:30	# array of 30 words
#array:  	.word 1,2,3,4,5,12,-15,-99,300,400,700,6,-5,-4
tempArray: .word 0:30	# array of 30 words
NUM:  .word 0	# Number of numbers in array
msg1: .asciiz "\n\nThe options are:\n 1. Enter a number (base 10)\n 2. Replace a number (base 10)\n 3. DEL a number (base 10)\n 4. Find a number in the array (base 10)\n 5. Find average (base 2-10)\n 6. Find Max (base 2-10)\n 7. Print the array elements (base 2-10)\n 8. Print sort array (base 2-10)\n 9. END\nEnter your selection from the options:"
msgArrIsFull: .asciiz "\n The array is full !"
msgAddNumber: .asciiz "\n What number to add?"
msgTheNumber: .asciiz "\n The number "
msgNumberAdded: .asciiz " was added successfully (in index: "
msgNumberNotFoundRep: .asciiz " couldn't be found in the array :: Replacement terminated !"
msgNumberNotFoundDel: .asciiz " couldn't be found in the array :: Delete terminated !"
msgNumberNotFound: .asciiz " couldn't be found in the array :: Find terminated !"
msgNumberExist: .asciiz " is already exist (in index: "
msgNumberExistR: .asciiz " is exist (in index: "
msgAddNumberAbort: .asciiz ") :: add_number terminated !"
msgInIndexEnd: .asciiz ")"
msgInIndexEndS: .asciiz "): ["
msgArrayIsEmpty: .asciiz "\n The array is empty :: method terminated !"
msgNumber2Replace: .asciiz "\n What number to replace?"
msgNumber2Del: .asciiz "\n What number to delete?"
msgWithWhatNumber: .asciiz ") --> Replace it with what number?"
msgReplacementAbort: .asciiz ") :: Replacement terminated !"
msgReplacementSucceeded: .asciiz "\n Replacement succeeded !" 
msgDeleteSucceeded: .asciiz "\n Delete succeeded !"
msgFindNumber: .asciiz "\n What number to find?"
msgWhichBase: .asciiz "\n Which base would you like to work with?"
msgTheAVG: .asciiz "\n The AVG is:"
msgTheMAX: .asciiz "\n The MAX is:"
msgBase: .asciiz " (base:"
msgTheSortedArr: .asciiz " After Sort"
msgBaseInIndexEnd: .asciiz "), In index:"
msgTheArray: .asciiz "\n The Array is (base:"
################# Code segment #####################
.text
.globl main
main:	# main program entry
#registers for main $s
#registers for methods $t

	#print all menu options
	la $a0,msg1	
	li $v0,4
	syscall 
	
	#read option (as char)
	li $v0,12
	syscall
	
	#check valid input
	blt $v0, '1', main
	bgt $v0, '9', main
	
	addi $v0,$v0,-48 #convert ASCII to digit (-0x30 or -48)
	
	#Calculate case label address
	addi $v0,$v0,-1 	#adjust menu to labels in memory (starts in zero)

	la $s4, JumpTable 	#Load JumpTable pointer into $t4
	
	#Load Case Loaction from Jump Table
	sll $s1, $v0, 2 	#calculate word address at K=4*K | K=user input
	add $s0, $s1, $s4 	#t0 - JTable + 4*K
	lw $s0, 0($s0) 	#Load location of triggered case
	jr $s0 		#jump to case
	
############ Cases: ############
#1. add_number	
L0:	
	la $a1, array
	la $a2, NUM
	jal add_number
	j main
#2. replace
L1:
	la $a1, array
	la $a2, NUM
	jal replace
	j main
#3. del
L2:
	la $a1, array
	la $a2, NUM
	jal del
	j main
#4. find	
L3:	la $a1, array
	la $a2, NUM
	jal find
	j main
#5. average	
L4:	
	la $a1, array
	la $a2, NUM
	jal average
	j main
#6. max
L5:	
	la $a1, array
	la $a2, NUM
	jal max
	j main
#7. print_array	
L6:
	la $a1, array
	la $a2, NUM
	jal print_array
	j main
#8. sort	
L7:	
	la $a1, array
	la $a2, NUM
	la $a3, tempArray
	jal sort
	j main
#9. exit
L8:
	#Exit
	li $v0,10
	syscall
####################################################
#Procedure:  add_number (base 10)                   
#input: 	$a1 = $array, $a2 = NUM              
#output: 	add NUM to array if array isn't full-->
#-->(duplicates numbers in array are not allowed)
#override: t2, t4, t5, t8, a2             	
####################################################	 
add_number:
	#push $ra
	addiu $sp,$sp-4
	sw $ra,0($sp)
	
	lw $t2,0($a2) #load NUM
		
	blt $t2,30,arrayIsNotFull
	# print "The array is full !"
	la $a0, msgArrIsFull
	li $v0, 4
	syscall
	j exit_add_number
	
arrayIsNotFull:
	# print "What number to add?"
	la $a0, msgAddNumber
	li $v0, 4
	syscall
	
	#read integer
	li $v0,5
	syscall 	
	move $t8,$v0  #t8 = backup user number
	
	beq $t2,0,arrayIsEmpty

	jal check
	move $t4, $v0 # backup index if exist (search result - return value)
	bge $v0,0,numberAlreadyExist
arrayIsEmpty:
	# number isn't exist - add it to array:
	addi $t2,$t2,1 #NUM++
	sw $t2, ($a2)
	
	addi $t2,$t2,-1 #index are from zero
	sll $t2,$t2,2
	add $t5,$a1,$t2
	sw $t8,0($t5)
	
	# print total: "The number  was added ssucssefully (in index: )""
	#[1/5] print: "The number " 
	la $a0,msgTheNumber
	li $v0,4
	syscall
	
	#[2/5] print the number
	move $a0,$t8	
	li $v0,1
	syscall
	
	#[3/5] print: " was added successfully (in index: "
	la $a0,msgNumberAdded	
	li $v0,4
	syscall
		
	#calculate the index
	move $v0,$t8 
	jal check
	move $t4, $v0 #backup the index
	
	#[4/5] print the index
	move $a0,$t4
	li $v0,1
	syscall
		
	#[5/5] print: ")"
	la $a0,msgInIndexEnd	
	li $v0,4
	syscall
	
	j exit_add_number
	
numberAlreadyExist:
	# print total:  "The number  is already exist (in index: ) :: add_number terminated !"
	#[1/5] print: "The number "
	la $a0,msgTheNumber
	li $v0,4
	syscall
	
	#[2/5] print the number
	move $a0,$t8	
	li $v0,1
	syscall
	
	#[3/5] print: " is already exist (in index: "
	la $a0,msgNumberExist
	li $v0,4
	syscall
		
	#[4/5] print the index
	move $a0,$t4	
	li $v0,1
	syscall
	
	#[5/5] print: "...) :: add_number terminated !"
	la $a0,msgAddNumberAbort	
	li $v0,4
	syscall
	
exit_add_number:

	#pop ra
	lw $ra, 0($sp)
	addiu $sp,$sp,4
		
	jr $ra
###################################################################
#Procedure: check		  		 
#input: $a1= $array, $a2= NUM, $v0= inputNumber                  
#output: $v0= binary search result-->
#--> (returns the index of inputNumber in array, -1 if not found)
#override: t0
#############################################################
check:	
	lw $t2,($a2) # load NUM
	li $t0, 0
			
	#push $a1 #address of array
	addiu $sp,$sp-4
	sw $a1,0($sp)

seacrhLoop:
	lw $t6,($a1)
	bne $t6,$v0,notFound
	move $v0,$t0 #return value - index
	j found
notFound:
	addi $t0,$t0,1
	addi $a1,$a1,4
	blt $t0,$t2, seacrhLoop
		
	li $v0,-1 #return value - not found
found:
	#pop a1
	lw $a1, 0($sp)
	addiu $sp,$sp,4
	
	jr $ra
###################################################################
#Procedure: replace		  		 
#input:    $a1= $array, $a2= NUM			                  
#output: The numbers that exists in both arrays in decending order
#override: t4, t5, t7, t9
##############################################################
replace:
	#push $ra
	addiu $sp,$sp-4
	sw $ra,0($sp)
	
	lw $t2,0($a2) #load NUM
	
	bgt $t2,0,arrayIsNotEmpty
	# print: "Array is Empty."
	la $a0, msgArrayIsEmpty
	li $v0, 4
	syscall
	j exit_replace
	
arrayIsNotEmpty:
	# print: "What number to replace?"
	la $a0, msgNumber2Replace
	li $v0, 4
	syscall
	
	#read integer
	li $v0,5
	syscall
	move $t9, $v0  # backup OLD number
	
	jal check
	move $t4, $v0  # backup OLD index
	
	bge $v0,0,numberExist_replace
	# print total:  "The number  was not found in the array"
	#[1/3] print "The number "
	la $a0,msgTheNumber
	li $v0,4
	syscall
	
	#[2/3] print the number
	move $a0,$t9	
	li $v0,1
	syscall
		
	#[3/3] print: " was not found in the array :: Replacement terminated!"
	la $a0,msgNumberNotFoundRep	
	li $v0,4
	syscall
	j exit_replace
	
numberExist_replace:
	# print total: "The number  is exist (in index: ) --> Replace with what number?"
	#[1/5] print "The number "
	la $a0,msgTheNumber
	li $v0,4
	syscall
	
	#[2/5] print the number
	move $a0,$t9	
	li $v0,1
	syscall

	#[3/5] print: " is exist (in index: "
	la $a0,msgNumberExistR
	li $v0,4
	syscall
	
	#[4/5] print the index
	move $a0,$t4	
	li $v0,1
	syscall
	
	#[5/5] print: "...) --> Replace with what number?"
	la $a0,msgWithWhatNumber	
	li $v0,4
	syscall
	
	#read integer
	li $v0,5
	syscall 	
	move $t5, $v0   # backup the NEW number
	
	jal check
	move $t7, $v0   # backup index (search result - return value)
	
	bge $v0,0,number2Exist_replace
	# $t4 = backup OLD index
	# $t5 = backup the NEW number
	sll $t4,$t4,2
	add $t4,$t4,$a1
	sw $t5,($t4)
	
	# print: "Replacement succeeded !" 
	la $a0,msgReplacementSucceeded
	li $v0,4
	syscall
	
	j exit_replace
	
number2Exist_replace:

# print total:  "The number  is already exist (in index: ) :: Replacement terminated !"
	#[1/5] print "The number " 
	la $a0,msgTheNumber
	li $v0,4
	syscall
	
	#[2/5] print the number 
	move $a0,$t5	
	li $v0,1
	syscall
	
	#[3/5] print: " is already exist (in index: "
	la $a0,msgNumberExist
	li $v0,4
	syscall
	
	#[4/5] print the index
	move $a0,$t7	
	li $v0,1
	syscall
	
	#[5/5] print: "... :: replacement terminated !"
	la $a0,msgReplacementAbort	
	li $v0,4
	syscall

exit_replace:

	#pop ra
	lw $ra, 0($sp)
	addiu $sp,$sp,4
	
	jr $ra
###################################################################
#Procedure: del	  		 
#input:   $a1 = $array, $a2 = NUM			                  
#output: delete given number from the array
##############################################################
del:
	#push $ra
	addiu $sp,$sp-4
	sw $ra,0($sp)
	
	lw $t2,0($a2) #load NUM
	
	bgt $t2,0,deleteNumber
	# print: "Array is Empty."
	la $a0, msgArrayIsEmpty
	li $v0, 4
	syscall
	j exit_del
	
deleteNumber:

	# print: "What number to delete?"
	la $a0, msgNumber2Del
	li $v0, 4
	syscall
	
	#read integer
	li $v0,5
	syscall
	move $t4, $v0  # backup number to delete
	
	jal check
	move $t7, $v0   # backup index (search result - return value)
	
	bge $v0,0,numberExist_delete
	# print total:  "The number  couldn't be found in the array :: Delete terminated !"
	#[1/3] print "The number " 
	la $a0,msgTheNumber
	li $v0,4
	syscall
	
	#[2/3] print the number 
	move $a0,$t4	
	li $v0,1
	syscall
	

	#[3/3] print " couldn't be found in the array :: Delete terminated !"
	la $a0,msgNumberNotFoundDel
	li $v0,4
	syscall

	j exit_replace
	
numberExist_delete:
	move $v0,$t7 # backup the index for reduction
		
	# $v0 = index
	jal reduction
	
	#decrease array size (NUM)
	addi $t2,$t2,-1 #NUM--
	sw $t2, ($a2)
	
	# print: "Delete succeeded !" 
	la $a0,msgDeleteSucceeded
	li $v0,4
	syscall
	
exit_del:
	#pop ra
	lw $ra, 0($sp)
	addiu $sp,$sp,4
		
	jr $ra
###################################################################
#Procedure: reduction	  		 
#input :  $a1= $array, $a2= NUM, $v0= numberIndex			                  
#output:  reduces all numberes indexes one index to left (index--)		                  
##############################################################
reduction:
	lw $t2,($a2) #load NUM
	move $t7,$v0 # $t7 = index
	move $t5, $t7 #couter for loop

	sll $t7,$t7,2
	add $t7,$t7,$a1
redLoop:   # while t4<NUM
	lw $t4,4($t7)
	sw $t4,0($t7)
	addi $t7,$t7,4 #t4++
	addi $t5,$t5,1
	bne $t5,$t2,redLoop

	jr $ra
###################################################################
#Procedure: find
#input:   $a1= $array, $a2= NUM
#output: index of the number (given by the user)  in the array
##############################################################
find:
	#push $ra
	addiu $sp,$sp-4
	sw $ra,0($sp)
			
	lw $t2,0($a2) #load NUM
	
	bgt $t2,0,findNumber
	# print: "Array is Empty."
	la $a0, msgArrayIsEmpty
	li $v0, 4
	syscall
	j exit_find
	
findNumber:	
	# print "What number to find?" 
	la $a0,msgFindNumber
	li $v0,4
	syscall
	
	#read integer
	li $v0,5
	syscall
	move $t4, $v0  # backup number to delete
	
	jal check
	move $t7, $v0   # backup index (search result - return value)
	
	bge $v0,0,numberIsExist
	# print total:  "The number  couldn't be found in the array :: Find terminated !"
	#[1/3] print "The number " 
	la $a0,msgTheNumber
	li $v0,4
	syscall
	
	#[2/3] print the number 
	move $a0,$t4	
	li $v0,1
	syscall
	
	#[3/3] print " couldn't be found in the array :: Find terminated !"
	la $a0,msgNumberNotFound
	li $v0,4
	syscall

	j exit_find
	
numberIsExist:
	# print total: "The number  is exist (in index: )"
	#[1/5] print "The number "
	la $a0,msgTheNumber
	li $v0,4
	syscall
	
	#[2/5] print the number
	move $a0,$t4	
	li $v0,1
	syscall

	#[3/5] print: " is exist (in index: "
	la $a0,msgNumberExistR
	li $v0,4
	syscall
	
	#[4/5] print the index
	move $a0,$t7	
	li $v0,1
	syscall
	
	#[5/5] print: ")"
	la $a0,msgInIndexEnd
	li $v0,4
	syscall
	
exit_find:
	#pop ra
	lw $ra, 0($sp)
	addiu $sp,$sp,4

	jr $ra	
###################################################################
#Procedure: average	  		 
#input:  	$a1= $array, $a2= NUM		                  
#output: AVG of all array elements
##############################################################
average:
	#push $ra
	addiu $sp,$sp-4
	sw $ra,0($sp)
			
	lw $t2,0($a2) #load NUM
	
	bgt $t2,0,calcAverage
	# print: "Array is Empty."
	la $a0, msgArrayIsEmpty
	li $v0, 4
	syscall
	j exit_average
	
calcAverage:

	#while t0 < NUM
	la $t0,($a1)
	li $t5,0 #sum-->avg
	li $t6,0 # counter
sumLoop:	
	lw $t4,($t0)
	add $t5,$t5,$t4
	addi $t0,$t0,4
	addi $t6,$t6,1 # counter
	bne $t6,$t2,sumLoop
	div $t5,$t5,$t2 # t5 contain the avg
	
inputAgain:	
	# print: "Which base would you like to work with?"
	la $a0,msgWhichBase
	li $v0,4
	syscall
		
	#read integer (base number to calc)
	li $v0,5
	syscall
	# move $t7,$v0 #backup base
	
	bgt $v0,10,inputAgain
	blt $v0,2,inputAgain
	
	move $a2,$v0 # base
	move $a1,$t5 # avg
	
	#[1/5] print: "The AVG is: "
	la $a0, msgTheAVG
	li $v0, 4
	syscall
	
	#[2/5]
	jal print_num
	
	#[3/5] print: " (base: "
	la $a0, msgBase
	li $v0, 4
	syscall
	
	#[4/5] print the base
	move $a0, $a2
	li $v0, 1
	syscall
	
	#[5/5] print: ")"
	la $a0, msgInIndexEnd
	li $v0, 4
	syscall
	
exit_average:
	#pop ra
	lw $ra, 0($sp)
	addiu $sp,$sp,4
	
	jr $ra
###################################################################
#Procedure: print_num	  		 
#input:  	$a1= $number, $a2= base (2-10)		                  
#output: convert number to the base and print it
##############################################################
print_num:
	beq $a2,10,decimal
	#not decimal
	bgtz $a1, positiveNum
	# negativeNum:
	# print minus '-'
	li $a0,'-'	
	li $v0,11
	syscall
	
	mul $a1,$a1,-1
	 
positiveNum:
	li $t6,0 #counter
disassemblyLoop:
	div $a1,$a2
	# mfhi = move from HI (remainder)
	# mflo = move from LO (div)
	mfhi $t4
	
	#push $t4
	addiu $sp,$sp-4
	sw $t4,0($sp)
	addi $t6,$t6,1 #counter
	mflo $a1
	bgtz $a1,disassemblyLoop
	
assemblyLoop:
	#pop $t4
	lw $t4, 0($sp)
	addiu $sp,$sp,4
	
	# print the number
	move $a0,$t4	
	li $v0,1
	syscall

	addi $t6,$t6,-1 #counter
	bgtz $t6,assemblyLoop
	j exit_print_num
	
decimal:
	# print the avg
	move $a0,$a1	
	li $v0,1
	syscall

exit_print_num:
	jr $ra
###################################################################
#Procedure: max	  		 
#input:  	$a1= $array, $a2= NUM		                  
#output: MAX element of all array elements
##############################################################
max:
	#push $ra
	addiu $sp,$sp-4
	sw $ra,0($sp)
			
	lw $t2,0($a2) #load NUM
	
	bgt $t2,0,findMax
	# print: "Array is Empty."
	la $a0, msgArrayIsEmpty
	li $v0, 4
	syscall
	j exit_max
	
findMax:
	la $t0,($a1)
	li $t5,0 #MAX
	li $t6,0 # counter
findMaxLoop:	
	lw $t4,($t0)
	blt $t4,$t5,notMax
	#max:
	move $t5,$t4
	move $t8,$t6 # save index of max
notMax:
	addi $t0,$t0,4
	addi $t6,$t6,1 # counter
	bne $t6,$t2,findMaxLoop
	
inputAgainM:	
	# print: "Which base would you like to work with?"
	la $a0,msgWhichBase
	li $v0,4
	syscall
		
	#read integer (base number to calc)
	li $v0,5
	syscall
	# move $t7,$v0 #backup base
	
	bgt $v0,10,inputAgainM
	blt $v0,2,inputAgainM
	
	move $a2,$v0 # base
	move $a1,$t5 # MAX
	
	#[1/6] print: "The MAX is: "
	la $a0, msgTheMAX
	li $v0, 4
	syscall
	
	#[2/6]
	jal print_num
	
	#[6/6] print: " (base: "
	la $a0, msgBase
	li $v0, 4
	syscall
	
	#[4/6] print the base
	move $a0, $a2
	li $v0, 1
	syscall
	
	#[5/6] print: "), In index:"
	la $a0, msgBaseInIndexEnd
	li $v0, 4
	syscall
	
	#[6/6] print the index
	move $a0, $t8
	li $v0, 1
	syscall

exit_max:
	#pop ra
	lw $ra, 0($sp)
	addiu $sp,$sp,4
	
	jr $ra
###################################################################
#Procedure: print_array  		 
#input: 	$a1= $array, $a2= NUM   			                  
#output:The numbers that exists in both arrays in decending order 
##############################################################
print_array:
	#push $ra
	addiu $sp,$sp-4
	sw $ra,0($sp)
			
	lw $t2,0($a2) #load NUM
	
	bgt $t2,0,inputAgainP
	# print: "Array is Empty."
	la $a0, msgArrayIsEmpty
	li $v0, 4
	syscall
	j exit_print_array
	
inputAgainP:	
	# print: "Which base would you like to work with?"
	la $a0,msgWhichBase
	li $v0,4
	syscall
		
	#read integer (base number to calc)
	li $v0,5
	syscall
	# move $t7,$v0 #backup base
	
	bgt $v0,10,inputAgainP
	blt $v0,2,inputAgainP
	
	move $a2,$v0 # base for print_num method
	
	#print "The Array (base:"
	la $a0,msgTheArray
	li $v0,4
	syscall
	
	#print the base"
	move $a0,$a2
	li $v0,1
	syscall
		
	#print ") is:"
	la $a0,msgInIndexEndS
	li $v0,4
	syscall
		
	li $t4,0 #counter
	addi $t7,$t2,-1 #last index
	add $t8,$t4,$a1
	
printLoop:	
	lw $t5,($t8)
	move $a1,$t5 # number
	
	#push t4
	addiu $sp,$sp-4
	sw $t4,0($sp)
			
	jal print_num
	
	#pop t4
	lw $t4, 0($sp)
	addiu $sp,$sp,4
	
	beq $t4,$t7,dontPrintComma
	# print a comma
	li $a0, ','
	li $v0, 11
	syscall
	j endPrint
	
dontPrintComma:
	# print a ']'
	li $a0, ']'
	li $v0, 11
	syscall
endPrint:
	addi $t4,$t4,1
	addi $t8,$t8,4	
	blt $t4,$t2,printLoop

exit_print_array:
	#pop ra
	lw $ra, 0($sp)
	addiu $sp,$sp,4
	
	jr $ra	
###################################################################
#Procedure: sort  		 
#input:  $a1= array, $a2= NUM, $a3= tempArray     
#output: copy the array to tempArray, sort it (bubble) and print it (call print_array)
##############################################################
sort:
	#push $ra
	addiu $sp,$sp-4
	sw $ra,0($sp)

	lw $t2,0($a2) #load NUM
	
	bgt $t2,0,sortStart
	# print: "Array is Empty."
	la $a0, msgArrayIsEmpty
	li $v0, 4
	syscall
	j exit_sort
	
sortStart:
	# copy array to tempArray
	li $t4,0 
	li $t6,0 
	li $t7,0
	add $t6,$t6,$a1 #array
	add $t7,$t7,$a3 #tempArray
copyArr:
	lw $t8,($t6)	
	sw $t8,($t7)

	addi $t4,$t4,1
	addi $t7,$t7,4
	addi $t6,$t6,4
	blt $t4,$t2,copyArr
	
	li $t3,0 #i
	add $t5,$t2,-1 #NUM-1
bubbleSort:
	li $t4,1 #j
	li $t6,0 
	li $t7,0
	add $t7,$t7,$a3 #tempArray
innerLoop:
	lw $t8,($t7)
	lw $t9,4($t7)
	blt $t8,$t9,dontSwap
	#swap
	sw $t9,($t7)
	sw $t8,4($t7)
dontSwap:	
	addi $t4,$t4,1
	addi $t7,$t7,4
	blt $t4,$t2,innerLoop
	
	addi $t3,$t3,1
	blt $t3,$t2,bubbleSort
	
	move $a1,$a3 # $tempArray
	jal print_array
	
	# print: "The sorted array ^"
	la $a0, msgTheSortedArr
	li $v0, 4
	syscall
exit_sort:	
	#pop ra
	lw $ra, 0($sp)
	addiu $sp,$sp,4
	
	jr $ra
