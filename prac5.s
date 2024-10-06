		AREA datos,DATA
;vuestras variables y constantes
; variables y constantes

reloj	DCD 0 ;contador de centesimas de segundo
max		DCD 8 ;velocidad de movimiento (en centesimas s.)
contador 	DCD 0	;instante siguiente movimiento
almacen_uno 	DCD 0
almacen_dos 	DCD 0
i_carretera		DCD 8
d_carretera		DCD 16
semilla		DCD 840710
tecla_pulsada DCD 0
puntuacion_u	DCB 48
puntuacion_d	DCB 48
puntuacion_c	DCB 48
puntuacion_m	DCB 48
iteraciones DCB 0
dirx 	DCB 12 ;direccion mov. caracter ‘H’ (-1 izda.,0 stop,1 der.)
diry 	DCB 15 ;direccion mov. caracter ‘H’ (-1 arriba,0 stop,1 abajo)
izquierda	DCB 0
medio		DCB 0
num_veces	DCB 0
fin 	DCB 0 ;indicador fin de programa (si vale 1)
pausita 	DCB 0 ;indicador pausa de programa (si vale 1)
credits	DCB 0 ;muestra los creditos (si vale 1)
texto	DCB "GAME OVER"
texto_2	DCB "-------------PAUSA--------------"
texto_3 DCB "CREADORES:" 
texto_4 DCB "JAVIER JULVE Y MARCOS GARCiA"
texto_5 DCB "DEDICADO ESPECIALMENTE A:"
texto_6 DCB "SANJU"
texto_7	DCB "PUNTUACION: "
I_Bit 	EQU 0x80
T0_IR 	EQU 0xE0004000
VICVectAddr0 EQU 0xFFFFF100
VICVectAddr EQU 0xFFFFF030
VICIntEnable EQU 0xFFFFF010
VICIntEnClr EQU 0xFFFFF014
RDAT	EQU	0xE0010000
IOSET	EQU 0xE0028004
IOCLR	EQU 0xE002800C
pantalla     EQU 0x40007E00
game_over	EQU 0x40007EE9
dir_puntos	EQU 0x40007F09
dir_pausa		EQU 0x40007EE0
dir_name		EQU 0x40007F00
dir_dedicatoria	EQU 0x40007FA0
dir_dedicatoria_sig	EQU 0x40007FC0
filas         EQU 16
columnas     EQU 32
carretera    EQU '#'
espacio        EQU ' '
coche        EQU 'H'


	
		AREA codigo,CODE
		EXPORT inicio			; forma de enlazar con el startup.s
		IMPORT srand			; para poder invocar SBR srand
		IMPORT rand				; para poder invocar SBR rand
inicio	; se recomienda poner punto de parada (breakpoint) en la primera
		; instruccion de código para poder ejecutar todo el Startup de golpe
		
