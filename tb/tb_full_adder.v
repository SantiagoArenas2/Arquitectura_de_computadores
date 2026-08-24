// tb_full_adder.v
// Testbench del sumador completo de 1 bit.
//
// OJO: las restricciones del enunciado (nada de +, if, case, etc.)
// aplican al CIRCUITO, no al testbench. Aqui puedes usar todo el
// Verilog que quieras, porque este codigo nunca se sintetiza:
// solo corre en el simulador.

`timescale 1ns / 1ps

module tb_full_adder;

    // Entradas del circuito -> reg, porque el testbench las maneja
    reg  a, b, cin;
    // Salidas del circuito -> wire, porque las maneja el circuito
    wire sum, cout;

    integer i;

    // Instancia del modulo bajo prueba (DUT: Device Under Test)
    full_adder dut (
        .a    (a),
        .b    (b),
        .cin  (cin),
        .sum  (sum),
        .cout (cout)
    );

    initial begin
        // Le dice al simulador donde escribir el archivo de ondas
        $dumpfile("build/tb_full_adder.vcd");
        // El 0 significa "graba esta jerarquia completa, con submodulos"
        $dumpvars(0, tb_full_adder);

        $display("");
        $display("  a  b cin | cout sum   esperado");
        $display("  ---------+------------------- ");

        // Recorre las 8 combinaciones posibles de entrada
        for (i = 0; i < 8; i = i + 1) begin
            {a, b, cin} = i[2:0];
            #10;  // espera 10 ns a que la logica se estabilice
            $display("  %b  %b  %b  |  %b   %b       %0d",
                     a, b, cin, cout, sum, a + b + cin);
        end

        $display("");
        #10 $finish;
    end

endmodule
