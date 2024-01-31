[org 0x0100]

jmp start



playerCol: dw 66
playerRow: dw 40
oldplatformCol: dw 56
newplatformCol: dw 56
newplatformRow: dw 35
oldplatformRow: dw 41
oldisr: dd 0 
oldtimer: dd 0
terminateflag: db 0
platformshiftdirection: db 0 ; zero=left, 1=right
oldplatformshiftdirection: db 1 ; zero=left, 1=right
newplatforminitialcol: dw 66
newplatforminitialrow: dw 35
resetplatformspeedcounter: dw 2
newplatformspeedcounter:dw 2
oldplatformspeedcounter:dw 2
haycolumn: dw 66
hayrow: dw 36
haycollected: db 0
upkeypressed: db 0 ; 0=not pressed
score: dw 0
platformAttribute: dw 0x70ba
oldplatformAttribute: dw 0x70ba
newplatformAttribute: dw 0x50ba
platformshiftflag: db 1
hayspawned: db 1
rows: db 43
cols: db 132
tickcount: dw 0
introscreenflag: db 1
buffer: times 300 dw 0x7031
pauseflag: db 0
resumeflag: db 0
timervalue: dw 3
endscreenflag: db 1


scorelocationrow: dw 31
scorelocationcol: dw 125
scoretext: db 'Score: '
scoretextlength: dw 7

rollnum1locationrow: dw 6
rollnum1locationcol: dw 109
rollnum1text: db 'Aun Noman (22L-6950)'
rollnum1length: dw 20

rollnum2locationrow: dw 8
rollnum2locationcol: dw 115
rollnum2text: db 'Muhummad Rohaim (22L-6573)' 
rollnum2length: dw 26

introTextlocationrow: dw 16
introTextlocationcol: dw 74
introText: db 'Press Enter to Play!'
introTextlength: dw 20

instructionText1locationrow: dw 22
instructionText1locationcol: dw 70
instructionText1: db 'INSTRUCTIONS:'
instructionText1length: dw 13

instructionText2locationrow: dw 24
instructionText2locationcol: dw 90
instructionText2: db 'Press UP key to jump and Collect Hay to get score.'
instructionText2length: dw 50

instructionText3locationrow: dw 26
instructionText3locationcol: dw 110
instructionText3: db 'Falling from platform or staying on Blue platform for too long will eliminate you.'
instructionText3length: dw 82


pausescreen1locationrow: dw 18
pausescreen1locationcol: dw 72
pausescreen1text: db 'GAME PAUSED'
pausescreen1length: dw 11

pausescreen2locationrow: dw 20
pausescreen2locationcol: dw 76
pausescreen2text: db 'Press E to End game'
pausescreen2length: dw 19

pausescreen3locationrow: dw 22
pausescreen3locationcol: dw 78
pausescreen3text: db 'Press R to Resume game'
pausescreen3length: dw 22
endscreenlocationrow: dw 18
endscreenlocationcol: dw 71
endscreentext: db 'GAME OVER!'
endscreenlength: dw 10

endscreen2locationrow: dw 23
endscreen2locationcol: dw 78
endscreen2text: db 'Press Enter to Quit Game'
endscreen2length: dw 24





clrscreen:;clears everything on the screen
	push ax
	push es
	push di
	
	mov ax,0xB800
	mov es,ax
	mov di,0
	
	nextloc:
		mov word [es:di],0x0720
		add di,2
		cmp di,11352
		jne nextloc
	
	pop di
	pop es
	pop ax
	ret

		
printpixel: ;takes  hex code of character ,atribute byte, row number and col number as parameters
	push bp
	mov bp,sp
	push es
	push ax
	push di
	
	
	mov ax,0xB800
	mov es,ax
	;calculating screen location
	mov al,[cols] 
	mul byte [bp + 6] ;multiply total columns by row number 
	add ax,[bp + 4] ;add col number
	shl ax,1 ;multiply by 2
	mov di,ax ;index on the screen
	
	mov ax,[bp + 8] ;atribute byte
	mov ah,al
	mov al,[bp + 10];character

	
	
	mov [es:di],ax
		
		
	
	
	pop di
	pop ax
	pop es
	pop bp
	
	ret 8
	
	
printline: ;takes atribute byte and row number as parameters
	push bp
	mov bp,sp
	push cx
	push di
	push ax
	
	mov cx,0 ;col number
	mov di,[bp + 4] ;row number
	mov ax,[bp + 6] ;colour	
	
	lineloop:
		push 0x20 ; hex of space
		push ax
		push di
		push cx
		call printpixel
		inc cx
		cmp cl,[cols]
		jne lineloop
		
	pop ax
	pop di
	pop cx
	pop bp
	ret 4
		
	
dividescreen:
	push ax
	push dx
	
	mov ax,0
	mov al,[rows]
	mov dx,0
	mov dl,3
	div dl
	mov ah,0
	
	;drawing 1st line
	push 0x77 ;white colored line
	push ax  ;row number
	call printline
	
	shl ax,1
	inc ax
	
	;drawing 2nd line
	push 0x77 ;white colored line
	push ax ;row number
	call printline
	
	pop dx
	pop ax
	ret
	
printbackground:;takes the colour, the starting row and the height of the background as parameters
	
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	
	mov bx,[bp + 6] ;row number
	mov cx,[bp + 4] ;height
	mov ax,[bp + 8] ;color 
	
	backgroundloop:
		push ax
		push bx
		call printline
		inc bx
		dec cx
		cmp cx,0
		jne backgroundloop
	
	
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6
	

