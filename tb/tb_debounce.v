// tb_debounce.v
// Testbench del antirrebote y el detector de flanco.
//
// Simula un boton real: al presionarlo la senal rebota varias veces
// antes de estabilizarse. Se verifica que:
//
//   1) la salida limpia NO reacciona a los rebotes
//   2) se genera exactamente UN pulso por presion
//
// Se usa N = 3 en el tick_gen para que el tick llegue cada 8 ciclos
// y la simulacion sea corta. En la placa se usa N = 15.

`timescale 1ns / 1ps

module tb_debounce;

    reg  clk;
    reg  boton;      // senal cruda, con rebotes
    wire tick;
    wire limpio;
    wire pulso;

    integer pulsos;

    tick_gen #(.N(3)) u_tick (
        .clk  (clk),
        .tick (tick)
    );

    debounce u_deb (
        .clk   (clk),
        .tick  (tick),
        .noisy (boton),
        .clean (limpio)
    );

    edge_detect u_edge (
        .clk   (clk),
        .level (limpio),
        .pulse (pulso)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Cuenta los pulsos generados
    always @(posedge clk) begin
        if (pulso) pulsos = pulsos + 1;
    end

    // Simula una presion con rebotes y luego estabilidad
    task presionar;
        integer r;
        begin
            $display("    -> presionando (con rebotes)");
            for (r = 0; r < 6; r = r + 1) begin
                boton = 1'b1; #17;
                boton = 1'b0; #13;
            end
            boton = 1'b1;
            #600;               // se mantiene estable
        end
    endtask

    task soltar;
        integer r;
        begin
            $display("    -> soltando (con rebotes)");
            for (r = 0; r < 6; r = r + 1) begin
                boton = 1'b0; #15;
                boton = 1'b1; #11;
            end
            boton = 1'b0;
            #600;
        end
    endtask

    initial begin
        $dumpfile("build/tb_debounce.vcd");
        $dumpvars(0, tb_debounce);

        boton  = 1'b0;
        pulsos = 0;
        #200;

        $display("");
        $display("  === Primera presion ===");
        presionar;
        $display("     pulsos acumulados: %0d", pulsos);
        soltar;

        $display("");
        $display("  === Segunda presion ===");
        presionar;
        $display("     pulsos acumulados: %0d", pulsos);
        soltar;

        $display("");
        $display("  === Tercera presion ===");
        presionar;
        $display("     pulsos acumulados: %0d", pulsos);
        soltar;

        $display("");
        if (pulsos == 3)
            $display("  RESULTADO: 3 presiones -> 3 pulsos. Correcto.");
        else
            $display("  RESULTADO: 3 presiones -> %0d pulsos. Revisar.", pulsos);
        $display("");

        #100 $finish;
    end

endmodule
