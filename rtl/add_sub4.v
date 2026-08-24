// add_sub4.v
// Sumador / restador de 4 bits en complemento a dos.
//
// Un solo circuito realiza las tres operaciones aritmeticas:
//
//   inv_a inv_b cin | resultado
//   ----------------+-------------------------
//     0     0    0  | A + B          (suma)
//     0     1    1  | A + ~B + 1 = A - B
//     1     0    1  | ~A + B + 1 = B - A
//
// ESTRUCTURA
//
//   1) Inversion condicional: cada bit pasa por un XOR con su senal
//      de control. XOR con 0 deja el bit intacto, XOR con 1 lo
//      invierte. Es un inversor que se puede encender y apagar.
//
//   2) Cadena de acarreo (ripple carry): cuatro full adders donde el
//      cout de cada uno alimenta el cin del siguiente, igual que
//      cuando uno suma a mano y "se lleva una".
//
//   3) El "+1" del complemento a dos entra por cin del primer full
//      adder, sin necesidad de hardware adicional.
//
// El cout final se expone para depuracion, pero la calculadora lo
// descarta: el enunciado indica conservar solo los cuatro bits menos
// significativos en caso de overflow.

module add_sub4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       inv_a,
    input  wire       inv_b,
    input  wire       cin,
    output wire [3:0] s,
    output wire       cout
);

    wire [3:0] ax;   // a despues de la inversion condicional
    wire [3:0] bx;   // b despues de la inversion condicional
    wire [2:0] c;    // acarreos internos entre etapas

    // --- Etapa 1: inversores programables ---
    xor u_xa0 (ax[0], a[0], inv_a);
    xor u_xa1 (ax[1], a[1], inv_a);
    xor u_xa2 (ax[2], a[2], inv_a);
    xor u_xa3 (ax[3], a[3], inv_a);

    xor u_xb0 (bx[0], b[0], inv_b);
    xor u_xb1 (bx[1], b[1], inv_b);
    xor u_xb2 (bx[2], b[2], inv_b);
    xor u_xb3 (bx[3], b[3], inv_b);

    // --- Etapa 2: cadena de cuatro full adders ---
    full_adder u_fa0 (
        .a(ax[0]), .b(bx[0]), .cin(cin),
        .sum(s[0]), .cout(c[0])
    );

    full_adder u_fa1 (
        .a(ax[1]), .b(bx[1]), .cin(c[0]),
        .sum(s[1]), .cout(c[1])
    );

    full_adder u_fa2 (
        .a(ax[2]), .b(bx[2]), .cin(c[1]),
        .sum(s[2]), .cout(c[2])
    );

    full_adder u_fa3 (
        .a(ax[3]), .b(bx[3]), .cin(c[2]),
        .sum(s[3]), .cout(cout)
    );

endmodule