printAllBackgrounds:; takes the color of the 1st,2nd and 3rd background as parameters
	push bp
	mov bp,sp
	push ax
	push dx
	push bx
	push cx
	
	mov ax,0 ;to store height of each background
	mov al,[rows]
	mov dx,0
	mov dl,3
	div dl
	mov ah,0
	mov bx,0;store starting col
	

	;1st background
	mov dx,[bp + 8];1st color
	push dx
	push bx
	push ax
	call printbackground
	
	
	mov bx,ax
	inc bx
	
	;2nd background
	mov dx,[bp + 6];1st color
	push dx
	push bx
	push ax
	call printbackground
	
	shl bx,1

	
	;3rd background ;NEED TO ADJUST THE LENGTH OF THIS PART ACCORDING TO THE ROW NUMBER
	mov dx,[bp + 4];3rd color
	push dx
	push bx
	push ax
	call printbackground
	
	
	pop cx
	pop bx
	pop dx
	pop ax
	pop bp
	ret 6
	


printRectangle:;takes the starting row, starting col, width, height and color of the rectangle as parameters
	
	push bp
	mov bp,sp
	push si
	push di
	push dx
	push bx
	push cx
	
	mov si,[bp + 12];starting row number
	mov di,[bp + 10];starting col number
	mov dx,[bp + 4];color
	add [bp + 6],si;ending row number
	add [bp + 8],di;ending col number
	
		printRectangleLoop1:
			push 0x20  ;hex code of space
			push dx
			push si
			push di
			call printpixel
			inc si
			cmp si,[bp + 6]
			jne printRectangleLoop1
	
	continue:
		mov si,[bp + 12]
		inc di
		cmp di,[bp + 8]
		jne printRectangleLoop1
	
	pop cx
	pop bx
	pop dx
	pop di
	pop si
	pop bp
	ret 10
	


printbuilding: ; takes starting row, starting col, width, height and color of building wall
	push bp 
	mov bp,sp
	sub sp,2
	sub sp,2
	push ax
	push bx
	push dx
	push cx
	push si
	push di
	
	mov si,[bp + 12];starting row number
	mov di,[bp + 10];starting col number
	mov dx,[bp + 4];color
	mov bx , [bp+6] ; height
	mov [bp-2], bx
	mov bx , [bp+8] ;width
	mov [bp-4], bx
	add [bp-2],si;ending row number
	add [bp-4],di;ending col number
	printtopcorners:
		push 0xda
		push dx
		push si
		push di
		call printpixel
		push 0xbf
		push dx
		push si
		push word [bp-4]
		call printpixel
	inc di
	printTopBoundaray:
		push 0xc4
		push dx
		push si
		push di
		call printpixel
		inc di
		cmp di,[bp-4]
		jne printTopBoundaray
	mov di,[bp + 10]
	inc si
	printsideboundarys:
		push 0xb3
		push dx
		push si
		push di
		call printpixel
		add di ,[bp+8]
		push 0xb3
		push dx
		push si
		push di
		call printpixel
		sub di,[bp+8]
		inc si
		cmp si,[bp-2]
		jne printsideboundarys

	fillinside:
		mov si,[bp + 12];starting row number
		mov di,[bp + 10];starting col number
		inc si
		inc di
		push si
		push di
		mov bx , [bp+8] ;width
		sub bx,1
		push bx
		mov bx , [bp+6] ; height
		sub bx,1
		push bx
		push dx
		call printRectangle
	windows:
		mov bx,[bp+12] ;starting row of building
		add bx,2
		mov [bp-2],bx ; starting row of first Window
		mov bx,[bp+10] ;starting col of building
		cmp word [bp+8],10 ; comparing width to 10
		jle buildingwidthnotgreaterthanten
			mov bx,[bp+8]
			shr bx,1
			add bx,[bp+10]
			sub bx,2
			jmp windowstartingcolcalculated
		buildingwidthnotgreaterthanten:
		add bx,3
		windowstartingcolcalculated:
		mov [bp-4],bx ; starting col of first Window
		mov dx, [bp+8] ; building width
		sub dx, 4 ; width of a window + space between them
		cmp dx,6
		jle windowsizenotgreaterthansix
			mov dx,6
		windowsizenotgreaterthansix:
		mov ax, [bp+6] ;building height;
		div dl ;  dviding building height by window height/width to get number of windows that will fit in building
		sub dx,2
		
		
	windowsloop:
		push word [bp-2] 
		push word [bp-4]
		push dx
		call printwindows
		add [bp-2],dl
		add word [bp-2],1
		dec al
		jnz windowsloop
		
		
	pop di
	pop si
	pop cx
	pop dx
	pop bx
	pop ax
	add sp,4
	pop bp
	ret 10
	
printwindows: ; takes starting row, starting col, height
    push bp
    mov bp, sp
	push ax
    push si
    push di
    push dx
    push bx
    push cx

    ; Parameters
    mov si, [bp + 8]  ; starting row number
    mov di, [bp + 6]  ; starting col number
    mov bx, [bp + 4]   ; height
	mov dx,01111000b ; black foreground and white background
    ; Draw windows
    mov ax, 0xc9  ; Window top left character
    push ax
    push dx 
    push si
    push di
    call printpixel
	
	add di,bx
	push 0xBB  ; Window top right character
    push dx
    push si
    push di
    call printpixel
	
	mov di, [bp + 6]
	add di,1
	add bx,[bp+6]
	
	printWindowTop:
		push 0xCD
		push dx ; black foreground and white background
		push si
		push di
		call printpixel
		add di,1
		cmp di,bx
		jne printWindowTop
	mov di,[bp + 6]
	inc si
	mov bx,[bp+8]
	add bx,[bp+4]
	dec bx
	printwindowsideboundarys:
		push 0xba
		push dx
		push si
		push di
		call printpixel
		add di ,[bp+4]
		push 0xba
		push dx
		push si
		push di
		call printpixel
		sub di,[bp+4]
		inc si
		cmp si,bx
		jne printwindowsideboundarys

    push 0xc8  ; Window bottom left character
    push dx
    push si
    push di
    call printpixel
	mov bx,[bp+4]
	add di,bx
    push 0xBC  ; Window bottom right character
    push dx
    push si
    push di
    call printpixel

	mov di, [bp + 6]
	add di,1
	mov bx, [bp + 4]
	add bx,[bp+6]
	
	printWindowBottom:
		push 0xcd
		push dx ; black foreground and white background
		push si
		push di
		call printpixel
		inc di
		cmp di,bx
		jne printWindowBottom
    windowfillinside:
		mov si,[bp + 8];starting row number
		mov di,[bp + 6];starting col number
		inc si
		inc di
		push si
		push di
		mov bx , [bp+4] ;width 
		sub bx,1
		push bx 
		sub bx,1 ;height
		push bx
		push dx ; colour
		call printRectangle
	
    pop cx
    pop bx
    pop dx
    pop di
    pop si
	pop ax
    pop bp
    ret 6
	
	
