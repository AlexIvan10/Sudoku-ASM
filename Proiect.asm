.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Sudoku",0
area_width EQU 1200
area_height EQU 800
area DD 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

button_size EQU 60

nr db 3, 2, 0, 0, 0, 0, 0, 0, 0
   db 0, 0, 0, 0, 0, 0, 0, 0, 0
   db 0, 0, 0, 0, 0, 0, 0, 6, 0
   db 0, 0, 0, 0, 0, 0, 0, 0, 0
   db 0, 0, 0, 0, 0, 0, 0, 0, 0
   db 0, 0, 0, 0, 0, 0, 0, 0, 0
   db 0, 0, 0, 0, 1, 0, 0, 0, 9
   db 0, 0, 0, 0, 0, 0, 0, 0, 0
   db 0, 5, 0, 0, 0, 0, 7, 0, 3
   
nrCopy db 3, 2, 0, 0, 0, 0, 0, 0, 0
   db 0, 0, 0, 0, 0, 0, 0, 0, 0
   db 0, 0, 0, 0, 0, 0, 0, 6, 0
   db 0, 0, 0, 0, 0, 0, 0, 0, 0
   db 0, 0, 0, 0, 0, 0, 0, 0, 0
   db 0, 0, 0, 0, 0, 0, 0, 0, 0
   db 0, 0, 0, 0, 1, 0, 0, 0, 9
   db 0, 0, 0, 0, 0, 0, 0, 0, 0
   db 0, 5, 0, 0, 0, 0, 7, 0, 3
   
trei dd 3
douazecisisapte dd 27
   
.code
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

line_horizontal macro x, y, len, color
local bucla_line
	mov eax, y ; EAX = y
	mov ebx, area_width
	mul ebx ; EAX = y * area_width 
	add eax, x ; EAX = y * area_width + x
	shl eax, 2 ; EAX = (y * area_width + x) * 4
	add eax, area
	mov ecx, len
bucla_line:
		mov dword ptr[eax], color
		add eax, 4
	loop bucla_line
endm

line_vertical macro x, y, len, color
local bucla_line
	mov eax, y ; EAX = y
	mov ebx, area_width
	mul ebx ; EAX = y * area_width 
	add eax, x ; EAX = y * area_width + x
	shl eax, 2 ; EAX = (y * area_width + x) * 4
	add eax, area
	mov ecx, len
bucla_line:
		mov dword ptr[eax], color
		add eax, area_width * 4
	loop bucla_line
endm

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

make_button macro x, y, len
	line_horizontal x, y, len, 0
	line_horizontal x, y + len, len, 0
	line_vertical x, y, len, 0
	line_vertical x + len, y, len, 0
endm

colorwhite macro x, y
	line_vertical x+31, y+1, 58, 0FFFFFFh
	line_vertical x+32, y+1, 58, 0FFFFFFh
	line_vertical x+33, y+1, 58, 0FFFFFFh
	line_vertical x+34, y+1, 58, 0FFFFFFh
	line_vertical x+35, y+1, 58, 0FFFFFFh
	line_vertical x+36, y+1, 58, 0FFFFFFh
	line_vertical x+37, y+1, 58, 0FFFFFFh
	line_vertical x+38, y+1, 58, 0FFFFFFh
	line_vertical x+39, y+1, 58, 0FFFFFFh
endm

verify_button macro x, y, i, j
local scrie1, scrie2, scrie3, scrie4, scrie5, scrie6, scrie7, scrie8, scrie9, verify_next
	cmp nr[i][j], 0
	jne scrie1
	colorwhite x, y
	jmp verify_next
scrie1:
	cmp nr[i][j], 1
	jne scrie2
	make_text_macro '1', area, x + button_size/2, y + button_size/2
	jmp verify_next
scrie2:
	cmp nr[i][j], 2
	jne scrie3
	make_text_macro '2', area, x + button_size/2, y + button_size/2
	jmp verify_next
scrie3:
	cmp nr[i][j], 3
	jne scrie4
	make_text_macro '3', area, x + button_size/2, y + button_size/2
	jmp verify_next
scrie4:
	cmp nr[i][j], 4
	jne scrie5
	make_text_macro '4', area, x + button_size/2, y + button_size/2
	jmp verify_next
scrie5:
	cmp nr[i][j], 5
	jne scrie6
	make_text_macro '5', area, x + button_size/2, y + button_size/2
	jmp verify_next
scrie6:
	cmp nr[i][j], 6
	jne scrie7
	make_text_macro '6', area, x + button_size/2, y + button_size/2
	jmp verify_next
scrie7:
	cmp nr[i][j], 7
	jne scrie8
	make_text_macro '7', area, x + button_size/2, y + button_size/2
	jmp verify_next
scrie8:
	cmp nr[i][j], 8
	jne scrie9
	make_text_macro '8', area, x + button_size/2, y + button_size/2
	jmp verify_next
scrie9:
	cmp nr[i][j], 9
	jne verify_next
	make_text_macro '9', area, x + button_size/2, y + button_size/2
verify_next:
endm

