// edge_detect.v
// Detector de flanco de subida.
//
// Convierte un nivel sostenido en un pulso de exactamente un ciclo
// de reloj.
//
// POR QUE ES NECESARIO
// El antirrebote entrega un NIVEL: vale 1 mientras el boton este
// presionado. Si eso alimentara directamente a la maquina de estados,
// mantener el boton apretado un segundo generaria 25 millones de
// confirmaciones y la FSM recorreria todos sus estados en un
// instante.
//
// COMO FUNCIONA
// Se guarda el valor del ciclo anterior en un flip-flop y se compara
// con el actual:
//
//   pulse = level AND NOT prev
//
// Eso vale 1 unicamente en el ciclo donde la senal paso de 0 a 1.
// Mientras el boton siga presionado, prev tambien vale 1 y el pulso
// se apaga solo.

module edge_detect (
    input  wire clk,
    input  wire level,
    output wire pulse
);

    reg  prev;
    wire nprev;

    not u_not (nprev, prev);
    and u_and (pulse, level, nprev);

    initial prev = 1'b0;

    always @(posedge clk) begin
        prev <= level;
    end

endmodule
