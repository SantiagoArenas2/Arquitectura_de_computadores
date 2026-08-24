// tb_calc_top.v
// Testbench del modulo de nivel superior.
//
// Simula presiones REALES de los botones, con rebote mecanico
// incluido, y verifica que la calculadora complete una operacion.
// Es la prueba mas cercana a lo que ocurrira en la placa.
//
// Para que la simulacion sea corta se sobreescribe el parametro N
// del tick_gen mediante defparam, de modo que el tick llegue cada
// 8 ciclos en vez de cada 32768.

`timescale 1ns / 1ps

module tb_calc_top;

    reg        clk;
    reg  [3:0] sw;
    wire [3:0] led;

    wire s1a, s1b, s1c, s1d, s1e, s1f, s1g;
    wire s2a, s2b, s2c, s2d, s2e, s2f, s2g;

    calc_top dut (
        .i_Clk    (clk),
        .i_Switch (sw),
        .o_LED    (led),
        .o_Segment1_A(s1a), .o_Segment1_B(s1b), .o_Segment1_C(s1c),
        .o_Segment1_D(s1d), .o_Segment1_E(s1e), .o_Segment1_F(s1f),
        .o_Segment1_G(s1g),
        .o_Segment2_A(s2a), .o_Segment2_B(s2b), .o_Segment2_C(s2c),
        .o_Segment2_D(s2d), .o_Segment2_E(s2e), .o_Segment2_F(s2f),
        .o_Segment2_G(s2g)
    );

    // Acorta el tick para que la simulacion no dure una eternidad
    defparam dut.u_tick.N = 3;

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ---- Simula una presion de boton con rebote ----
    task presionar;
        input integer idx;
        integer r;
        begin
            for (r = 0; r < 4; r = r + 1) begin
                sw[idx] = 1'b1; #17;
                sw[idx] = 1'b0; #13;
            end
            sw[idx] = 1'b1;
            #500;                 // se mantiene presionado
            for (r = 0; r < 4; r = r + 1) begin
                sw[idx] = 1'b0; #15;
                sw[idx] = 1'b1; #11;
            end
            sw[idx] = 1'b0;
            #500;                 // se suelta
        end
    endtask

    task presionar_n;
        input integer idx;
        input integer n;
        integer k;
        begin
            for (k = 0; k < n; k = k + 1) presionar(idx);
        end
    endtask

    task estado;
        input [8*24:1] etiqueta;
        begin
            $display("  %0s | LED=%b st=%b disp=%b  seg2=%b%b%b%b%b%b%b  signo=%b",
                     etiqueta, led, dut.estado, dut.disp_val,
                     s2a, s2b, s2c, s2d, s2e, s2f, s2g, s1g);
        end
    endtask

    initial begin
        $dumpfile("build/tb_calc_top.vcd");
        $dumpvars(0, tb_calc_top);

        sw = 4'b0000;
        #300;

        $display("");
        $display("  === Sesion completa: 6 - 2 ===");
        estado("inicio                ");

        // ST_OP: subir dos veces para llegar al opcode 010 (resta)
        presionar_n(0, 2);
        estado("opcode = resta        ");

        presionar(2);
        estado("-> ingreso operando A ");

        // ST_A: subir seis veces
        presionar_n(0, 6);
        estado("A = 6                 ");

        presionar(2);
        estado("-> ingreso operando B ");

        // ST_B: subir dos veces
        presionar_n(0, 2);
        estado("B = 2                 ");

        presionar(2);
        estado("-> resultado          ");

        if (dut.result === 4'd4)
            $display("");
        else
            $display("  ATENCION: se esperaba 0100 y se obtuvo %b", dut.result);

        presionar(2);
        estado("-> vuelta al inicio   ");

        $display("");
        $display("  Nota: seg2 = pines del display de valor (0 = encendido)");
        $display("        signo = segmento g del display izquierdo");
        $display("");

        #100 $finish;
    end

endmodule