verify_buttonreset macro
local
	push eax
	mov al, nrCopy[0][0]
	mov nr[0][0], al
	mov al, nrCopy[0][1]
	mov nr[0][1], al
	mov al, nrCopy[0][2]
	mov nr[0][2], al
	mov al, nrCopy[0][3]
	mov nr[0][3], al
	mov al, nrCopy[0][4]
	mov nr[0][4], al
	mov al, nrCopy[0][5]
	mov nr[0][5], al
	mov al, nrCopy[0][6]
	mov nr[0][6], al
	mov al, nrCopy[0][7]
	mov nr[0][7], al
	mov al, nrCopy[0][8]
	mov nr[0][8], al
	
	mov al, nrCopy[9][0]
	mov nr[9][0], al
	mov al, nrCopy[9][1]
	mov nr[9][1], al
	mov al, nrCopy[9][2]
	mov nr[9][2], al
	mov al, nrCopy[9][3]
	mov nr[9][3], al
	mov al, nrCopy[9][4]
	mov nr[9][4], al
	mov al, nrCopy[9][5]
	mov nr[9][5], al
	mov al, nrCopy[9][6]
	mov nr[9][6], al
	mov al, nrCopy[9][7]
	mov nr[9][7], al
	mov al, nrCopy[9][8]
	mov nr[9][8], al
	
	mov al, nrCopy[18][0]
	mov nr[18][0], al
	mov al, nrCopy[18][1]
	mov nr[18][1], al
	mov al, nrCopy[18][2]
	mov nr[18][2], al
	mov al, nrCopy[18][3]
	mov nr[18][3], al
	mov al, nrCopy[18][4]
	mov nr[18][4], al
	mov al, nrCopy[18][5]
	mov nr[18][5], al
	mov al, nrCopy[18][6]
	mov nr[18][6], al
	mov al, nrCopy[18][7]
	mov nr[18][7], al
	mov al, nrCopy[18][8]
	mov nr[18][8], al
	
	mov al, nrCopy[27][0]
	mov nr[27][0], al
	mov al, nrCopy[27][1]
	mov nr[27][1], al
	mov al, nrCopy[27][2]
	mov nr[27][2], al
	mov al, nrCopy[27][3]
	mov nr[27][3], al
	mov al, nrCopy[27][4]
	mov nr[27][4], al
	mov al, nrCopy[27][5]
	mov nr[27][5], al
	mov al, nrCopy[27][6]
	mov nr[27][6], al
	mov al, nrCopy[27][7]
	mov nr[27][7], al
	mov al, nrCopy[27][8]
	mov nr[27][8], al
	
	mov al, nrCopy[36][0]
	mov nr[36][0], al
	mov al, nrCopy[36][1]
	mov nr[36][1], al
	mov al, nrCopy[36][2]
	mov nr[36][2], al
	mov al, nrCopy[36][3]
	mov nr[36][3], al
	mov al, nrCopy[36][4]
	mov nr[36][4], al
	mov al, nrCopy[36][5]
	mov nr[36][5], al
	mov al, nrCopy[36][6]
	mov nr[36][6], al
	mov al, nrCopy[36][7]
	mov nr[36][7], al
	mov al, nrCopy[36][8]
	mov nr[36][8], al
	
	mov al, nrCopy[45][0]
	mov nr[45][0], al
	mov al, nrCopy[45][1]
	mov nr[45][1], al
	mov al, nrCopy[45][2]
	mov nr[45][2], al
	mov al, nrCopy[45][3]
	mov nr[45][3], al
	mov al, nrCopy[45][4]
	mov nr[45][4], al
	mov al, nrCopy[45][5]
	mov nr[45][5], al
	mov al, nrCopy[45][6]
	mov nr[45][6], al
	mov al, nrCopy[45][7]
	mov nr[45][7], al
	mov al, nrCopy[45][8]
	mov nr[45][8], al
	
	mov al, nrCopy[54][0]
	mov nr[54][0], al
	mov al, nrCopy[54][1]
	mov nr[54][1], al
	mov al, nrCopy[54][2]
	mov nr[54][2], al
	mov al, nrCopy[54][3]
	mov nr[54][3], al
	mov al, nrCopy[54][4]
	mov nr[54][4], al
	mov al, nrCopy[54][5]
	mov nr[54][5], al
	mov al, nrCopy[54][6]
	mov nr[54][6], al
	mov al, nrCopy[54][7]
	mov nr[54][7], al
	mov al, nrCopy[54][8]
	mov nr[54][8], al
	
	mov al, nrCopy[63][0]
	mov nr[63][0], al
	mov al, nrCopy[63][1]
	mov nr[63][1], al
	mov al, nrCopy[63][2]
	mov nr[63][2], al
	mov al, nrCopy[63][3]
	mov nr[63][3], al
	mov al, nrCopy[63][4]
	mov nr[63][4], al
	mov al, nrCopy[63][5]
	mov nr[63][5], al
	mov al, nrCopy[63][6]
	mov nr[63][6], al
	mov al, nrCopy[63][7]
	mov nr[63][7], al
	mov al, nrCopy[63][8]
	mov nr[63][8], al
	
	mov al, nrCopy[72][0]
	mov nr[72][0], al
	mov al, nrCopy[72][1]
	mov nr[72][1], al
	mov al, nrCopy[72][2]
	mov nr[72][2], al
	mov al, nrCopy[72][3]
	mov nr[72][3], al
	mov al, nrCopy[72][4]
	mov nr[72][4], al
	mov al, nrCopy[72][5]
	mov nr[72][5], al
	mov al, nrCopy[72][6]
	mov nr[72][6], al
	mov al, nrCopy[72][7]
	mov nr[72][7], al
	mov al, nrCopy[72][8]
	mov nr[72][8], al

	pop eax
endm

reset macro
	local line1reset,  line2reset, line3reset, line4reset, line5reset, line6reset, line7reset, line8reset, line9reset
	verify_buttonreset
line1reset:
	verify_button 100, 50, 0, 0
	verify_button 160, 50, 0, 1
	verify_button 220, 50, 0, 2
	verify_button 300, 50, 0, 3
	verify_button 360, 50, 0, 4
	verify_button 420, 50, 0, 5
	verify_button 500, 50, 0, 6
	verify_button 560, 50, 0, 7
	verify_button 620, 50, 0, 8
line2reset:
	verify_button 100, 110, 9, 0
	verify_button 160, 110, 9, 1
	verify_button 220, 110, 9, 2
	verify_button 300, 110, 9, 3
	verify_button 360, 110, 9, 4
	verify_button 420, 110, 9, 5
	verify_button 500, 110, 9, 6
	verify_button 560, 110, 9, 7
	verify_button 620, 110, 9, 8
line3reset:
	verify_button 100, 170, 18, 0
	verify_button 160, 170, 18, 1
	verify_button 220, 170, 18, 2
	verify_button 300, 170, 18, 3
	verify_button 360, 170, 18, 4
	verify_button 420, 170, 18, 5
	verify_button 500, 170, 18, 6
	verify_button 560, 170, 18, 7
	verify_button 620, 170, 18, 8
line4reset:
	verify_button 100, 250, 27, 0
	verify_button 160, 250, 27, 1
	verify_button 220, 250, 27, 2
	verify_button 300, 250, 27, 3
	verify_button 360, 250, 27, 4
	verify_button 420, 250, 27, 5
	verify_button 500, 250, 27, 6
	verify_button 560, 250, 27, 7
	verify_button 620, 250, 27, 8
line5reset:
	verify_button 100, 310, 36, 0
	verify_button 160, 310, 36, 1
	verify_button 220, 310, 36, 2
	verify_button 300, 310, 36, 3
	verify_button 360, 310, 36, 4
	verify_button 420, 310, 36, 5
	verify_button 500, 310, 36, 6
	verify_button 560, 310, 36, 7
	verify_button 620, 310, 36, 8
line6reset:
	verify_button 100, 370, 45, 0
	verify_button 160, 370, 45, 1
	verify_button 220, 370, 45, 2
	verify_button 300, 370, 45, 3
	verify_button 360, 370, 45, 4
	verify_button 420, 370, 45, 5
	verify_button 500, 370, 45, 6
	verify_button 560, 370, 45, 7
	verify_button 620, 370, 45, 8
line7reset:
	verify_button 100, 450, 54, 0
	verify_button 160, 450, 54, 1
	verify_button 220, 450, 54, 2
	verify_button 300, 450, 54, 3
	verify_button 360, 450, 54, 4
	verify_button 420, 450, 54, 5
	verify_button 500, 450, 54, 6
	verify_button 560, 450, 54, 7
	verify_button 620, 450, 54, 8
line8reset:
	verify_button 100, 510, 63, 0
	verify_button 160, 510, 63, 1
	verify_button 220, 510, 63, 2
	verify_button 300, 510, 63, 3
	verify_button 360, 510, 63, 4
	verify_button 420, 510, 63, 5
	verify_button 500, 510, 63, 6
	verify_button 560, 510, 63, 7
	verify_button 620, 510, 63, 8
line9reset:
	verify_button 100, 570, 72, 0
	verify_button 160, 570, 72, 1
	verify_button 220, 570, 72, 2
	verify_button 300, 570, 72, 3
	verify_button 360, 570, 72, 4
	verify_button 420, 570, 72, 5
	verify_button 500, 570, 72, 6
	verify_button 560, 570, 72, 7
	verify_button 620, 570, 72, 8
