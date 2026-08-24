// ctrl_decode.v
// Genera las senales de control del sumador/restador a partir del
// codigo de operacion.
//
// Tabla de verdad:
//
//   opcode | operacion       | inv_a inv_b cin
//   -------+-----------------+----------------
//    000   | reinicio        |   0     0    0
//    001   | suma            |   0     0    0
//    010   | resta           |   0     1    1
//    011   | resta inversa   |   1     0    1
//    100   | shift left      |   0     0    0
//    101   | shift right     |   0     0    0
//    110   | no usado        |   0     0    0
//    111   | no usado        |   0     0    0
//
// Expresiones obtenidas de los mapas de Karnaugh:
//
//   inv_a = ~op2 AND op1 AND  op0     (solo minterm 011)
//   inv_b = ~op2 AND op1 AND ~op0     (solo minterm 010)
//   cin   = ~op2 AND op1              (agrupa 010 y 011: op0 se elimina)
//
// El termino t = ~op2 AND op1 es comun a las tres, asi que se calcula
// una sola vez. Total: 2 NOT y 3 AND.
//
// Notar que inv_a e inv_b nunca valen 1 al mismo tiempo: no tiene
// sentido negar ambos operandos.

module ctrl_decode (
    input  wire [2:0] op,
    output wire       inv_a,
    output wire       inv_b,
    output wire       cin
);

    wire n2;   // ~op2
    wire n0;   // ~op0
    wire t;    // ~op2 AND op1  -> vale 1 para los opcodes 010 y 011

    not u_n2 (n2, op[2]);
    not u_n0 (n0, op[0]);

    and u_t  (t, n2, op[1]);

    and u_ia (inv_a, t, op[0]);   // 011 -> resta inversa
    and u_ib (inv_b, t, n0);      // 010 -> resta

    buf u_ci (cin, t);            // cin = t para ambas restas

endmodule
