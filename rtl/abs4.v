// abs4.v
// Calcula el valor absoluto de un numero de 4 bits en complemento
// a dos, para mostrarlo en el display de siete segmentos.
//
// EL PROBLEMA QUE RESUELVE
//
// El display de signo indica si el numero es negativo, pero el
// display de valor mostraba los cuatro bits crudos en hexadecimal.
// Eso produce lecturas sin sentido:
//
//   valor  bits   hex crudo   se leia
//   -----  ----   ---------   -------
//    -4    1100       C         "-C"
//    -7    1001       9         "-9"
//    -8    1000       8         "-8"
//
// Mostrando la magnitud, la lectura pasa a ser "-4", "-7" y "-8",
// que es como se escribe un numero negativo.
//
// COMO FUNCIONA
//
// Negar en complemento a dos es invertir los bits y sumar uno, que
// es exactamente lo que hace add_sub4 con inv_a = 1 y cin = 1. Y con
// inv_a = 0 y cin = 0 el numero pasa intacto. Como el segundo
// operando es la constante 0000, el modulo se reduce a:
//
//   v[3] = 0  ->  mag = v + 0     = v
//   v[3] = 1  ->  mag = ~v + 0 + 1 = -v
//
// Una sola senal, el bit de signo, controla ambos casos. Es la
// tercera reutilizacion del mismo sumador en el proyecto.
//
// CASO LIMITE
// El valor -8 (1000) negado da 1000 otra vez, porque +8 no es
// representable con 4 bits en complemento a dos. El display muestra
// "8", que es la magnitud correcta.

module abs4 (
    input  wire [3:0] v,
    output wire [3:0] mag
);

    wire cout;

    add_sub4 u_neg (
        .a     (v),
        .b     (4'b0000),
        .inv_a (v[3]),      // invierte A solo si el numero es negativo
        .inv_b (1'b0),
        .cin   (v[3]),      // el "+1" del complemento a dos
        .s     (mag),
        .cout  (cout)
    );

endmodule