endm

valid_number macro i, j
local wrong, right, final, lin0, lin1, lin2, lin3, lin4, lin5, lin6, lin7, lin8, col0, col1, col2, col3, col4, col5, col6, col7, col8, pat0, pat1, pat2, pat3, pat4, pat5, pat6, pat7, pat8
	push ebx
	mov bl, nr[i][j]
	
	mov ecx, j
lin0:
	cmp ecx, 0
	je lin1
	cmp bl, nr[i][0]
	je wrong
lin1:
	cmp ecx, 1
	je lin2
	cmp bl, nr[i][1]
	je wrong
lin2:
	cmp ecx, 2
	je lin3
	cmp bl, nr[i][2]
	je wrong
lin3:
	cmp ecx, 3
	je lin4
	cmp bl, nr[i][3]
	je wrong
lin4:
	cmp ecx, 4
	je lin5
	cmp bl, nr[i][4]
	je wrong
lin5:
	cmp ecx, 5
	je lin6
	cmp bl, nr[i][5]
	je wrong
lin6:
	cmp ecx, 6
	je lin7
	cmp bl, nr[i][6]
	je wrong
lin7:
	cmp ecx, 7
	je lin8
	cmp bl, nr[i][7]
	je wrong
lin8:
	cmp ecx, 8
	je col0
	cmp bl, nr[i][8]
	je wrong

col0:
	mov ecx, i
	cmp ecx, 0
	je col1
	cmp bl, nr[0][j]
	je wrong
col1:
	cmp ecx, 9
	je col2
	cmp bl, nr[9][j]
	je wrong
col2:
	cmp ecx, 18
	je col3
	cmp bl, nr[18][j]
	je wrong
col3:
	cmp ecx, 27
	je col4
	cmp bl, nr[27][j]
	je wrong
col4:
	cmp ecx, 36
	je col5
	cmp bl, nr[36][j]
	je wrong
col5:
	cmp ecx, 45
	je col6
	cmp bl, nr[45][j]
	je wrong
col6:
	cmp ecx, 54
	je col7
	cmp bl, nr[54][j]
	je wrong
col7:
	cmp ecx, 63
	je col8
	cmp bl, nr[63][j]
	je wrong
col8:
	cmp ecx, 72
	je pat0
	cmp bl, nr[72][j]
	je wrong

pat0:
	push esi
	mov esi, douazecisisapte
	mov edx, 0
	mov eax, i
	div esi
	mov eax, i
	sub eax, edx
	mov ecx, eax
	mov edx, 0
	mov eax, j
	div trei
	mov eax, j
	sub eax, edx
	mov edx, eax
	pop esi

	cmp ecx, i
	je pat1
	cmp eax, j
	je pat1
	cmp bl, nr[ecx][eax]
	je wrong
	
pat1:
	inc eax
	cmp ecx, i
	je pat2
	cmp eax, j
	je pat2
	cmp bl, nr[ecx][eax]
	je wrong
	
pat2:
	inc eax
	cmp ecx, i
	je pat3
	cmp eax, j
	je pat3
	cmp bl, nr[ecx][eax]
	je wrong
	
pat3:
	mov eax, edx
	add ecx, 9
	cmp ecx, i
	je pat4
	cmp eax, j
	je pat4
	cmp bl, nr[ecx][eax]
	je wrong

pat4:
	inc eax
	cmp ecx, i
	je pat5
	cmp eax, j
	je pat5
	cmp bl, nr[ecx][eax]
	je wrong

pat5:
	inc eax
	cmp ecx, i
	je pat6
	cmp eax, j
	je pat6
	cmp bl, nr[ecx][eax]
	je wrong

pat6:
	mov eax, edx
	add ecx, 9
	cmp ecx, i
	je pat7
	cmp eax, j
	je pat7
	cmp bl, nr[ecx][eax]
	je wrong

pat7:
	inc eax
	cmp ecx, i
	je pat8
	cmp eax, j
	je pat8
	cmp bl, nr[ecx][eax]
	je wrong

pat8:
	inc eax
	cmp ecx, i
	je right
	cmp eax, j
	je right
	cmp bl, nr[ecx][eax]
	je wrong

	jmp right
	
wrong:
	mov dl, 0
	jmp final
right:
	mov dl, 1
final:
	pop ebx
endm

count_button macro x, y, i, j
local numnr0, numnr1, numnr2, numnr3, numnr4, numnr5, numnr6, numnr7, numnr8, numnr9
	mov al, nr[i][j]
	cmp al, 0
	je numnr0
	cmp al, 1
	je numnr1
	cmp al, 2
	je numnr2
	cmp al, 3
	je numnr3
	cmp al, 4
	je numnr4
	cmp al, 5
	je numnr5
	cmp al, 6
	je numnr6
	cmp al, 7
	je numnr7
	cmp al, 8
	je numnr8
	cmp al, 9
	je numnr9
numnr0:
	mov nr[i][j], 1
	valid_number i, j
	cmp dl, 0
	je numnr1
	make_text_macro '1', area, x + button_size/2, y + button_size/2
	jmp fail
numnr1:
	mov nr[i][j], 2 
	valid_number i, j
	cmp dl, 0
	je numnr2
	make_text_macro '2', area, x + button_size/2, y + button_size/2
	jmp fail
numnr2:
	mov nr[i][j], 3
	valid_number i, j
	cmp dl, 0
	je numnr3
	make_text_macro '3', area, x + button_size/2, y + button_size/2
	jmp fail
numnr3:
	mov nr[i][j], 4
	valid_number i, j
	cmp dl, 0
	je numnr4
	make_text_macro '4', area, x + button_size/2, y + button_size/2
	jmp fail
numnr4:
	mov nr[i][j], 5
	valid_number i, j
	cmp dl, 0
	je numnr5
	make_text_macro '5', area, x + button_size/2, y + button_size/2
	jmp fail
numnr5:
	mov nr[i][j], 6
	valid_number i, j
	cmp dl, 0
	je numnr6
	make_text_macro '6', area, x + button_size/2, y + button_size/2
	jmp fail
numnr6:
	mov nr[i][j], 7
	valid_number i, j
	cmp dl, 0
	je numnr7
	make_text_macro '7', area, x + button_size/2, y + button_size/2
	jmp fail
numnr7:
	mov nr[i][j], 8
	valid_number i, j
	cmp dl, 0
	je numnr8
	make_text_macro '8', area, x + button_size/2, y + button_size/2
	jmp fail
numnr8:
	mov nr[i][j], 9
	valid_number i, j
	cmp dl, 0
	je numnr9
	make_text_macro '9', area, x + button_size/2, y + button_size/2
	jmp fail
numnr9:
	mov nr[i][j], 0
	jmp fail
endm


draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:

patrat_1:
	mov eax, [ebp+arg2]
	cmp eax, 101
	jl patrat_2
	cmp eax, 99 + button_size
	jg patrat_2
	mov eax, [ebp+arg3]
	cmp eax, 51
	jl patrat_2
	cmp eax, 49 + button_size
	jg patrat_2
	count_button 100, 50, 0, 0
	
