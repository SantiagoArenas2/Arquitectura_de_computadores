// reg4.v
// Registro de 4 bits con habilitacion de carga.
//
// Es el unico elemento con memoria de la calculadora: almacena el
// resultado de la ultima operacion ejecutada.
//
// COMPORTAMIENTO
//
//   load = 1  ->  en el proximo flanco de subida, q toma el valor d
//   load = 0  ->  q conserva su valor
//
// COMO SE EVITA EL "if"
//
// El enunciado prohibe usar if. En vez de escribir
//
//     if (load) q <= d;          <-- NO permitido
//
// se coloca un multiplexor ANTES del flip-flop:
//
//     next = load ? d : q
//     q <= next                  <-- siempre carga
//
// Cuando load = 0 el registro se recarga con su propio valor, por lo
// que el contenido no cambia. El flip-flop carga en todos los
// flancos; lo que se controla es QUE carga. El multiplexor es el
// mismo mux2_4bit ya disenado con compuertas.
//
// Notar que el always con posedge no viola la restriccion del
// enunciado: la restriccion aplica a la logica COMBINACIONAL, y un
// flip-flop no se puede construir con las primitivas permitidas.

module reg4 (
    input  wire       clk,
    input  wire       load,
    input  wire [3:0] d,
    output reg  [3:0] q
);

    wire [3:0] next;

    // next = load ? d : q
    mux2_4bit u_mux (
        .i0 (q),      // load = 0 -> se recarga a si mismo
        .i1 (d),      // load = 1 -> toma el dato nuevo
        .s  (load),
        .y  (next)
    );

    // Valor inicial del registro al encender la FPGA.
    // Yosys lo traduce al valor de inicializacion de los flip-flops
    // de la iCE40, y ademas hace que la simulacion coincida con el
    // comportamiento real de la placa (sin esto, en simulacion el
    // registro arrancaria en X).
    initial q = 4'b0000;

    always @(posedge clk) begin
        q <= next;
    end

endmodule
