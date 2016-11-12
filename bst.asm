data segment
    s label byte
	max_size db 5
	act_size db ?
	input_str db 5 dup('$') 
	temp db 5			;number of inputs
	root db 200 dup(0)	;binary search tree
	avail dw ?
	s1 db 200 dup('$')
	nl db ',$'
	print_ptr db 3
	ac db 0
data ends

extra_data segment
	db 100 dup(0) 	;to store the traversal order
extra_data ends

stk segment
    dw 100 dup(0) 	;stack for recursion
    top label word
stk ends

code segment 
    
start: assume cs:code,ss:stk,ds:data,es:extra_data
    mov ax,data
    mov ds,ax
	mov ax,stk
	mov ss,ax
    lea sp,top
	mov ax,extra_data
	mov es,ax
	
	inp_lop: call far ptr insert	;loop for taking input
	sub temp,1	;decrement counter
	cmp temp,0
	jnz inp_lop
	
	mov di,0
	lea bx,root	
	push bx
	push ax
	call preorder
	pop ax
	pop bx
	mov di,0
	lea bx,root
	push bx
	push ax
	call inorder
	pop ax
	pop bx
	mov di,0
	lea bx,root
	push bx
	push ax
	call postorder
	pop ax
	pop bx
	
    mov ah,4ch
	int 21h
    
	insert proc far
        mov ah,0Ah
		lea dx,s
		int 21h
		inc act_size
		call input
		lea bx,root
		cmp [root], 0
		JE first
	here:
		cmp ax, [bx]
		JA greater
		cmp byte ptr [bx+2],0
		JE emptyL
		mov bx, [bx+2]
		JMP here
	emptyL:
		mov dx, avail
		mov [bx+2], dx
		JMP exit
	greater:
		cmp byte ptr [bx+4],0
		JE emptyG
		mov bx, [bx+4]
		JMP here
	emptyG:
		mov dx, avail
		mov [bx+4], dx
		JMP exit
    first: 
		mov avail, bx
	exit: 
		mov bx, avail
		mov [bx],ax
		add avail, 06H	
	insert endp

	input proc near
		lea si,input_str
		mov al,0h
		mov bh,act_size
		sub bh,1h
		mov cl,bh
		mov bh,10h
		again:
			mov bl,[si]
			sub bl,30h
			mul bh
			add al,bl
			inc si
			dec cl
			jnz again			
		ret
	
	input endp
	
	preorder proc near
		mov bp,sp
		add bp,4
		mov si,[bp]
		mov ax,[si]
		cmp si,0
		jz fin
		cmp ax,0
		jz fin
		mov [es:di],al   ;print to es
		inc di
		;push ax
		;call far ptr IntToStr
		;pop ax
		mov bx,[si+2]
		push bx
		push si
		call preorder
		pop si
		pop bx
		mov bx,[si+4]
		push bx
		push si
		call preorder
		pop si
		pop bx
		
		fin:
			ret
		
	preorder endp
       
	inorder proc near
		mov bp,sp
		add bp,4
		mov si,[bp]
		mov ax,[si]
		cmp si,0
		jz fini
		cmp ax,0
		jz fini
		mov bx,[si+2]
		push bx
		push si
		call inorder
		pop si
		pop bx
		mov ax,[si]
		mov [es:di],al  ;print to es
		inc di
		;push ax
		;call far ptr IntToStr
		;pop ax
		mov bx,[si+4]
		push bx
		push si
		call inorder
		pop si
		pop bx
		
		fini:
			ret
		
	inorder endp  

	postorder proc near
		mov bp,sp
		add bp,4
		mov si,[bp]
		mov ax,[si]
		cmp si,0
		jz finis
		cmp ax,0
		jz finis
		mov bx,[si+2]
		push bx
		push si
		call postorder
		pop si
		pop bx
		mov bx,[si+4]
		push bx
		push si
		call postorder
		pop si
		pop bx
		mov ax,[si]
		mov [es:di],al  ;print to es
		inc di
		;push ax
		;call far ptr IntToStr
		;pop ax
		finis:
			ret
		
	postorder endp   	
	   
code ends    

code2 segment
assume cs:code2
IntToStr proc far
    
    mov bp,sp
	add bp,6
	mov si,[bp]
	mov ax,si
	lea cx,s1
	add cl,print_ptr
	mov bx,cx
aga:
	add ac,0
    mov ah,0
    mov cl,10
    div cl         ;div number by 10
	add ah,30h     ;add 30 to convert to character  
	mov [bx],ah
    dec bx
    cmp al,0
    jne aga
print:
	inc bx
    mov dx,bx
    mov ah,9h
    int 21h
	lea dx,nl
	mov ah,9h
	int 21h
	add print_ptr,3
	ret

IntToStr endp
code2 ends

end start
    