patrat_2:
	mov eax, [ebp+arg2]
	cmp eax, 161
	jl patrat_3
	cmp eax, 159 + button_size
	jg patrat_3
	mov eax, [ebp+arg3]
	cmp eax, 51
	jl patrat_3
	cmp eax, 49 + button_size
	jg patrat_3
	count_button 160, 50, 0, 1

patrat_3:
	mov eax, [ebp+arg2]
	cmp eax, 221
	jl patrat_4
	cmp eax, 219 + button_size
	jg patrat_4
	mov eax, [ebp+arg3]
	cmp eax, 51
	jl patrat_4
	cmp eax, 49 + button_size
	jg patrat_4
	count_button 220, 50, 0, 2
	
patrat_4:
	mov eax, [ebp+arg2]
	cmp eax, 301
	jl patrat_5
	cmp eax, 299 + button_size
	jg patrat_5
	mov eax, [ebp+arg3]
	cmp eax, 51
	jl patrat_5
	cmp eax, 49 + button_size
	jg patrat_5
	count_button 300, 50, 0, 3
	
patrat_5:
	mov eax, [ebp+arg2]
	cmp eax, 361
	jl patrat_6
	cmp eax, 359 + button_size
	jg patrat_6
	mov eax, [ebp+arg3]
	cmp eax, 51
	jl patrat_6
	cmp eax, 49 + button_size
	jg patrat_6
	count_button 360, 50, 0, 4

patrat_6:
	mov eax, [ebp+arg2]
	cmp eax, 421
	jl patrat_7
	cmp eax, 419 + button_size
	jg patrat_7
	mov eax, [ebp+arg3]
	cmp eax, 51
	jl patrat_7
	cmp eax, 49 + button_size
	jg patrat_7
	count_button 420, 50, 0, 5
	
patrat_7:
	mov eax, [ebp+arg2]
	cmp eax, 501
	jl patrat_8
	cmp eax, 499 + button_size
	jg patrat_8
	mov eax, [ebp+arg3]
	cmp eax, 51
	jl patrat_8
	cmp eax, 49 + button_size
	jg patrat_8
	count_button 500, 50, 0, 6
	
patrat_8:
	mov eax, [ebp+arg2]
	cmp eax, 561
	jl patrat_9
	cmp eax, 559 + button_size
	jg patrat_9
	mov eax, [ebp+arg3]
	cmp eax, 51
	jl patrat_9
	cmp eax, 49 + button_size
	jg patrat_9
	count_button 560, 50, 0, 7

patrat_9:
	mov eax, [ebp+arg2]
	cmp eax, 621
	jl patrat_10
	cmp eax, 619 + button_size
	jg patrat_10
	mov eax, [ebp+arg3]
	cmp eax, 51
	jl patrat_10
	cmp eax, 49 + button_size
	jg patrat_10
	count_button 620, 50, 0, 8

patrat_10:
	mov eax, [ebp+arg2]
	cmp eax, 101
	jl patrat_11
	cmp eax, 99 + button_size
	jg patrat_11
	mov eax, [ebp+arg3]
	cmp eax, 111
	jl patrat_11
	cmp eax, 109 + button_size
	jg patrat_11
	count_button 100, 110, 9, 0
	
patrat_11:
	mov eax, [ebp+arg2]
	cmp eax, 161
	jl patrat_12
	cmp eax, 159 + button_size
	jg patrat_12
	mov eax, [ebp+arg3]
	cmp eax, 111
	jl patrat_12
	cmp eax, 109 + button_size
	jg patrat_12
	count_button 160, 110, 9, 1

patrat_12:
	mov eax, [ebp+arg2]
	cmp eax, 221
	jl patrat_13
	cmp eax, 219 + button_size
	jg patrat_13
	mov eax, [ebp+arg3]
	cmp eax, 111
	jl patrat_13
	cmp eax, 109 + button_size
	jg patrat_13
	count_button 220, 110, 9, 2
	
patrat_13:
	mov eax, [ebp+arg2]
	cmp eax, 301
	jl patrat_14
	cmp eax, 299 + button_size
	jg patrat_14
	mov eax, [ebp+arg3]
	cmp eax, 111
	jl patrat_14
	cmp eax, 109 + button_size
	jg patrat_14
	count_button 300, 110, 9, 3
	
patrat_14:
	mov eax, [ebp+arg2]
	cmp eax, 361
	jl patrat_15
	cmp eax, 359 + button_size
	jg patrat_15
	mov eax, [ebp+arg3]
	cmp eax, 111
	jl patrat_15
	cmp eax, 109 + button_size
	jg patrat_15
	count_button 360, 110, 9, 4

patrat_15:
	mov eax, [ebp+arg2]
	cmp eax, 421
	jl patrat_16
	cmp eax, 419 + button_size
	jg patrat_16
	mov eax, [ebp+arg3]
	cmp eax, 111
	jl patrat_16
	cmp eax, 109 + button_size
	jg patrat_16
	count_button 420, 110, 9, 5
	
patrat_16:
	mov eax, [ebp+arg2]
	cmp eax, 501
	jl patrat_17
	cmp eax, 499 + button_size
	jg patrat_17
	mov eax, [ebp+arg3]
	cmp eax, 111
	jl patrat_17
	cmp eax, 109 + button_size
	jg patrat_17
	count_button 500, 110, 9, 6
	
patrat_17:
	mov eax, [ebp+arg2]
	cmp eax, 561
	jl patrat_18
	cmp eax, 559 + button_size
	jg patrat_18
	mov eax, [ebp+arg3]
	cmp eax, 111
	jl patrat_18
	cmp eax, 109 + button_size
	jg patrat_18
	count_button 560, 110, 9, 7

patrat_18:
	mov eax, [ebp+arg2]
	cmp eax, 621
	jl patrat_19
	cmp eax, 619 + button_size
	jg patrat_19
	mov eax, [ebp+arg3]
	cmp eax, 111
	jl patrat_19
	cmp eax, 109 + button_size
	jg patrat_19
	count_button 620, 110, 9, 8

patrat_19:
	mov eax, [ebp+arg2]
	cmp eax, 101
	jl patrat_20
	cmp eax, 99 + button_size
	jg patrat_20
	mov eax, [ebp+arg3]
	cmp eax, 171
	jl patrat_20
	cmp eax, 169 + button_size
	jg patrat_20
	count_button 100, 170, 18, 0
	
patrat_20:
	mov eax, [ebp+arg2]
	cmp eax, 161
	jl patrat_21
	cmp eax, 159 + button_size
	jg patrat_21
	mov eax, [ebp+arg3]
	cmp eax, 171
	jl patrat_21
	cmp eax, 169 + button_size
	jg patrat_21
	count_button 160, 170, 18, 1

patrat_21:
	mov eax, [ebp+arg2]
	cmp eax, 221
	jl patrat_22
	cmp eax, 219 + button_size
	jg patrat_22
	mov eax, [ebp+arg3]
	cmp eax, 171
	jl patrat_22
	cmp eax, 169 + button_size
	jg patrat_22
	count_button 220, 170, 18, 2
	
