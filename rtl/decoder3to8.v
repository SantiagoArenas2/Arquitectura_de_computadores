// decoder3to8.v
// Decodificador 3 a 8 en codificacion one-hot.
//
// Convierte el codigo de operacion de 3 bits en 8 lineas de las cuales
// exactamente UNA vale 1. Esa linea habilita despues el resultado
// correspondiente en el multiplexor de operacion.
//
//   op = 000  ->  sel = 00000001   (reinicio)
//   op = 001  ->  sel = 00000010   (suma)
//   op = 010  ->  sel = 00000100   (resta)
//   op = 011  ->  sel = 00001000   (resta inversa)
//   op = 100  ->  sel = 00010000   (shift left)
//   op = 101  ->  sel = 00100000   (shift right)
//   op = 110  ->  sel = 01000000   (no usado)
//   op = 111  ->  sel = 10000000   (no usado)
//
// Cada salida es un unico minterm: el producto de las tres entradas,
// negadas donde corresponde. El mapa de Karnaugh de cada salida tiene
// un solo 1 aislado, por lo que no admite simplificacion.

module decoder3to8 (
    input  wire [2:0] op,
    output wire [7:0] sel
);

    wire n2, n1, n0;   // versiones negadas de cada bit del opcode

    not u_n2 (n2, op[2]);
    not u_n1 (n1, op[1]);
    not u_n0 (n0, op[0]);

    //         salida     op2     op1     op0
    and u_s0 (sel[0],     n2,     n1,     n0     );
    and u_s1 (sel[1],     n2,     n1,     op[0]  );
    and u_s2 (sel[2],     n2,     op[1],  n0     );
    and u_s3 (sel[3],     n2,     op[1],  op[0]  );
    and u_s4 (sel[4],     op[2],  n1,     n0     );
    and u_s5 (sel[5],     op[2],  n1,     op[0]  );
    and u_s6 (sel[6],     op[2],  op[1],  n0     );
    and u_s7 (sel[7],     op[2],  op[1],  op[0]  );

endmodule