printroadlines:;takes size and color of road lines
	push bp
	mov bp,sp
	push ax
	push dx
	push di
		
	mov di,0 ;col num	
	mov ax,[bp + 6] ;size
	mov dx,[bp + 4] ;color
	printroadline:
		push 0x20 
		push dx
		push 21 ;row num
		push di
		call printpixel
		inc di
		dec ax
		cmp ax,0
		jne printroadline
	continueRoadline:
		mov ax,[bp + 6]
		add di,5
		cmp di,132
		jb printroadline
	
	pop di
	pop dx
	pop ax
	pop bp
	ret 4
	
	
	
printcar:;takes the starting row, starting col, width, height and color of the car as parameters
	push bp
	mov bp,sp
	push ax
	push dx
	
	bottomhalf:
		mov ax,[bp + 12]
		push ax
		mov ax,[bp + 10]
		push ax
		mov ax,[bp + 8]
		push ax
		mov ax,[bp + 6]
		shr ax,1
		push ax
		mov ax,[bp + 4]
		push ax
		
		call printRectangle
		
		
	
	tophalf:
		mov ax,[bp + 12]
		sub ax,3
		push ax
		mov ax,[bp + 10]
		add ax,6
		push ax
		mov ax,[bp + 8]
		shr ax,1
		add ax,2
		push ax
		mov ax,[bp + 6]
		shr ax,1
		push ax
		mov ax,[bp + 4]
		push ax
		
		call printRectangle
		
		mov ax,[bp + 12]
		sub ax,2
		push ax
		mov ax,[bp + 10]
		add ax,7
		push ax
		mov ax,[bp + 8]
		shr ax,1
		push ax
		mov ax,[bp + 6]
		shr ax,1
		dec ax
		push ax
		push 0x33
		
		call printRectangle
		
	tires:
		mov ax,[bp + 12];row num
		push ax
		mov ax,[bp + 10];col num
		push ax
		mov ax,[bp + 6];height
		push ax
		mov ax,[bp + 8];width
		push ax
		call printCarTires
		
	headlight:
		; mov ax,[bp + 12]
		; push ax
		; mov ax,[bp + 10]
		; push ax
		; push 2
		; push 1
		; push 0x66
		; call printRectangle
		mov ax,[bp + 12]
		push ax
		mov ax,[bp + 10]
		push ax
		push 2
		push 1
		push 0x66
		call printRectangle
		
	pop dx
	pop ax
	pop bp
	
	ret 10
	
	
printCarTires:;takes starting row, starting col, height and width of car as input

		push bp
		mov bp,sp
		push ax
		push dx
		
		;left tire
		mov ax,[bp + 10]
		mov dx,[bp + 6]
		shr dx,1
		add ax,dx
		dec ax
		push ax
		
		mov ax,[bp + 8]
		add ax,6
		push ax
		push 4
		push 2
		push 0x77
		call printRectangle
		
		;right tire
		mov ax,[bp + 10]
		mov dx,[bp + 6]
		shr dx,1
		add ax,dx
		dec ax
		push ax
		
		mov ax,[bp + 8]
		add ax,[bp + 4]
		sub ax,10
		push ax
		push 4
		push 2
		push 0x77
		call printRectangle
		
		pop dx
		pop ax
		pop bp
		ret 8
		
		
shiftrowright: ;takes row number as input
	push bp
	mov bp,sp
	push ax
	push si
	push di
	push bx
	push cx
	push dx
	push es
	push ds

	mov ax,0xB800
	mov es,ax
	mov ds,ax
	mov ax,[bp+4]
	push ax
	push 131
	call calcScreenLoc
	mov dx, [es:di]
	mov si,di
	sub si,2
	std 
	mov cx,131
	rep movsw
	push ax
	push 0
	call calcScreenLoc
	mov [es:di],dx
	
	pop ds
	pop es
	pop dx
	pop cx
	pop bx
	pop di
	pop si
	pop ax
	pop bp
	ret 2
	
shiftrowleft: ;takes row number as input
	push bp
	mov bp,sp
	push ax
	push si
	push di
	push bx
	push cx
	push dx
	push es
	push ds
	
	mov ax,0xB800
	mov es,ax
	mov ds,ax
	mov ax,[bp+4]
	push ax
	push 0
	call calcScreenLoc
	mov dx, [es:di]
	mov si,di
	add si,2
	cld
	mov cx,131
	rep movsw
	push ax
	push 131
	call calcScreenLoc
	mov [es:di],dx
	
	pop ds
	pop es
	pop dx
	pop cx
	pop bx
	pop di
	pop si
	pop ax
	pop bp
	ret 2
	
shiftbackgrounds:
	push bp
	mov bp,sp
	push ax
	push dx
	push bx
	push cx
	push es
	
	mov ax,0 ;to store height of each background
	mov al,[rows]
	mov dx,0
	mov dl,3
	div dl
	mov ah,0
	mov bx,0;store starting row
	
	mov ax,14
	inc bx
	;1st background
	firstbackgroundshift:
		push bx
		call shiftrowright
		inc bx
		cmp bx,ax
		jne firstbackgroundshift
	
	
	mov bx,ax
	inc bx
	shl ax,1
	;2nd background
	secondbackgroundshift:
		push bx
		call shiftrowleft
		inc bx
		cmp bx,ax
		jne secondbackgroundshift
	
	pop es
	pop cx
	pop bx
	pop dx
	pop ax
	pop bp
	ret 
	