patrat_22:
	mov eax, [ebp+arg2]
	cmp eax, 301
	jl patrat_23
	cmp eax, 299 + button_size
	jg patrat_23
	mov eax, [ebp+arg3]
	cmp eax, 171
	jl patrat_23
	cmp eax, 169 + button_size
	jg patrat_23
	count_button 300, 170, 18, 3
	
patrat_23:
	mov eax, [ebp+arg2]
	cmp eax, 361
	jl patrat_24
	cmp eax, 359 + button_size
	jg patrat_24
	mov eax, [ebp+arg3]
	cmp eax, 171
	jl patrat_24
	cmp eax, 169 + button_size
	jg patrat_24
	count_button 360, 170, 18, 4

patrat_24:
	mov eax, [ebp+arg2]
	cmp eax, 421
	jl patrat_25
	cmp eax, 419 + button_size
	jg patrat_25
	mov eax, [ebp+arg3]
	cmp eax, 171
	jl patrat_25
	cmp eax, 169 + button_size
	jg patrat_25
	count_button 420, 170, 18, 5
	
patrat_25:
	mov eax, [ebp+arg2]
	cmp eax, 501
	jl patrat_26
	cmp eax, 499 + button_size
	jg patrat_26
	mov eax, [ebp+arg3]
	cmp eax, 171
	jl patrat_26
	cmp eax, 169 + button_size
	jg patrat_26
	count_button 500, 170, 18, 6
	
patrat_26:
	mov eax, [ebp+arg2]
	cmp eax, 561
	jl patrat_27
	cmp eax, 559 + button_size
	jg patrat_27
	mov eax, [ebp+arg3]
	cmp eax, 171
	jl patrat_27
	cmp eax, 169 + button_size
	jg patrat_27
	count_button 560, 170, 18, 7

patrat_27:
	mov eax, [ebp+arg2]
	cmp eax, 621
	jl patrat_28
	cmp eax, 619 + button_size
	jg patrat_28
	mov eax, [ebp+arg3]
	cmp eax, 171
	jl patrat_28
	cmp eax, 169 + button_size
	jg patrat_28
	count_button 620, 170, 18, 8

	
patrat_28:
	mov eax, [ebp+arg2]
	cmp eax, 101
	jl patrat_29
	cmp eax, 99 + button_size
	jg patrat_29
	mov eax, [ebp+arg3]
	cmp eax, 251
	jl patrat_29
	cmp eax, 249 + button_size
	jg patrat_29
	count_button 100, 250, 27, 0
	
patrat_29:
	mov eax, [ebp+arg2]
	cmp eax, 161
	jl patrat_30
	cmp eax, 159 + button_size
	jg patrat_30
	mov eax, [ebp+arg3]
	cmp eax, 251
	jl patrat_30
	cmp eax, 249 + button_size
	jg patrat_30
	count_button 160, 250, 27, 1

patrat_30:
	mov eax, [ebp+arg2]
	cmp eax, 221
	jl patrat_31
	cmp eax, 219 + button_size
	jg patrat_31
	mov eax, [ebp+arg3]
	cmp eax, 251
	jl patrat_31
	cmp eax, 249 + button_size
	jg patrat_31
	count_button 220, 250, 27, 2
	
patrat_31:
	mov eax, [ebp+arg2]
	cmp eax, 301
	jl patrat_32
	cmp eax, 299 + button_size
	jg patrat_32
	mov eax, [ebp+arg3]
	cmp eax, 251
	jl patrat_32
	cmp eax, 249 + button_size
	jg patrat_32
	count_button 300, 250, 27, 3
	
patrat_32:
	mov eax, [ebp+arg2]
	cmp eax, 361
	jl patrat_33
	cmp eax, 359 + button_size
	jg patrat_33
	mov eax, [ebp+arg3]
	cmp eax, 251
	jl patrat_33
	cmp eax, 249 + button_size
	jg patrat_33
	count_button 360, 250, 27, 4

patrat_33:
	mov eax, [ebp+arg2]
	cmp eax, 421
	jl patrat_34
	cmp eax, 419 + button_size
	jg patrat_34
	mov eax, [ebp+arg3]
	cmp eax, 251
	jl patrat_34
	cmp eax, 249 + button_size
	jg patrat_34
	count_button 420, 250, 27, 5
	
patrat_34:
	mov eax, [ebp+arg2]
	cmp eax, 501
	jl patrat_35
	cmp eax, 499 + button_size
	jg patrat_35
	mov eax, [ebp+arg3]
	cmp eax, 251
	jl patrat_35
	cmp eax, 249 + button_size
	jg patrat_35
	count_button 500, 250, 27, 6
	
patrat_35:
	mov eax, [ebp+arg2]
	cmp eax, 561
	jl patrat_36
	cmp eax, 559 + button_size
	jg patrat_36
	mov eax, [ebp+arg3]
	cmp eax, 251
	jl patrat_36
	cmp eax, 249 + button_size
	jg patrat_36
	count_button 560, 250, 27, 7

patrat_36:
	mov eax, [ebp+arg2]
	cmp eax, 621
	jl patrat_37
	cmp eax, 619 + button_size
	jg patrat_37
	mov eax, [ebp+arg3]
	cmp eax, 251
	jl patrat_37
	cmp eax, 249 + button_size
	jg patrat_37
	count_button 620, 250, 27, 8

patrat_37:
	mov eax, [ebp+arg2]
	cmp eax, 101
	jl patrat_38
	cmp eax, 99 + button_size
	jg patrat_38
	mov eax, [ebp+arg3]
	cmp eax, 311
	jl patrat_38
	cmp eax, 309 + button_size
	jg patrat_38
	count_button 100, 310, 36, 0
	
patrat_38:
	mov eax, [ebp+arg2]
	cmp eax, 161
	jl patrat_39
	cmp eax, 159 + button_size
	jg patrat_39
	mov eax, [ebp+arg3]
	cmp eax, 311
	jl patrat_39
	cmp eax, 309 + button_size
	jg patrat_39
	count_button 160, 310, 36, 1

patrat_39:
	mov eax, [ebp+arg2]
	cmp eax, 221
	jl patrat_40
	cmp eax, 219 + button_size
	jg patrat_40
	mov eax, [ebp+arg3]
	cmp eax, 311
	jl patrat_40
	cmp eax, 309 + button_size
	jg patrat_40
	count_button 220, 310, 36, 2
	
patrat_40:
	mov eax, [ebp+arg2]
	cmp eax, 301
	jl patrat_41
	cmp eax, 299 + button_size
	jg patrat_41
	mov eax, [ebp+arg3]
	cmp eax, 311
	jl patrat_41
	cmp eax, 309 + button_size
	jg patrat_41
	count_button 300, 310, 36, 3
	
patrat_41:
	mov eax, [ebp+arg2]
	cmp eax, 361
	jl patrat_42
	cmp eax, 359 + button_size
	jg patrat_42
	mov eax, [ebp+arg3]
	cmp eax, 311
	jl patrat_42
	cmp eax, 309 + button_size
	jg patrat_42
	count_button 360, 310, 36, 4

