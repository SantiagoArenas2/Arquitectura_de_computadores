// tb_mux2.v
// Testbench de mux2_1bit y mux2_4bit.
//
// El mux de 1 bit se prueba de forma exhaustiva: las 8 combinaciones
// posibles de (s, i1, i0). El de 4 bits se prueba con algunos vectores
// representativos, porque probar las 512 combinaciones no aporta nada
// si el bloque de 1 bit ya esta verificado.

`timescale 1ns / 1ps

module tb_mux2;

    // --- mux de 1 bit ---
    reg  i0, i1, s;
    wire y;

    // --- mux de 4 bits ---
    reg  [3:0] a, b;
    reg        sel;
    wire [3:0] out;

    integer i;
    integer errores;

    mux2_1bit dut1 (.i0(i0), .i1(i1), .s(s), .y(y));
    mux2_4bit dut4 (.i0(a),  .i1(b),  .s(sel), .y(out));

    initial begin
        $dumpfile("build/tb_mux2.vcd");
        $dumpvars(0, tb_mux2);

        errores = 0;

        $display("");
        $display("  === mux2_1bit (exhaustivo) ===");
        $display("   s i1 i0 | y  esperado");
        $display("   --------+-----------");

        for (i = 0; i < 8; i = i + 1) begin
            {s, i1, i0} = i[2:0];
            #10;
            $display("   %b  %b  %b | %b     %b", s, i1, i0, y, s ? i1 : i0);
            if (y !== (s ? i1 : i0)) errores = errores + 1;
        end

        $display("");
        $display("  === mux2_4bit ===");
        $display("   sel   i0    i1   |  y");
        $display("   -----------------+------");

        a = 4'b1010; b = 4'b0101; sel = 1'b0; #10;
        $display("    %b   %b  %b | %b", sel, a, b, out);
        if (out !== a) errores = errores + 1;

        sel = 1'b1; #10;
        $display("    %b   %b  %b | %b", sel, a, b, out);
        if (out !== b) errores = errores + 1;

        a = 4'b1111; b = 4'b0000; sel = 1'b0; #10;
        $display("    %b   %b  %b | %b", sel, a, b, out);
        if (out !== a) errores = errores + 1;

        sel = 1'b1; #10;
        $display("    %b   %b  %b | %b", sel, a, b, out);
        if (out !== b) errores = errores + 1;

        $display("");
        if (errores == 0)
            $display("  RESULTADO: todas las pruebas pasaron.");
        else
            $display("  RESULTADO: %0d prueba(s) fallaron.", errores);
        $display("");

        #10 $finish;
    end

endmodule