delay:      
	push cx
	mov cx, 0xFFFF
	loop1:		
		loop loop1
		
	mov cx, 0xFFFF
	
	loop2:		
		loop loop2
		
	pop cx
	ret

printPlayerCharacter:;takes attribute byte, bottom middle row and col as parameters
	push bp
	mov bp,sp
	push ax
	push si
	push di
	push dx
	push cx
	
	mov si,[bp + 4] ;mid col
	mov di,[bp + 6] ;mid row
 	mov dx,[bp + 8] ;attribute byte
	
	sub di,1 ;get top of row of character
	sub si,3 ;get left column of character
	
	push di
	push si
	push 7
	push 2
	push dx
    call printRectangle
	
	mov di,[bp + 6];row
	mov si,[bp + 4];col
	
	
	sub di,2
	
	;left ear
	sub si,2
	push 201
	push dx
	push di
	push si
	call printpixel
	
	;right ear
	add si,4
	push 187
	push dx
	push di
	push si
	call printpixel
	
	;left eye
	add di,1
	sub si,3
	push 229
	push dx
	push di
	push si
	call printpixel
	
	;right eye
	add si,2
	push 229
	push dx
	push di
	push si
	call printpixel
	
	;mouth
	add di,1
	sub si,1
	push 205
	push dx
	push di
	push si
	call printpixel
	
	
	

	pop cx
	pop dx
	pop di
	pop si
	pop ax
	pop bp
	ret 6
	


printplatform: ;takes left most row and col of the platform as parameters
	push bp
	mov bp,sp
	push ax
	push si
	push di
	push dx
	push cx
	push bx
	
	mov si,[bp + 4] ;left most col
	mov di,[bp + 6] ;left most row
 	mov dx,[platformAttribute] ;attribute byte
	mov ax,0
	mov al,dl
	mov bx,0
	mov bl,dh
	
	
	mov cx,20 ;width of platform
	
	printplatformLoop:
		push ax
		push bx
		push di
		push si
		call printpixel
		inc si
		
		dec cx
		cmp cx,0
		jne printplatformLoop
	
	pop bx
	pop cx
	pop dx
	pop di
	pop si
	pop ax
	pop bp
	ret 4	

calcScreenLoc:;takes row and col number and saves in di
	push bp
	mov bp,sp
	push ax
	mov al,132
	mul byte [bp + 6]
	add ax,[bp + 4]
	shl ax,1
	
	mov di,ax
	
	pop ax
	pop bp
	ret 4


shiftnewplatform:
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push es
	push dx
	push si
	push di

	mov ax,0xb800
	mov es,ax
	mov cx,[newplatformspeedcounter]
	cmp word [newplatformspeedcounter],0
	je outofbound
	dec cx
	outofbound:
	cmp cx,0
	jne noshift
	mov cx,[resetplatformspeedcounter]
	cmp byte [platformshiftdirection],1
	je moveright
	moveleft:
		mov ax,[newplatformCol]
		push 35
		push ax
		call calcScreenLoc

		mov dx,[es:di]
		sub di,4
		
		mov bx,[es:di]
		add di,2
		mov [es:di],dx
		add di,40
		
		mov [es:di],bx
		sub di,40
		mov bx,di ; saves col of left most pixel of platform in bx
		push 35 ; row
		push 36 ;boundary col
		call calcScreenLoc
		sub word [newplatformCol],1
		cmp bx,di
		
		jne leftboundarynotreached
		mov byte[platformshiftdirection],1
		leftboundarynotreached:
		
		jmp noshift
	moveright:
		mov ax,[newplatformCol]
		add ax,19
		push 35
		push ax
		call calcScreenLoc

		mov dx,[es:di]
		add di,4
		
		mov bx,[es:di]
		sub di,2
		mov [es:di],dx
		sub di,40
		
		mov [es:di],bx
		add di,40
		mov bx,di ; saves col of right most pixel of platform in bx
		push 35 ; row
		push 96 ;boundary col
		call calcScreenLoc
		add word [newplatformCol],1
		cmp bx,di
		
		jne rightboundarynotreached
		mov byte[platformshiftdirection],0
		rightboundarynotreached:
		
		
	noshift:
	mov [newplatformspeedcounter],cx
	pop di
	pop si
	pop dx
	pop es
	pop cx
	pop bx
	pop ax
	pop bp
	ret
	
printMainScreen:
	call clrscreen
	call dividescreen
	
	push 0x33 ;color of top screen
	push 0x00 ;color of middle screen
	push 0x22 ;color of bottom screen
	call printAllBackgrounds
	
	push 1 ;starting row
	push 10 ; starting col
	push 15 ; width
	push 13 ; height
	push 01101111b ; colour
	call printbuilding
	
	push 1 ;starting row
	push 30 ; starting col
	push 15 ; width
	push 13 ; height
	push 01101111b ; colour
	call printbuilding
	
	push 1 ;starting row
	push 50 ; starting col
	push 15 ; width
	push 13 ; height
	push 01101111b ; colour
	call printbuilding
	
	push 1 ;starting row
	push 70 ; starting col
	push 15 ; width
	push 13 ; height
	push 01101111b ; colour
	call printbuilding
	
	push 1 ;starting row
	push 90 ; starting col
	push 15 ; width
	push 13 ; height
	push 01101111b ; colour
	call printbuilding
	
	push 1 ;starting row
	push 110 ; starting col
	push 15 ; width
	push 13 ; height
	push 01101111b ; colour
	call printbuilding
	
	; push 6
	; push 0x77
	; call printroadlines
	
	push 19
	push 10
	push 30
	push 6
	push 0x44
	call printcar ;takes the starting row, starting col, width, height and color of the car as parameters
	
	push 21
	push 100
	push 30
	push 6
	push 0x44
	call printcar
	
	push 23
	push 55
	push 30
	push 6
	push 0x44
	call printcar ;takes the starting row, starting col, width, height and color of the car as parameters
	
	push 01000000b
	push 40 ; playerrow
	push word [playerCol]
	call printPlayerCharacter
	

	push 41
	push word [oldplatformCol]
	call printplatform
	
	
	; push 35
	; ;push word [newplatformCol]
	; push word [newplatforminitialcol]
	call printnewplatform
	
	; push word 0x74
	; push word timertext
	; push word [timertextlength]
	; push word [timertextlocationrow]
	; push word [timertextlocationcol]
	; call printtext ;takes attribute byte, address of string,length of the string, row number,and col to print on as parameters 
	
	push word 0x74 ;takes attribute byte, address of string,length of the string, row number,and col to print on as parameters
	push word scoretext
	push word [scoretextlength]
	push word [scorelocationrow]
	push word [scorelocationcol]
	call printtext
	
	push word [score]
	push word [scorelocationrow]
	push word [scorelocationcol]
	call printnum ;printing score
	
	ret