patrat_42:
	mov eax, [ebp+arg2]
	cmp eax, 421
	jl patrat_43
	cmp eax, 419 + button_size
	jg patrat_43
	mov eax, [ebp+arg3]
	cmp eax, 311
	jl patrat_43
	cmp eax, 309 + button_size
	jg patrat_43
	count_button 420, 310, 36, 5
	
patrat_43:
	mov eax, [ebp+arg2]
	cmp eax, 501
	jl patrat_44
	cmp eax, 499 + button_size
	jg patrat_44
	mov eax, [ebp+arg3]
	cmp eax, 311
	jl patrat_44
	cmp eax, 309 + button_size
	jg patrat_44
	count_button 500, 310, 36, 6
	
patrat_44:
	mov eax, [ebp+arg2]
	cmp eax, 561
	jl patrat_45
	cmp eax, 559 + button_size
	jg patrat_45
	mov eax, [ebp+arg3]
	cmp eax, 311
	jl patrat_45
	cmp eax, 309 + button_size
	jg patrat_45
	count_button 560, 310, 36, 7

patrat_45:
	mov eax, [ebp+arg2]
	cmp eax, 621
	jl patrat_46
	cmp eax, 619 + button_size
	jg patrat_46
	mov eax, [ebp+arg3]
	cmp eax, 311
	jl patrat_46
	cmp eax, 309 + button_size
	jg patrat_46
	count_button 620, 310, 36, 8

 patrat_46:
	mov eax, [ebp+arg2]
	cmp eax, 101
	jl patrat_47
	cmp eax, 99 + button_size
	jg patrat_47
	mov eax, [ebp+arg3]
	cmp eax, 371
	jl patrat_47
	cmp eax, 369 + button_size
	jg patrat_47
	count_button 100, 370, 45, 0
	
patrat_47:
	mov eax, [ebp+arg2]
	cmp eax, 161
	jl patrat_48
	cmp eax, 159 + button_size
	jg patrat_48
	mov eax, [ebp+arg3]
	cmp eax, 371
	jl patrat_48
	cmp eax, 369 + button_size
	jg patrat_48
	count_button 160, 370, 45, 1

patrat_48:
	mov eax, [ebp+arg2]
	cmp eax, 221
	jl patrat_49
	cmp eax, 219 + button_size
	jg patrat_49
	mov eax, [ebp+arg3]
	cmp eax, 371
	jl patrat_49
	cmp eax, 369 + button_size
	jg patrat_49
	count_button 220, 370, 45, 2
	
patrat_49:
	mov eax, [ebp+arg2]
	cmp eax, 301
	jl patrat_50
	cmp eax, 299 + button_size
	jg patrat_50
	mov eax, [ebp+arg3]
	cmp eax, 371
	jl patrat_50
	cmp eax, 369 + button_size
	jg patrat_50
	count_button 300, 370, 45, 3
	
patrat_50:
	mov eax, [ebp+arg2]
	cmp eax, 361
	jl patrat_51
	cmp eax, 359 + button_size
	jg patrat_51
	mov eax, [ebp+arg3]
	cmp eax, 371
	jl patrat_51
	cmp eax, 369 + button_size
	jg patrat_51
	count_button 360, 370, 45, 4

patrat_51:
	mov eax, [ebp+arg2]
	cmp eax, 421
	jl patrat_52
	cmp eax, 419 + button_size
	jg patrat_52
	mov eax, [ebp+arg3]
	cmp eax, 371
	jl patrat_52
	cmp eax, 369 + button_size
	jg patrat_52
	count_button 420, 370, 45, 5
	
patrat_52:
	mov eax, [ebp+arg2]
	cmp eax, 501
	jl patrat_53
	cmp eax, 499 + button_size
	jg patrat_53
	mov eax, [ebp+arg3]
	cmp eax, 371
	jl patrat_53
	cmp eax, 369 + button_size
	jg patrat_53
	count_button 500, 370, 45, 6
	
patrat_53:
	mov eax, [ebp+arg2]
	cmp eax, 561
	jl patrat_54
	cmp eax, 559 + button_size
	jg patrat_54
	mov eax, [ebp+arg3]
	cmp eax, 371
	jl patrat_54
	cmp eax, 369 + button_size
	jg patrat_54
	count_button 560, 370, 45, 7

patrat_54:
	mov eax, [ebp+arg2]
	cmp eax, 621
	jl patrat_55
	cmp eax, 619 + button_size
	jg patrat_55
	mov eax, [ebp+arg3]
	cmp eax, 371
	jl patrat_55
	cmp eax, 369 + button_size
	jg patrat_55
	count_button 620, 370, 45, 8

patrat_55:
	mov eax, [ebp+arg2]
	cmp eax, 101
	jl patrat_56
	cmp eax, 99 + button_size
	jg patrat_56
	mov eax, [ebp+arg3]
	cmp eax, 451
	jl patrat_56
	cmp eax, 449 + button_size
	jg patrat_56
	count_button 100, 450, 54, 0
	
patrat_56:
	mov eax, [ebp+arg2]
	cmp eax, 161
	jl patrat_57
	cmp eax, 159 + button_size
	jg patrat_57
	mov eax, [ebp+arg3]
	cmp eax, 451
	jl patrat_57
	cmp eax, 449 + button_size
	jg patrat_57
	count_button 160, 450, 54, 1

patrat_57:
	mov eax, [ebp+arg2]
	cmp eax, 221
	jl patrat_58
	cmp eax, 219 + button_size
	jg patrat_58
	mov eax, [ebp+arg3]
	cmp eax, 451
	jl patrat_58
	cmp eax, 449 + button_size
	jg patrat_58
	count_button 220, 450, 54, 2
	
patrat_58:
	mov eax, [ebp+arg2]
	cmp eax, 301
	jl patrat_59
	cmp eax, 299 + button_size
	jg patrat_59
	mov eax, [ebp+arg3]
	cmp eax, 451
	jl patrat_59
	cmp eax, 449 + button_size
	jg patrat_59
	count_button 300, 450, 54, 3
	
patrat_59:
	mov eax, [ebp+arg2]
	cmp eax, 361
	jl patrat_60
	cmp eax, 359 + button_size
	jg patrat_60
	mov eax, [ebp+arg3]
	cmp eax, 451
	jl patrat_60
	cmp eax, 449 + button_size
	jg patrat_60
	count_button 360, 450, 54, 4

patrat_60:
	mov eax, [ebp+arg2]
	cmp eax, 421
	jl patrat_61
	cmp eax, 419 + button_size
	jg patrat_61
	mov eax, [ebp+arg3]
	cmp eax, 451
	jl patrat_61
	cmp eax, 449 + button_size
	jg patrat_61
	count_button 420, 450, 54, 5
	
patrat_61:
	mov eax, [ebp+arg2]
	cmp eax, 501
	jl patrat_62
	cmp eax, 499 + button_size
	jg patrat_62
	mov eax, [ebp+arg3]
	cmp eax, 451
	jl patrat_62
	cmp eax, 449 + button_size
	jg patrat_62
	count_button 500, 450, 54, 6
	
patrat_62:
	mov eax, [ebp+arg2]
	cmp eax, 561
	jl patrat_63
	cmp eax, 559 + button_size
	jg patrat_63
	mov eax, [ebp+arg3]
	cmp eax, 451
	jl patrat_63
	cmp eax, 449 + button_size
	jg patrat_63
	count_button 560, 450, 54, 7

