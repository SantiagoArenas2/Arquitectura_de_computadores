// decoder4to16.v
// Decodificador 4 a 16 en codificacion one-hot.
//
// Genera los 16 minterms de una entrada de 4 bits: la salida m[k]
// vale 1 unicamente cuando v = k.
//
// Es la misma idea del decoder3to8, extendida a cuatro variables.
// Se usa como base del decodificador de siete segmentos: cada
// segmento se obtiene como un OR de los minterms en que ese segmento
// debe estar encendido (forma canonica de suma de productos).

module decoder4to16 (
    input  wire [3:0]  v,
    output wire [15:0] m
);

    wire n3, n2, n1, n0;

    not u_n3 (n3, v[3]);
    not u_n2 (n2, v[2]);
    not u_n1 (n1, v[1]);
    not u_n0 (n0, v[0]);

    and u_m00 (m[0],  n3,   n2,   n1,   n0  );
    and u_m01 (m[1],  n3,   n2,   n1,   v[0]);
    and u_m02 (m[2],  n3,   n2,   v[1], n0  );
    and u_m03 (m[3],  n3,   n2,   v[1], v[0]);
    and u_m04 (m[4],  n3,   v[2], n1,   n0  );
    and u_m05 (m[5],  n3,   v[2], n1,   v[0]);
    and u_m06 (m[6],  n3,   v[2], v[1], n0  );
    and u_m07 (m[7],  n3,   v[2], v[1], v[0]);
    and u_m08 (m[8],  v[3], n2,   n1,   n0  );
    and u_m09 (m[9],  v[3], n2,   n1,   v[0]);
    and u_m10 (m[10], v[3], n2,   v[1], n0  );
    and u_m11 (m[11], v[3], n2,   v[1], v[0]);
    and u_m12 (m[12], v[3], v[2], n1,   n0  );
    and u_m13 (m[13], v[3], v[2], n1,   v[0]);
    and u_m14 (m[14], v[3], v[2], v[1], n0  );
    and u_m15 (m[15], v[3], v[2], v[1], v[0]);

endmodule