removeOldPlatform:
	push ax
	push es
	push cx
	push di
	
	mov ax,0xB800
	mov es,ax
	mov cx,132
	push word [oldplatformRow]
	push 0
	call calcScreenLoc
	removeOldPlatformloop:
		mov word [es:di],0x2220
		add di,2
		loop removeOldPlatformloop
	pop di
	pop cx
	pop es
	pop ax
	ret


kbisr: 
	push ax
	push es
	

	in al,0x60
	cmp al,0x48 ;upkey
	jne compareESC
	mov byte [upkeypressed],1
	mov byte [platformshiftflag],0
	call removeOldPlatform
	call checkhay
	jmp nomatch
	
	compareESC:
	cmp al,0x1
	jne compareEnter
	;mov byte [terminateflag],1
	mov byte [pauseflag],1
	jmp nomatch
	
	compareEnter:
	cmp al,0x1c
	jne compareR
	cmp byte [terminateflag],1
	jne notend
	mov byte [endscreenflag],0
	notend:
	mov byte [introscreenflag],0
	jmp nomatch
	
	compareR:
	cmp byte [pauseflag],1
	jne nomatch
	
	
	cmp al,0x13
	jne compareE
	mov byte [resumeflag],1
	jmp nomatch
	
	compareE:
	cmp al,0x12
	jne nomatch
	mov byte [terminateflag],1
	
	nomatch:

	
	mov al, 0x20
	out 0x20, al ; end of interrupt
	pop es 
	pop ax
	iret




shiftdown: ; takes row number as input
	push bp
	mov bp,sp
	push ax
	push cx
	push es
	push si
	push di
	push bx

	mov ax,0xB800
	mov es,ax
	mov ax, [bp+4]
	push ax
	mov bx,[newplatformCol]
	push bx
	call calcScreenLoc
	mov si,di
	inc ax
	push ax
	mov bx, [newplatformCol]
	push bx
	call calcScreenLoc
	
	mov cx,0
	;mov cl,[cols]
	mov cl,20

	
	
	mov ax,[platformAttribute]
	
	shiftdownloop:
		
		 cmp word [es:di],0x2220
		 jne skipshiftdown1 ;does not copy platform to dest if dest does not contain background
		 ; cmp word [es:si],0x2220
		 ; je skipshiftdown1
		 mov word [es:di],ax
		 
		 
		 skipshiftdown1:
		 cmp word [es:si], ax
		 jne skipshiftdown2 ;does not copy background to source if source is not platform
		 mov word [es:si] , 0x2220
		 skipshiftdown2:
		
	
	
		
		
		
			add si,2
			add di,2
			
		loop shiftdownloop
	
	pop bx
	pop di
	pop si
	pop es
	pop cx
	pop ax
	pop bp
	ret 2
	
checklanding:
	push ax
	push cx
	push es
	push di
	push si

	mov cx,0
	mov ax,0xB800
	mov es,ax
	push word [playerRow]
	push word [playerCol]
	call calcScreenLoc
	sub di, 6
	add di,264
	mov ax,[platformAttribute]
	mov si,7
	checklandingloop:
		cmp [es:di],ax
		jne noplatformbelow
		inc cx
		noplatformbelow:
		add di,2
		dec si
		jnz checklandingloop
	
	cmp cx,2
	jge notterminate
	mov byte [terminateflag],1
	notterminate:
	
	pop si
	pop di
	pop es
	pop cx
	pop ax
	ret

printnewplatform:
	push ax
	push dx
	call randomisebrickcolour
	mov ax,[newplatformAttribute]
	mov [platformAttribute],ax
	
	call RANDGEN
	shl dl,2
	add dl,37
	mov dh,0
	mov [newplatforminitialcol],dx
	mov [newplatformCol],dx
	
	
	push word [newplatforminitialrow]
	push word [newplatforminitialcol]
	call printplatform
	mov word [tickcount],0
	pop dx
	pop ax
	ret