patrat_63:
	mov eax, [ebp+arg2]
	cmp eax, 621
	jl patrat_64
	cmp eax, 619 + button_size
	jg patrat_64
	mov eax, [ebp+arg3]
	cmp eax, 451
	jl patrat_64
	cmp eax, 449 + button_size
	jg patrat_64
	count_button 620, 450, 54, 8

patrat_64:
	mov eax, [ebp+arg2]
	cmp eax, 101
	jl patrat_65
	cmp eax, 99 + button_size
	jg patrat_65
	mov eax, [ebp+arg3]
	cmp eax, 511
	jl patrat_65
	cmp eax, 509 + button_size
	jg patrat_65
	count_button 100, 510, 63, 0
	
patrat_65:
	mov eax, [ebp+arg2]
	cmp eax, 161
	jl patrat_66
	cmp eax, 159 + button_size
	jg patrat_66
	mov eax, [ebp+arg3]
	cmp eax, 511
	jl patrat_66
	cmp eax, 509 + button_size
	jg patrat_66
	count_button 160, 510, 63, 1

patrat_66:
	mov eax, [ebp+arg2]
	cmp eax, 221
	jl patrat_67
	cmp eax, 219 + button_size
	jg patrat_67
	mov eax, [ebp+arg3]
	cmp eax, 511
	jl patrat_67
	cmp eax, 509 + button_size
	jg patrat_67
	count_button 220, 510, 63, 2
	
patrat_67:
	mov eax, [ebp+arg2]
	cmp eax, 301
	jl patrat_68
	cmp eax, 299 + button_size
	jg patrat_68
	mov eax, [ebp+arg3]
	cmp eax, 511
	jl patrat_68
	cmp eax, 509 + button_size
	jg patrat_68
	count_button 300, 510, 63, 3
	
patrat_68:
	mov eax, [ebp+arg2]
	cmp eax, 361
	jl patrat_69
	cmp eax, 359 + button_size
	jg patrat_69
	mov eax, [ebp+arg3]
	cmp eax, 511
	jl patrat_69
	cmp eax, 509 + button_size
	jg patrat_69
	count_button 360, 510, 63, 4

patrat_69:
	mov eax, [ebp+arg2]
	cmp eax, 421
	jl patrat_70
	cmp eax, 419 + button_size
	jg patrat_70
	mov eax, [ebp+arg3]
	cmp eax, 511
	jl patrat_70
	cmp eax, 509 + button_size
	jg patrat_70
	count_button 420, 510, 63, 5
	
patrat_70:
	mov eax, [ebp+arg2]
	cmp eax, 501
	jl patrat_71
	cmp eax, 499 + button_size
	jg patrat_71
	mov eax, [ebp+arg3]
	cmp eax, 511
	jl patrat_71
	cmp eax, 509 + button_size
	jg patrat_71
	count_button 500, 510, 63, 6
	
patrat_71:
	mov eax, [ebp+arg2]
	cmp eax, 561
	jl patrat_72
	cmp eax, 559 + button_size
	jg patrat_72
	mov eax, [ebp+arg3]
	cmp eax, 511
	jl patrat_72
	cmp eax, 509 + button_size
	jg patrat_72
	count_button 560, 510, 63, 7

patrat_72:
	mov eax, [ebp+arg2]
	cmp eax, 621
	jl patrat_73
	cmp eax, 619 + button_size
	jg patrat_73
	mov eax, [ebp+arg3]
	cmp eax, 511
	jl patrat_73
	cmp eax, 509 + button_size
	jg patrat_73
	count_button 620, 510, 63, 8

patrat_73:
	mov eax, [ebp+arg2]
	cmp eax, 101
	jl patrat_74
	cmp eax, 99 + button_size
	jg patrat_74
	mov eax, [ebp+arg3]
	cmp eax, 571
	jl patrat_74
	cmp eax, 569 + button_size
	jg patrat_74
	count_button 100, 570, 72, 0
	
patrat_74:
	mov eax, [ebp+arg2]
	cmp eax, 161
	jl patrat_75
	cmp eax, 159 + button_size
	jg patrat_75
	mov eax, [ebp+arg3]
	cmp eax, 571
	jl patrat_75
	cmp eax, 569 + button_size
	jg patrat_75
	count_button 160, 570, 72, 1

patrat_75:
	mov eax, [ebp+arg2]
	cmp eax, 221
	jl patrat_76
	cmp eax, 219 + button_size
	jg patrat_76
	mov eax, [ebp+arg3]
	cmp eax, 571
	jl patrat_76
	cmp eax, 569 + button_size
	jg patrat_76
	count_button 220, 570, 72, 2
	
patrat_76:
	mov eax, [ebp+arg2]
	cmp eax, 301
	jl patrat_77
	cmp eax, 299 + button_size
	jg patrat_77
	mov eax, [ebp+arg3]
	cmp eax, 571
	jl patrat_77
	cmp eax, 569 + button_size
	jg patrat_77
	count_button 300, 570, 72, 3
	
patrat_77:
	mov eax, [ebp+arg2]
	cmp eax, 361
	jl patrat_78
	cmp eax, 359 + button_size
	jg patrat_78
	mov eax, [ebp+arg3]
	cmp eax, 571
	jl patrat_78
	cmp eax, 569 + button_size
	jg patrat_78
	count_button 360, 570, 72, 4

patrat_78:
	mov eax, [ebp+arg2]
	cmp eax, 421
	jl patrat_79
	cmp eax, 419 + button_size
	jg patrat_79
	mov eax, [ebp+arg3]
	cmp eax, 571
	jl patrat_79
	cmp eax, 569 + button_size
	jg patrat_79
	count_button 420, 570, 72, 5
	
patrat_79:
	mov eax, [ebp+arg2]
	cmp eax, 501
	jl patrat_80
	cmp eax, 499 + button_size
	jg patrat_80
	mov eax, [ebp+arg3]
	cmp eax, 571
	jl patrat_80
	cmp eax, 569 + button_size
	jg patrat_80
	count_button 500, 570, 72, 6
	
patrat_80:
	mov eax, [ebp+arg2]
	cmp eax, 561
	jl patrat_81
	cmp eax, 559 + button_size
	jg patrat_81
	mov eax, [ebp+arg3]
	cmp eax, 571
	jl patrat_81
	cmp eax, 569 + button_size
	jg patrat_81
	count_button 560, 570, 72, 7

patrat_81:
	mov eax, [ebp+arg2]
	cmp eax, 621
	jl buton_rezolvare
	cmp eax, 619 + button_size
	jg buton_rezolvare
	mov eax, [ebp+arg3]
	cmp eax, 571
	jl buton_rezolvare
	cmp eax, 569 + button_size
	jg buton_rezolvare
	count_button 620, 570, 72, 8
	
buton_rezolvare:
	mov eax, [ebp+arg2]
	cmp eax, 901
	jl fail
	cmp eax, 899 + button_size
	jg fail
	mov eax, [ebp+arg3]
	cmp eax, 311
	jl fail
	cmp eax, 309 + button_size
	jg fail
	reset

	jmp afisare_litere
	
