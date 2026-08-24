// tb_selector.v
// Testbench del decodificador 3 a 8 y del multiplexor 8 a 1,
// probados JUNTOS, que es como se usan en la calculadora.
//
// Se conecta la salida del decodificador directamente al selector
// del mux, se le meten ocho datos distintos y reconocibles, y se
// verifica que para cada opcode salga el dato correspondiente.

`timescale 1ns / 1ps

module tb_selector;

    reg  [2:0] op;
    wire [7:0] sel;
    wire [3:0] y;

    // Ocho datos distintos, para poder identificar cual salio
    wire [3:0] d0 = 4'h0;
    wire [3:0] d1 = 4'h1;
    wire [3:0] d2 = 4'h2;
    wire [3:0] d3 = 4'h3;
    wire [3:0] d4 = 4'h4;
    wire [3:0] d5 = 4'h5;
    wire [3:0] d6 = 4'h6;
    wire [3:0] d7 = 4'h7;

    integer i;
    integer errores;

    decoder3to8 u_dec (
        .op  (op),
        .sel (sel)
    );

    mux8_4bit u_mux (
        .d0(d0), .d1(d1), .d2(d2), .d3(d3),
        .d4(d4), .d5(d5), .d6(d6), .d7(d7),
        .sel(sel),
        .y  (y)
    );

    initial begin
        $dumpfile("build/tb_selector.vcd");
        $dumpvars(0, tb_selector);

        errores = 0;

        $display("");
        $display("  op  |   sel      |  y   esperado");
        $display("  ----+------------+--------------");

        for (i = 0; i < 8; i = i + 1) begin
            op = i[2:0];
            #10;
            $display("  %b |  %b  |  %h      %h", op, sel, y, i[3:0]);

            // Verificacion 1: el dato que sale es el correcto
            if (y !== i[3:0]) errores = errores + 1;

            // Verificacion 2: sel es realmente one-hot.
            // $countones cuenta los bits en 1; debe haber exactamente uno.
            if (sel !== (8'b1 << i)) begin
                $display("        ERROR: sel no es one-hot para op = %b", op);
                errores = errores + 1;
            end
        end

        $display("");
        if (errores == 0)
            $display("  RESULTADO: todas las pruebas pasaron.");
        else
            $display("  RESULTADO: %0d prueba(s) fallaron.", errores);
        $display("");

        #10 $finish;
    end

endmodule