shiftoldplatformAndplayer:
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push es
	push dx
	push si
	push di
	
	

	mov ax,0xb800
	mov es,ax
	mov cx,[oldplatformspeedcounter]
	cmp word [oldplatformspeedcounter],0
	je outofbound1
	dec cx
	outofbound1:
	cmp cx,0
	jne noshift1
	mov cx,[resetplatformspeedcounter]
	cmp byte [oldplatformshiftdirection],1
	je moveright1
	moveleft1:
		mov ax,[oldplatformCol]
		push word [oldplatformRow]
		push ax
		call calcScreenLoc

		mov dx,[es:di]
		sub di,4
		
		mov bx,[es:di]
		add di,2
		mov [es:di],dx
		add di,40
		
		mov [es:di],bx
		sub di,40
		mov bx,di ; saves col of left most pixel of platform in bx
		
				
		mov ax,[playerRow]
		push ax
		call shiftrowleft
		dec ax
		push ax
		call shiftrowleft
		dec ax
		push ax
		call shiftrowleft
		sub word [playerCol],1
		
		push word [oldplatformRow] ; row
		push 36 ;boundary col
		call calcScreenLoc
		sub word [oldplatformCol],1
		cmp bx,di
		
		jne leftboundarynotreached1
		mov byte[oldplatformshiftdirection],1
		leftboundarynotreached1:
		
		jmp noshift1
	moveright1:
		mov ax,[oldplatformCol]
		add ax,19
		push word[oldplatformRow]
		push ax
		call calcScreenLoc

		mov dx,[es:di]
		add di,4
		
		mov bx,[es:di]
		sub di,2
		mov [es:di],dx
		sub di,40
		
		mov [es:di],bx
		add di,40
		mov bx,di ; saves col of left most pixel of platform in bx
		
				
		mov ax,[playerRow]
		push ax
		call shiftrowright
		dec ax
		push ax
		call shiftrowright
		dec ax
		push ax
		call shiftrowright
		add word [playerCol],1
		
		push word [oldplatformRow] ; row
		push 96 ;boundary col
		call calcScreenLoc
		add word [oldplatformCol],1
		cmp bx,di
		
		jne rightboundarynotreached1
		mov byte[oldplatformshiftdirection],0
		rightboundarynotreached1:
		
		
	noshift1:
	mov [oldplatformspeedcounter],cx
	pop di
	pop si
	pop dx
	pop es
	pop cx
	pop bx
	pop ax
	pop bp
	ret
	
RANDGEN:         ; generate a rand no using the system time and stores it in dl
	push ax
	push cx
	push bx
	

	cli
	mov ax, 0
	mov dx,0
	out 0x70, al ; command byte written at first port
	jmp D1 ; waste one instruction time
	D1: in al, 0x71 ; result of command is in AL now
	mov cx,10
	div cl
	mov dl,ah ;returns number in dl
	sti
	
	

	 pop bx
	 pop cx
	 pop ax
	
	ret
	
printhay: 
	push ax
	push dx
	;cmp byte [hayspawned],1
	;jne printhayskip
	

	mov ax,[hayrow]
	mov dx,[haycolumn]
	push word 205
	push word 0x0060
	push word ax
	push word dx
	call printpixel
	
	inc dx
	push word 205
	push word 0x0060
	push word ax
	push word dx
	call printpixel
	
	inc dx
	push word 205
	push word 0x0060
	push word ax
	push word dx
	call printpixel
	
	inc ax
	push word 205
	push word 0x0060
	push word ax
	push word dx
	call printpixel
	
	dec dx
	push word 205
	push word 0x0060
	push word ax
	push word dx
	call printpixel
	
	dec dx
	push word 205
	push word 0x0060
	push word ax
	push word dx
	call printpixel
	
	;printhayskip:
	
	pop dx
	pop ax
	ret

checkhay:
	push ax
	push es
	push dx
	push bx
	push cx
	push di

	
	mov ax,0xB800
	mov es,ax
	mov ax,[playerRow]
	mov dx,[playerCol]
	sub ax,3
	sub dx,3
	mov cx,7
	checkhayloop:
		push ax
		push dx
		call calcScreenLoc
		mov bx,[es:di]
		cmp bx, 0x60cd
		jne checkhayskip
		mov byte [haycollected],1
 		checkhayskip:
		inc dx
		loop checkhayloop
	
	cmp byte [haycollected],1
	jne notcollected
	mov byte [haycollected],0
	inc word [score]
	
	push word [score]
	push word [scorelocationrow]
	push word [scorelocationcol]
	call printnum ;printing score
	
	notcollected:
	mov ax,[hayrow]
	mov dx,[haycolumn] 
	push ax
	push dx
	push word 3
	push word 2
	push word 0x0022
	call printRectangle
	mov byte [hayspawned],0
	
	pop di
	pop cx
	pop bx
	pop dx
	pop es
	pop ax
	ret
	
randomhayspawning:
	push dx
	call RANDGEN
	cmp dl,5
	jl skiprandomhayspawning
	mov byte [hayspawned],1
	call RANDGEN
	
	shl dl,2
	add dl,46
	mov dh,0
	mov [haycolumn],dx
	
	call printhay
	
	
	skiprandomhayspawning:
	
	pop dx
	ret
	
randomisebrickcolour:
	push dx
	
	call RANDGEN
	cmp word [oldplatformAttribute],0x10ba
	jne randomisebrickstart2
	randomisebrickstart1:
	cmp dl,4
	jg orangebrickskip1
	mov word [newplatformAttribute],0x60ba ;orange brick
	jmp colourdecided
	orangebrickskip1:
	mov word [newplatformAttribute],0x50ba ; purple brick
	jmp colourdecided

	
		
	randomisebrickstart2:
	
	cmp dl,3
	jg orangebrickskip2
	mov word [newplatformAttribute],0x60ba ;orange brick
	jmp colourdecided
	orangebrickskip2:
	cmp dl,6
	jg purplebrickskip2
	mov word [newplatformAttribute],0x50ba ; purple brick
	jmp colourdecided
	purplebrickskip2:
	mov word [newplatformAttribute],0x10ba ;blue brick
	mov word [tickcount], 0
	colourdecided:
	
	pop dx
	ret

	
increaseplatformspeed:
	push ax
	push dx
	cmp word [resetplatformspeedcounter],0
	je skipincrease
	cmp word [score],0
	je skipincrease
	mov ax,[score]
	mov dl,2
	div dl
	cmp ah,1
	je skipincrease
	dec word [resetplatformspeedcounter]
	;dec word [newplatformspeedcounter]
	;dec word [oldplatformspeedcounter]
	skipincrease:
	pop dx
	pop ax
	ret

