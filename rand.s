;/*****************************************************************************/ 
;/* Carlos Jose Perez Jimenez 
;/* Mayo 2014 
;/* 
;/* Implementacion de un generador de numeros pseudo-aleatorios de 31 bits
;/* Es el generador en congruencias lineales 
;/* x_n = 1103515245 * x_{n-1} + 12345 mod 2^31
;/* 
;/* Se compone de dos SBR
;/* srand -> inicializa la semilla (rand_x) del generador
;/*		Sin resultados
;/*		Un parametro por valor (semilla) en la pila
;/*
;/* rand  -> genera a partir de un numero aleatorio (rand_x) otro en la misma variable (rand_x) 
;/*		Resultado rand_x en la  pila
;/*		Sin parametros

				AREA datos,DATA
rand_x			DCD 0
rand_a			DCD 1103515245
rand_c			DCD 12345

				AREA codigo,CODE
				EXPORT srand
				EXPORT rand

srand			PUSH {r11,lr}
				mov fp,sp
				PUSH {r0,r1}
				ldr r0,[fp,#8]
				LDR r1,=rand_x
				str r0,[r1]
				POP {r0,r1,r11,pc}

rand			PUSH {r11,lr}
				mov fp,sp
				PUSH {r0-r3}
				LDR r1,=rand_x
				LDR r2,=rand_a
				ldr r0,[r1]
				ldr r3,[r2]
				mul r0,r3,r0
				LDR r2,=rand_c
 				ldr r3,[r2]
				add r0,r0,r3
				bic r0,r0,#0x80000000
				str r0,[r1]
				str r0,[fp,#8]
				POP {r0-r3,r11,pc}
				END