evt_timer:
	
afisare_litere:
	make_text_macro 'S', area, 360, 15
	make_text_macro 'U', area, 370, 15
	make_text_macro 'D', area, 380, 15
	make_text_macro 'O', area, 390, 15
	make_text_macro 'K', area, 400, 15
	make_text_macro 'U', area, 410, 15
	
	make_text_macro 'R', area, 906, 285
	make_text_macro 'E', area, 916, 285
	make_text_macro 'S', area, 926, 285
	make_text_macro 'E', area, 936, 285
	make_text_macro 'T', area, 946, 285
	
prima_linie:
	make_button 100, 50, 60
	make_button 160, 50, 60
	make_button 220, 50, 60
	
	make_button 300, 50, 60
	make_button 360, 50, 60
	make_button 420, 50, 60
	
	make_button 500, 50, 60
	make_button 560, 50, 60
	make_button 620, 50, 60

a_doua_linie:
	make_button 100, 110, 60
	make_button 160, 110, 60
	make_button 220, 110, 60
	
	make_button 300, 110, 60
	make_button 360, 110, 60
	make_button 420, 110, 60
	
	make_button 500, 110, 60
	make_button 560, 110, 60
	make_button 620, 110, 60
	
a_treia_linie:
	make_button 100, 170, 60
	make_button 160, 170, 60
	make_button 220, 170, 60
	
	make_button 300, 170, 60
	make_button 360, 170, 60
	make_button 420, 170, 60
	
	make_button 500, 170, 60
	make_button 560, 170, 60
	make_button 620, 170, 60
	
a_patra_linie:
	make_button 100, 250, 60
	make_button 160, 250, 60
	make_button 220, 250, 60
	
	make_button 300, 250, 60
	make_button 360, 250, 60
	make_button 420, 250, 60
	
	make_button 500, 250, 60
	make_button 560, 250, 60
	make_button 620, 250, 60

a_cincea_linie:
	make_button 100, 310, 60
	make_button 160, 310, 60
	make_button 220, 310, 60
	
	make_button 300, 310, 60
	make_button 360, 310, 60
	make_button 420, 310, 60
	
	make_button 500, 310, 60
	make_button 560, 310, 60
	make_button 620, 310, 60

a_sasea_linie:
	make_button 100, 370, 60
	make_button 160, 370, 60
	make_button 220, 370, 60
	
	make_button 300, 370, 60
	make_button 360, 370, 60
	make_button 420, 370, 60
	
	make_button 500, 370, 60
	make_button 560, 370, 60
	make_button 620, 370, 60

a_saptea_linie:
	make_button 100, 450, 60
	make_button 160, 450, 60
	make_button 220, 450, 60
	
	make_button 300, 450, 60
	make_button 360, 450, 60
	make_button 420, 450, 60
	
	make_button 500, 450, 60
	make_button 560, 450, 60
	make_button 620, 450, 60

a_opta_linie:
	make_button 100, 510, 60
	make_button 160, 510, 60
	make_button 220, 510, 60
	
	make_button 300, 510, 60
	make_button 360, 510, 60
	make_button 420, 510, 60
	
	make_button 500, 510, 60
	make_button 560, 510, 60
	make_button 620, 510, 60
	
a_noua_linie:
	make_button 100, 570, 60
	make_button 160, 570, 60
	make_button 220, 570, 60
	
	make_button 300, 570, 60
	make_button 360, 570, 60
	make_button 420, 570, 60
	
	make_button 500, 570, 60
	make_button 560, 570, 60
	make_button 620, 570, 60
	
buton_special:
	make_button 900, 310, 60

	;verific ce este in matrice diferit de 0
line1:
	verify_button 100, 50, 0, 0
	verify_button 160, 50, 0, 1
	verify_button 220, 50, 0, 2
	verify_button 300, 50, 0, 3
	verify_button 360, 50, 0, 4
	verify_button 420, 50, 0, 5
	verify_button 500, 50, 0, 6
	verify_button 560, 50, 0, 7
	verify_button 620, 50, 0, 8
line2:
	verify_button 100, 110, 9, 0
	verify_button 160, 110, 9, 1
	verify_button 220, 110, 9, 2
	verify_button 300, 110, 9, 3
	verify_button 360, 110, 9, 4
	verify_button 420, 110, 9, 5
	verify_button 500, 110, 9, 6
	verify_button 560, 110, 9, 7
	verify_button 620, 110, 9, 8
line3:
	verify_button 100, 170, 18, 0
	verify_button 160, 170, 18, 1
	verify_button 220, 170, 18, 2
	verify_button 300, 170, 18, 3
	verify_button 360, 170, 18, 4
	verify_button 420, 170, 18, 5
	verify_button 500, 170, 18, 6
	verify_button 560, 170, 18, 7
	verify_button 620, 170, 18, 8
line4:
	verify_button 100, 250, 27, 0
	verify_button 160, 250, 27, 1
	verify_button 220, 250, 27, 2
	verify_button 300, 250, 27, 3
	verify_button 360, 250, 27, 4
	verify_button 420, 250, 27, 5
	verify_button 500, 250, 27, 6
	verify_button 560, 250, 27, 7
	verify_button 620, 250, 27, 8
line5:
	verify_button 100, 310, 36, 0
	verify_button 160, 310, 36, 1
	verify_button 220, 310, 36, 2
	verify_button 300, 310, 36, 3
	verify_button 360, 310, 36, 4
	verify_button 420, 310, 36, 5
	verify_button 500, 310, 36, 6
	verify_button 560, 310, 36, 7
	verify_button 620, 310, 36, 8
line6:
	verify_button 100, 370, 45, 0
	verify_button 160, 370, 45, 1
	verify_button 220, 370, 45, 2
	verify_button 300, 370, 45, 3
	verify_button 360, 370, 45, 4
	verify_button 420, 370, 45, 5
	verify_button 500, 370, 45, 6
	verify_button 560, 370, 45, 7
	verify_button 620, 370, 45, 8
line7:
	verify_button 100, 450, 54, 0
	verify_button 160, 450, 54, 1
	verify_button 220, 450, 54, 2
	verify_button 300, 450, 54, 3
	verify_button 360, 450, 54, 4
	verify_button 420, 450, 54, 5
	verify_button 500, 450, 54, 6
	verify_button 560, 450, 54, 7
	verify_button 620, 450, 54, 8
line8:
	verify_button 100, 510, 63, 0
	verify_button 160, 510, 63, 1
	verify_button 220, 510, 63, 2
	verify_button 300, 510, 63, 3
	verify_button 360, 510, 63, 4
	verify_button 420, 510, 63, 5
	verify_button 500, 510, 63, 6
	verify_button 560, 510, 63, 7
	verify_button 620, 510, 63, 8
line9:
	verify_button 100, 570, 72, 0
	verify_button 160, 570, 72, 1
	verify_button 220, 570, 72, 2
	verify_button 300, 570, 72, 3
	verify_button 360, 570, 72, 4
	verify_button 420, 570, 72, 5
	verify_button 500, 570, 72, 6
	verify_button 560, 570, 72, 7
	verify_button 620, 570, 72, 8
fail:
	
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start