timer:		
	pusha
			
	inc word [cs:tickcount]; increment tick count
	cmp word [cs:tickcount], 54
	jne skiptimer
	cmp word [cs:oldplatformAttribute], 0x10ba
	jne skiptimer
	call removeOldPlatform
	mov byte [cs:terminateflag],1
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	call delay
	skiptimer:
	mov al, 0x20
	out 0x20, al ; end of interrupt4
	popa
	iret ; return from interrupt	


printnum: ; takes number , row and col as parameter 
	push bp
	mov bp,sp
	push es
	push ax
	push bx
	push cx
	push dx
	push di

	mov ax, 0xb800
	mov es, ax			; point es to video base

	mov ax, [bp+8]		; load number in ax= 4529
	mov bx, 10			; use base 10 for division
	mov cx, 0			; initialize count of digits
	
	nextdigit:		
		mov dx, 0			; zero upper half of dividend
		div bx				; divide by 10 AX/BX --> Quotient --> AX, Remainder --> DX ..... 
		add dl, 0x30		; convert digit into ascii value
		push dx				; save ascii value on stack

		inc cx				; increment count of values
		cmp ax, 0			; is the quotient zero
		jnz nextdigit		; if no divide it again

		push word [bp+6]
		push word [bp+4]
		call calcScreenLoc


	nextpos:		
		pop dx				; remove a digit from the stack
		mov dh, 0x74		; use normal attribute
		mov [es:di], dx		; print char on screen
		add di, 2			; move to next screen location
		loop nextpos		; repeat for all digits on stack

	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	pop bp
	ret 6
	

	
printtext: ;takes attribute byte, address of string,length of the string, row number,and col to print on as parameters
	push bp
	mov bp,sp
    push es
    push ax
    push di
    push cx
    push si

    mov ax,0xB800
    mov es,ax
	mov ax,[bp+6] ;row
	push ax
	mov ax, [bp+4] ; col
	push ax
	call calcScreenLoc
	mov ax,[bp+8]
	shl ax,1
	sub di,ax
    
    mov si,[bp+10] ;index of the string
    mov cx,[bp+8] ;length of the string
    mov ah,[bp+12];attribute byte

    nextchar:
        mov al,[si]
        mov [es:di],ax
        add si,1
        add di,2
        sub cx,1
        jnz nextchar


    pop si
    pop cx
    pop di
    pop ax
    pop es
	pop bp
 
    ret 10
	
printintroscreen:
	
	call clrscreen
	
	push word 3
	push word 15
	push word 102
	push word 37
	push word 0x40
	call printRectangle ;takes the starting row, starting col, width, height and color of the rectangle as parameters
	
	push word 4
	push word 16
	push word 100
	push word 35
	push word 0x70
	call printRectangle ;takes the starting row, starting col, width, height and color of the rectangle as parameters
	
	
	push word 0x70
	push word rollnum1text
	push word [rollnum1length]
	push word [rollnum1locationrow]
	push word [rollnum1locationcol]
	call printtext ;takes attribute byte, address of string,length of the string, row number,and col to print on as parameters
	
	
	
	push word 0x70
	push word rollnum2text
	push word [rollnum2length]
	push word [rollnum2locationrow]
	push word [rollnum2locationcol]
	call printtext
	
	push word 0x70
	push word introText
	push word [introTextlength]
	push word [introTextlocationrow]
	push word [introTextlocationcol]
	call printtext
	
	push word 0x70
	push word instructionText1
	push word [instructionText1length]
	push word [instructionText1locationrow]
	push word [instructionText1locationcol]
	call printtext
	
	push word 0x70
	push word instructionText2
	push word [instructionText2length]
	push word [instructionText2locationrow]
	push word [instructionText2locationcol]
	call printtext
	
	push word 0x70
	push word instructionText3
	push word [instructionText3length]
	push word [instructionText3locationrow]
	push word [instructionText3locationcol]
	call printtext
	
	push 01000000b
	push word 36
	push word 63
	call printPlayerCharacter;takes attribute byte, bottom middle row and col as parameters
	
	push word 37
	push word 54
	call printplatform ;takes left most row and col of the platform as parameters
	
	introloop:
		cmp byte [introscreenflag],1
		je introloop
	ret


pausegame:
	push ax
	push ds
	push es
	push si
	push di
	push dx
	push cx
	push bx
	
	;mov byte [pauseflag],1

	mov ax,0xB800
	mov bx,ds
	mov ds,ax

	mov es,bx
	push 16 ;row
	push 51 ;col
	call calcScreenLoc
	mov si,di
	mov di,buffer
	mov dx,10 ;rows
	
	cld
	copyloop1:
		mov cx,30 ; cols
		rep movsw
		
		sub si,60 ; go back to start
		add si,264 ; go down
		dec dx
		jnz copyloop1
	

	mov ds,bx ;reset ds
	
	push word 16
	push word 51
	push word 30
	push word 10
	push word 0x40
	call printRectangle ;takes the starting row, starting col, width, height and color of the rectangle as parameters
	
	push word 17
	push word 52
	push word 28
	push word 8
	push word 0x70
	call printRectangle ;takes the starting row, starting col, width, height and color of the rectangle as parameters
	
	push word 0x70
	push word pausescreen1text
	push word [pausescreen1length]
	push word [pausescreen1locationrow]
	push word [pausescreen1locationcol]
	call printtext ;takes attribute byte, address of string,length of the string, row number,and col to print on as parameters
	
	push word 0x70
	push word pausescreen2text
	push word [pausescreen2length]
	push word [pausescreen2locationrow]
	push word [pausescreen2locationcol]
	call printtext ;takes attribute byte, address of string,length of the string, row number,and col to print on as parameters
	
	push word 0x70
	push word pausescreen3text
	push word [pausescreen3length]
	push word [pausescreen3locationrow]
	push word [pausescreen3locationcol]
	call printtext ;takes attribute byte, address of string,length of the string, row number,and col to print on as parameters
	
	; call delay
	; call delay
		; call delay
	; call delay
		; call delay
	; call delay
	
	pauseloop:

		cmp byte [resumeflag],1
		je resumed
		cmp byte [terminateflag],1
		je endpause
		jmp pauseloop
	
	resumed:
		mov byte [resumeflag],0
	
	mov ax,0xb800
	mov es,ax
	push 16
	push 51
	call calcScreenLoc
	
	mov si,buffer
	mov dx,10 ;rows
	
	
	copyloop2:
		mov cx,30 ; cols
		rep movsw
		sub di,60 ; go back to start
		add di,264 ; go down
		dec dx
		jnz copyloop2
	


	
	
	
	
	
	endpause:
	
	mov ds,bx ;reset ds
	mov byte [pauseflag],0
	pop bx
	pop cx
	pop dx
	pop di
	pop si
	pop es
	pop ds
	pop ax
	
	ret
	
	