;Inicializo teclado	
	LDR r0,=VICVectAddr0
	LDR r1,=RSI_teclado
	mov r2,#7
	str r1,[r0,r2,LSL #2]
	LDR r0,=VICIntEnable
	mov r1,#2_10000000
	str r1,[r0]
;Inicializo reloj
	LDR r0,=VICVectAddr0
	LDR r1,=RSI_timer
	mov r2,#4
	str r1,[r0,r2,LSL#2]
	LDR r0,=VICIntEnable
	mov r1,#0x10
	str r1,[r0]

	b main
	
		
		
main
	LDR r0, =pantalla
    push{r0}
    bl ini_pantalla
    add sp, sp, #4
	LDR r1, =semilla
	ldr r1, [r1]
	push{r1}
	bl srand
	add sp, sp, #4
	bl random
	
	
bucle
	
	LDR r0,=pausita
	ldrb r0,[r0]
	cmp r0,#1
	beq pausado
	
	LDR r0,=tecla_pulsada
	ldr r0, [r0]
	cmp r0, #0
	blne mover_coche
	
	
	LDR r0,=contador
	ldr r0,[r0]
	LDR r1,=max
	ldr r1,[r1]
	cmp r0,r1
	blt comprobar_fin
	ldr r1,=contador
	mov r0,#0
	str r0,[r1]
	bl sumar_puntos
	bl act_carretera
	bl generar_carretera
	bl mover_coche
	

comprobar_fin
	LDR r0,=fin
	ldrb r0,[r0]
	cmp r0,#1
	bne bucle 	
	
	bl over
	b deshab

pausado
	bl almacenar
	bl pausa
pausa_sigue
	LDR r0,=credits
	ldrb r0,[r0]
	cmp r0,#1
	bleq creditos
	beq deshab
	LDR r2,=pausita
	ldrb r2,[r2]
	cmp r2,#1
	beq pausa_sigue
	bl despausar
	b bucle

	
deshab 
	LDR r0,=VICIntEnClr
	ldr r1,[r0]
	mov r2,#2_10010000
	orr r1,r1,r2
	str r1,[r0]


final b final

;INICIALIZAR PANTALLA
;---------------------------------------------------------------------------------------------------------------------------------------------------------
ini_pantalla
    push{lr, fp}
    mov fp, sp
    push{r0-r6}
    LDR r0, [fp, #8]  ;r0=@pantalla
    mov r3, #carretera
    mov r4, #espacio
	mov r5, #columnas
    mov r1, #0  ;r1=i
for_1
    cmp r1, #16
    beq poner_coche
    mov r2, #0 ;r2=j
for_2
    cmp r2, #32
    addeq r1, r1, #1
    beq for_1
	mul r6,r1,r5
	add r6,r6,r2
	cmp r2,#8
	beq hastag
	cmp r2,#16
	beq hastag
	strb r4,[r0,r6]
	add r2,r2,#1
	b for_2
hastag
	strb r3,[r0,r6]
	add r2,r2,#1
	b for_2
poner_coche   
	mov r6, #coche
	LDR r3,=dirx
	ldrb r3,[r3]
	LDR r4,=diry
	ldrb r4,[r4]
	mul r1,r4,r5
	add r1,r1,r3
	strb r6,[r0,r1]


    pop{r0, r1, r2, r3, r4, r5, r6, fp, pc}
;---------------------------------------------------------------------------------------------------------------------------------------------------------	
	
;ACTUALIZAR CARRETERA
;---------------------------------------------------------------------------------------------------------------------------------------------------------
act_carretera
	push{lr}
	push{r0-r8}
	LDR r0,=VICIntEnClr
	ldr r1,[r0]
	mov r2,#2_10010000
	orr r1,r1,r2
	str r1,[r0]
	bl borrar_coche
	
	LDR r0,=pantalla
	mov r1,#espacio
	mov r2,#carretera
	mov r4,#14 ;j
	mov r5,#columnas
	mov r8,#coche
for
	cmp r4,#-1
	beq fin_carretera
	mov r3,#0 ;i
	
otro_for
	cmp r3,#32
	subeq r4,r4,#1
	beq for
	mul r6,r5,r4
	add r6,r6,r3
	ldr r7,[r0,r6]
	add r6,r6,#32
	str r7,[r0,r6]
	add r3,r3,#4
	b otro_for
	
fin_carretera
	LDR r0,=VICIntEnable
	ldr r1,[r0]
	mov r2,#2_10010000
	orr r1,r1,r2
	str r1,[r0]
	bl colision
	LDR r0,=dirx
	ldrb r0,[r0]
	LDR r1,=diry
	ldrb r1,[r1]
	mov r2, #columnas
	LDR r3, =pantalla
	mov r5, #coche
	mul r4, r1, r2
	add r4, r4, r0
	strb r5, [r3, r4]
	
	pop{r0, r1, r2, r3, r4, r5, r6, r7, r8, pc}
	
;---------------------------------------------------------------------------------------------------------------------------------------------------------


;MOVER COCHE
;---------------------------------------------------------------------------------------------------------------------------------------------------------
mover_coche
	push{lr}
    push{r0-r5}
	bl borrar_coche
	LDR r2, =tecla_pulsada
	ldr r2, [r2]
	LDR r1,=dirx
	ldrb r0,[r1]
J
	cmp r2,#74 ;J
	bne L
	sub r0,#1
	strb r0,[r1]
	b fin_mover
L
	cmp r2,#76 ;L
	bne cordY
	add r0,#1
	strb r0,[r1]
	b fin_mover

cordY
	LDR r1,=diry
	ldrb r0,[r1]
	
K
	cmp r2,#75 ;K
	bne I
	cmp r0,#15
	beq fin_mover 
	add r0,#1
	strb r0,[r1]
	b fin_mover
I
	cmp r2,#73
	bne fin_mover
	sub r0,#1
	cmp r0,#-1
	addeq r0,#1
	strb r0,[r1]
	b fin_mover
	
	
fin_mover
	LDR r2, =tecla_pulsada
	mov r1, #0
	str r1, [r2]
	bl colision
	LDR r0,=dirx
	ldrb r0,[r0]
	LDR r1,=diry
	ldrb r1,[r1]
	mov r2, #columnas
	LDR r3, =pantalla
	mov r5, #coche
	mul r4, r1, r2
	add r4, r4, r0
	strb r5, [r3, r4]
	pop{r0, r1, r2, r3, r4, r5, pc}
	
	
;---------------------------------------------------------------------------------------------------------------------------------------------------------


;COLISION
;---------------------------------------------------------------------------------------------------------------------------------------------------------
colision
	push{lr}
	push{r0-r5}
	LDR r0,=dirx
	ldrb r0,[r0]
	LDR r1,=diry
	ldrb r1,[r1]
	mov r2, #columnas
	LDR r3, =pantalla
	mov r4, #carretera
	mul r5, r1, r2
	add r5, r5, r0
	ldrb r6, [r3, r5]
	cmp r6, r4
	bne no_colision
	LDR r0, =fin
	mov r1, #1
	strb r1,[r0]
no_colision
	pop{r0, r1, r2, r3, r4, r5, pc}
	

;---------------------------------------------------------------------------------------------------------------------------------------------------------


;BORRAR COCHE
;---------------------------------------------------------------------------------------------------------------------------------------------------------
borrar_coche
	push{lr}
	push{r0-r5}
	LDR r0,=dirx
	ldrb r0,[r0]
	LDR r1,=diry
	ldrb r1,[r1]
	LDR r2,=pantalla
	mov r3,#espacio
	mov r4,#columnas
	mul r5,r1,r4
	add r5,r5,r0
	strb r3,[r2,r5]
	
	pop{r0, r1, r2, r3, r4, r5, pc}
;---------------------------------------------------------------------------------------------------------------------------------------------------------
	
;SUMAR PUNTOS
;---------------------------------------------------------------------------------------------------------------------------------------------------------
sumar_puntos
	push{lr}
	push{r0,r1}
	LDR r0,=puntuacion_u
	ldrb r1,[r0]
	cmp r1,#57
	beq decenas
	add r1,r1,#1
	strb r1,[r0]
	b final_points
decenas
	mov r1,#48
	strb r1,[r0]
	LDR r0,=puntuacion_d
	ldrb r1,[r0]
	cmp r1,#57
	beq centenas
	add r1,r1,#1
	strb r1,[r0]
	b final_points
centenas
	mov r1,#48
	strb r1,[r0]
	LDR r0,=puntuacion_c
	ldrb r1,[r0]
	cmp r1,#57
	beq miles
	add r1,r1,#1
	strb r1,[r0]
	b final_points
miles
	mov r1,#48
	strb r1,[r0]
	LDR r0,=puntuacion_m
	ldrb r1,[r0]
	cmp r1,#57
	beq final_points
	add r1,r1,#1
	strb r1,[r0]

final_points
	
	pop{r0,r1,pc}

;---------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
;PANTALLA GAMEOVER
;---------------------------------------------------------------------------------------------------------------------------------------------------------
over	
	push{lr}
	push{r0-r5}
	LDR r0,=pantalla
	mov r1,#espacio
	mov r2,#0
	mov r4,#columnas
for_over
	cmp r2,#16
	beq fin_over
	mov r3,#0 ;i
	
otro_for_over
	cmp r3,#32
	addeq r2,r2,#1
	beq for_over
	mul r5,r4,r2
	add r5,r5,r3
	strb r1,[r0,r5]
	add r3,r3,#1
	b otro_for_over
	
fin_over
	LDR r0,=game_over ;@ escribir el mensaje
	mov r2,#0 ;i
	LDR r1,=texto ;texto
for_texto
	ldrb r3,[r1]
	strb r3,[r0,r2]
	add r2,r2,#1
	add r1,r1,#1
	cmp r2,#9
	bne for_texto
	bl puntos

	pop{r0, r1, r2, r3, r4, r5, pc}
	
;---------------------------------------------------------------------------------------------------------------------------------------------------------

;PUNTUACION
;---------------------------------------------------------------------------------------------------------------------------------------------------------
puntos
	push{lr}
	push{r0,r1,r2,r3}
	LDR r0,=dir_puntos
	mov r1,#0
	LDR r2,=texto_7
for_puntos
	ldrb r3,[r2]
	strb r3,[r0,r1]
	add r1,r1,#1
	add r2,r2,#1
	cmp r1,#11
	bne for_puntos
	LDR r2,=puntuacion_m ;miles
	ldrb r2,[r2]
	add r1,r1,#1
	strb r2,[r0,r1]
	LDR r2,=puntuacion_c ;centenas
	ldrb r2,[r2]
	add r1,r1,#1
	strb r2,[r0,r1]
	LDR r2,=puntuacion_d ;decenas
	ldrb r2,[r2]
	add r1,r1,#1
	strb r2,[r0,r1]
	LDR r2,=puntuacion_u ;unidades
	ldrb r2,[r2]
	add r1,r1,#1
	strb r2,[r0,r1]

	pop{r0, r1, r2, r3, pc}
;---------------------------------------------------------------------------------------------------------------------------------------------------------


;PAUSA
;---------------------------------------------------------------------------------------------------------------------------------------------------------
pausa
	push{lr}
	push{r0,r1,r2,r3}
	LDR r0,=dir_pausa
	mov r1,#0
	LDR r2,=texto_2
for_pausa
	ldrb r3,[r2]
	strb r3,[r0,r1]
	add r1,r1,#1
	add r2,r2,#1
	cmp r1,#32
	bne for_pausa
	
	pop{r0, r1, r2, r3, pc}
;---------------------------------------------------------------------------------------------------------------------------------------------------------

;ALMACENAR
;---------------------------------------------------------------------------------------------------------------------------------------------------------
almacenar
	push{lr}
	push{r0,r1,r2,r3,r4}
	LDR r0,=dir_pausa
	mov r1,#0
	mov r2,#carretera
	mov r4,#0
for_almacenar
	ldrb r3,[r0]
	cmp r3,r2
	bne no
	cmp r4,#1
	beq segundo_almacen
	LDR r3,=almacen_uno
	str r0,[r3]
	add r4,#1
	b no
segundo_almacen
	LDR r3,=almacen_dos
	str r0,[r3]
no
	add r0,r0,#1
	add r1,r1,#1
	cmp r1,#32
	bne for_almacenar

	pop{r0, r1, r2, r3, r4, pc}
	
;---------------------------------------------------------------------------------------------------------------------------------------------------------

;DESPAUSAR
;---------------------------------------------------------------------------------------------------------------------------------------------------------
despausar
	push{lr}
	push{r0,r1,r2}
	LDR r0,=dir_pausa
	mov r1,#0
	mov r2,#espacio
for_despausa
	strb r2,[r0,r1]
	add r1,r1,#1
	cmp r1,#32
	bne for_despausa
	
	mov r2,#carretera
	LDR r0,=almacen_uno
	ldr r0,[r0]
	LDR r1,=almacen_dos
	ldr r1,[r1]
	strb r2,[r0]
	strb r2,[r1]
	
	pop{r0, r1, r2, pc}
	
;---------------------------------------------------------------------------------------------------------------------------------------------------------

;CRÉDITOS
;---------------------------------------------------------------------------------------------------------------------------------------------------------
creditos
	push{lr}
	push{r0,r1,r2,r3,r4,r5}
	LDR r0,=credits
	ldrb r0,[r0]
	cmp r0,#1
	bne fin_creditos
poner_creditos
	push{lr}
	push{r0-r5}
	LDR r0,=pantalla
	mov r1,#espacio
	mov r2,#0
	mov r4,#columnas
for_credits
	cmp r2,#16
	beq fin_credits
	mov r3,#0 ;i
	
otro_for_credits
	cmp r3,#32
	addeq r2,r2,#1
	beq for_credits
	mul r5,r4,r2
	add r5,r5,r3
	strb r1,[r0,r5]
	add r3,r3,#1
	b otro_for_credits
	
fin_credits
	LDR r0,=dir_pausa ;@ escribir el mensaje
	mov r2,#0 ;i
	LDR r1,=texto_3 ;texto
for_texto_credits
	ldrb r3,[r1]
	strb r3,[r0,r2]
	add r2,r2,#1
	add r1,r1,#1
	cmp r2,#10
	bne for_texto_credits
	

	LDR r0,=dir_name ;@ escribir el mensaje
	mov r2,#0 ;i
	LDR r1,=texto_4 ;texto
for_texto_credits_name
	ldrb r3,[r1]
	strb r3,[r0,r2]
	add r2,r2,#1
	add r1,r1,#1
	cmp r2,#28
	bne for_texto_credits_name
	
	
	LDR r0,=dir_dedicatoria ;@ escribir el mensaje
	mov r2,#0 ;i
	LDR r1,=texto_5 ;texto
for_texto_dedicar
	ldrb r3,[r1]
	strb r3,[r0,r2]
	add r2,r2,#1
	add r1,r1,#1
	cmp r2,#25
	bne for_texto_dedicar
	
	
	LDR r0,=dir_dedicatoria_sig ;@ escribir el mensaje
	mov r2,#0 ;i
	LDR r1,=texto_6 ;texto
for_texto_dedicar_sig
	ldrb r3,[r1]
	strb r3,[r0,r2]
	add r2,r2,#1
	add r1,r1,#1
	cmp r2,#5
	bne for_texto_dedicar_sig
fin_creditos
	pop{r0, r1, r2, r3, r4, r5, pc}
;---------------------------------------------------------------------------------------------------------------------------------------------------------

;RANDOMIZAR
;---------------------------------------------------------------------------------------------------------------------------------------------------------
random
	push{lr}
	push{r0-r4}
	sub sp, sp, #4
	bl rand
	pop {r1}
	and r3, r1, #12
	and r1,r1,#3
	cmp r1,#1
	beq n_veces
	cmp r1,#2
	beq izda
centro
	mov r2,#1
	LDR r1,=medio
	strb r2,[r1]
	b n_veces
izda
	mov r2,#1
	LDR r1,=izquierda
	strb r2,[r1]
	b n_veces
n_veces
	mov r4, #0
	add r3, r4, r3, LSR #2
	LDR r4, =num_veces
	strb r3, [r4]
	pop{r0,r1,r2,r3,r4,pc}

;---------------------------------------------------------------------------------------------------------------------------------------------------------

;GENERAR CARRETERA
;---------------------------------------------------------------------------------------------------------------------------------------------------------
generar_carretera
	push{lr}
	push{r0-r7}
	LDR r0, =num_veces
	ldrb r1,[r0]
	cmp r1, #0
	ble generar_random
principio
	mov r5, #espacio
	LDR r2,=pantalla
	LDR r3, =i_carretera
	LDR r4, =d_carretera
	ldrb r6, [r3] ;valor de i_carretera
	ldrb r7, [r4] ;valor de d_carretera
	strb r5,[r2,r6]
	strb r5,[r2,r7]
	LDR r5,=medio
	ldrb r5,[r5] ;valor de medio
	cmp r5, #1
	bne ir_izquierda
	b recolocar_carretera
ir_izquierda
	LDR r5,=izquierda
	ldrb r5,[r5] ;valor de izquierda
	cmp r5, #1
	bne ir_derecha
	sub r6, r6, #1
	cmp r6, #0
	bge no_hacer_1
	mov r6, #0
	b recolocar_carretera
no_hacer_1
	sub r7, r7, #1
	b recolocar_carretera
ir_derecha
	add r7, r7, #1
	cmp r7, #31
	ble no_hacer_2
	mov r7, #31
	b recolocar_carretera
no_hacer_2
	add r6, r6, #1
recolocar_carretera
	mov r5, #carretera
	strb r5, [r2, r6]
	strb r5, [r2, r7]
	sub r1, r1, #1
	strb r1, [r0]
	strb r6, [r3]
	strb r7, [r4]
	b fin_generar
generar_random
	LDR r0, =medio
	LDR r1, =izquierda
	mov r2, #0
	strb r2, [r0]
	strb r2, [r1]
	bl random
	b principio
fin_generar
	bl colision
	pop{r0,r1,r2,r3,r4,r5,r6,r7,pc}
;---------------------------------------------------------------------------------------------------------------------------------------------------------


;TECLADO
;---------------------------------------------------------------------------------------------------------------------------------------------------------
RSI_teclado 
	sub lr, lr, #4
	push{lr}
	mrs	r14, spsr
	push{r14}
	push{r0,r1,r2,r3}
	mrs r1,cpsr
	bic r1,r1,#I_Bit
	msr cpsr_c, r1
;Transferencia	
	LDR r1,=RDAT
	ldrb r2,[r1] ;r2=tecla pulsada
;Tratamiento
	bic r2,r2,#2_100000
	cmp r2,#80 ;Tecla P provoca pausa 
	bne cont
	LDR r1,=pausita
	ldrb r3,[r1]
	cmp r3,#1
	bne cambio
	LDR r1,=pausita
	mov r3,#0
	strb r3,[r1]
	b teclado_fin
cambio
	LDR r1,=pausita
	mov r3,#1
	strb r3,[r1]
	b teclado_fin
cont
	LDR r1,=pausita
	ldrb r3,[r1]
	cmp r3,#1
	beq creditos_tec
	cmp r2,#81 ;Tecla Q hace que finalice el juego
	bne mas
	LDR r1,=fin
	mov r2,#1
	strb r2,[r1]

mas
	cmp r2,#11
	bne menos
	LDR r1,=max
	ldr r0,[r1]
	cmp r0,#1
	beq teclado_fin
	mov r3,#0
	add r3,r3,r0,LSR #1
	str r3,[r1]
	b teclado_fin
	
menos
	cmp r2,#13
	bne sigue
	LDR r1,=max
	ldr r0,[r1]
	cmp r0,#128
	beq teclado_fin
	mov r3,#0
	add r3,r3,r0,LSL #1
	str r3,[r1]
	b teclado_fin

creditos_tec
	cmp r2,#67
	bne teclado_fin
	LDR r0,=credits
	mov r1,#1
	strb r1,[r0]
	b teclado_fin
	
sigue	
	LDR r1, =tecla_pulsada
	str r2, [r1]

teclado_fin 
	mrs r1,cpsr
	orr r1,r1,#I_Bit
	msr cpsr_cxsf,r1
	
	pop {r0,r1,r2,r3}
	pop {r14}
	msr spsr_cxsf, r14
	ldr r14,=VICVectAddr
	str r14, [r14]
	pop {pc}^
;---------------------------------------------------------------------------------------------------------------------------------------------------------


;TIMER
;---------------------------------------------------------------------------------------------------------------------------------------------------------
RSI_timer 
	sub lr, lr, #4
	push{lr}
	mrs	r14, spsr
	push{r14}
	push{r0,r1}
	mrs r1,cpsr
	bic r1,r1,#I_Bit
	msr cpsr_c, r1
	ldr r0,=T0_IR
	mov r1,#1
	str r1,[r0]
	
	LDR r0,=pausita
	ldrb r0,[r0]
	cmp r0,#1
	beq ZA_WARUDO
	
	ldr r0,=contador
	ldr r1, [r0]
	add r1,r1,#1
	str r1,[r0]

ZA_WARUDO
	mrs r1,cpsr
	orr r1,r1,#I_Bit
	msr cpsr_cxsf,r1
	
	pop {r0,r1}
	pop {r14}
	msr spsr_cxsf, r14
	ldr r14,=VICVectAddr
	str r14, [r14]
	pop {pc}^
;---------------------------------------------------------------------------------------------------------------------------------------------------------	
	
	END	