printendscreen:
	call clrscreen
	
	push word 16
	push word 51
	push word 30
	push word 10
	push word 0x10
	call printRectangle ;takes the starting row, starting col, width, height and color of the rectangle as parameters
	
	push word 17
	push word 52
	push word 28
	push word 8
	push word 0x70
	call printRectangle ;takes the starting row, starting col, width, height and color of the rectangle as parameters
	
	push word 0x70
	push word endscreentext
	push word [endscreenlength]
	push word [endscreenlocationrow]
	push word [endscreenlocationcol]
	call printtext ;takes attribute byte, address of string,length of the string, row number,and col to print on as parameters
	
	push word 0x70
	push word endscreen2text
	push word [endscreen2length]
	push word [endscreen2locationrow]
	push word [endscreen2locationcol]
	call printtext ;takes attribute byte, address of string,length of the string, row number,and col to print on as parameters
	
	
	
	mov word [scorelocationrow],21
	mov word [scorelocationcol], 67
	
	push word 0x70 ;takes attribute byte, address of string,length of the string, row number,and col to print on as parameters
	push word scoretext
	push word [scoretextlength]
	push word [scorelocationrow]
	push word [scorelocationcol]
	call printtext
	
	push word [score]
	push word [scorelocationrow]
	push word [scorelocationcol]
	call printnum ;printing score
	
	endscreenloop:
		cmp byte [endscreenflag],1
		je endscreenloop
	
	call clrscreen
	ret
	
start:

	; following code just changes your screen resolution to 43x132 Mode
	mov ah,0x00
	mov al, 0x54
	int 0x10
	


	xor ax, ax
	mov es, ax ; point es to IVT base
	mov ax, [es:9*4]
	mov [oldisr], ax ; save offset of old routine
	mov ax, [es:9*4+2]
	mov [oldisr+2], ax ; save segment of old routine
	cli ; disable interrupts
	mov word [es:9*4], kbisr ; store offset at n*4
	mov [es:9*4+2], cs ; store segment at n*4+2
	sti
	
	mov ax, [es:8*4]
	mov [oldtimer], ax ; save offset of old routine
	mov ax, [es:8*4+2]
	mov [oldtimer+2], ax ; save segment of old routine
	cli ; disable interrupts
	mov word [es:8*4], timer; store offset at n*4
	mov [es:8*4+2], cs ; store segment at n*4+2
	sti ; enable interrupts
	
	

	
	; mov ax,0x19f5
	; mov es,ax
	
	
	call printintroscreen
	
	call printMainScreen
	
	mov ax,[newplatforminitialcol]
	mov [newplatformCol],ax
	shift:
		cmp byte [pauseflag],1
		jne notpaused
			call pausegame
		notpaused:
		cli
		call shiftbackgrounds
		;call printhay
		
		; push word [score]
		; push word [scorelocationrow]
		; push word [scorelocationcol]
		; call printnum ;printing score
		

		sti
		cmp byte [platformshiftflag],0
		je skipplatformshift
		cmp word [newplatformAttribute],0x10ba
		je skipnewshift
		call shiftnewplatform
		skipnewshift:
		cmp word [oldplatformAttribute],0x10ba
		je skipoldshift
		call shiftoldplatformAndplayer
		skipoldshift:
		skipplatformshift:
		
		call delay
		
	

		cmp byte [upkeypressed] ,1
		jne upnotpressed
			
			push word [newplatformRow]
			call shiftdown
			inc word [newplatformRow]
			mov ax,[newplatformRow]
			cmp [oldplatformRow],ax
			jne jumping
			mov byte [upkeypressed],0
			mov word [newplatformRow],35
			mov  ax,[newplatformCol]
			mov [oldplatformCol],ax
			mov ax,[newplatforminitialcol]
			mov [newplatformCol],ax
			mov ax, [newplatformAttribute]
			mov [oldplatformAttribute],ax
			mov byte [platformshiftflag],1
			call delay
			call delay
			call delay
			call delay
			call checklanding
			
			;call printnewplatform
			call randomhayspawning
			call increaseplatformspeed
			;mov word [tickcount],0
			call printnewplatform

			
			jumping:
			
		upnotpressed:
		
		cmp byte [terminateflag],1
		jne shift
		call printendscreen
		
	xor ax, ax
	mov es, ax
	
	;unhooking kb	
	mov ax, [oldisr] ; read old offset in ax
	mov bx, [oldisr+2] ; read old segment in bx

	cli ; disable interrupts
	mov [es:9*4], ax ; restore old offset from ax
	mov [es:9*4+2], bx ; restore old segment from bx
	sti
	
	;unhooking timer
	mov ax, [oldtimer] ; read old offset in ax
	mov bx, [oldtimer+2] ; read old segment in bx

	cli ; disable interrupts
	mov [es:8*4], ax ; restore old offset from ax
	mov [es:8*4+2], bx ; restore old segment from bx
	sti
	


terminate:
	MOV		AX, 0x4C00
	INT		0x21