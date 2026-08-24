# Proyecto 1 — Calculadora de 4 bits

Arquitectura de Computadores · Universidad de los Andes · Semestre 2026-2
Profesor: Jorge Gómez Mir

**Integrantes:**
- [José Tomás Arévalo]
- [Santiago Arenas]
- [Danna Collazos]

---

## Descripción

Calculadora de 4 bits con soporte para números negativos en complemento a dos,
descrita en Verilog e implementada sobre una FPGA Lattice iCE40 HX1K
(Nandland Go Board).

Toda la lógica combinacional está construida **exclusivamente con primitivas de
compuerta** (`and`, `or`, `not`, `xor`, `nand`, `nor`, `xnor`, `buf`), sin usar
operadores de alto nivel de Verilog.

## Operaciones soportadas

| Código  | Operación      | Resultado           |
|---------|----------------|---------------------|
| `3'b000`| Reinicio       | `R = 4'b0000`       |
| `3'b001`| Suma           | `R = A + B`         |
| `3'b010`| Resta          | `R = A - B`         |
| `3'b011`| Resta inversa  | `R = B - A`         |
| `3'b100`| Shift left     | `R = A << B[1:0]`   |
| `3'b101`| Shift right    | `R = A >> B[1:0]`   |
| `3'b110`| No usado       | `R = 4'b0000`       |
| `3'b111`| No usado       | `R = 4'b0000`       |

Todos los cálculos son de 4 bits. En caso de overflow se conservan únicamente
los cuatro bits menos significativos.

## Requisitos

- [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build) — incluye
  Yosys, nextpnr-ice40, icepack, iceprog, Icarus Verilog y GTKWave.
- GNU Make.
- Nandland Go Board (solo para la implementación en hardware).

Antes de correr cualquier comando hay que activar el entorno:

```bash
# Linux / macOS
source <ruta>/oss-cad-suite/environment

# Windows: ejecutar start.bat dentro de la carpeta oss-cad-suite
```

## Estructura del repositorio

```
rtl/          Módulos del circuito (sintetizables)
tb/           Testbenches (solo simulación)
docs/         Informe en PDF
build/        Archivos generados (no versionados)
goboard.pcf   Asignación de pines de la Go Board
Makefile      Automatización del flujo
```

## Cómo simular

```bash
make sim TB=tb_calc_core     # compila y ejecuta el testbench
make wave TB=tb_calc_core    # abre las formas de onda en GTKWave
```

Para probar otros módulos por separado, cambiar el valor de `TB`:

```bash
make sim TB=tb_full_adder
make sim TB=tb_alu4
```

Los valores y operaciones a evaluar se modifican en el bloque `initial` de
`tb/tb_calc_core.v`.

## Cómo programar la FPGA

Con la Go Board conectada por USB:

```bash
make prog
```

Esto ejecuta la cadena completa: síntesis con Yosys, place & route con
nextpnr-ice40, generación del bitstream con icepack y grabado con iceprog.

Comandos auxiliares:

```bash
make stats    # uso de recursos de la FPGA
make clean    # borra los archivos generados
```

## Uso en la placa

| Botón              | Función                                          |
|--------------------|--------------------------------------------------|
| Superior izquierdo | Incrementa el valor                              |
| Inferior izquierdo | Disminuye el valor                               |
| Superior derecho   | Confirma / ejecuta                               |
| Inferior derecho   | Usa el resultado anterior como segundo operando  |

**Secuencia de operación:**

1. Se ingresa el código de operación, que se muestra en los LEDs de la placa.
2. Se ingresa el primer operando, visible en el display de siete segmentos
   (display izquierdo: signo; display derecho: valor en hexadecimal).
3. Se ingresa el segundo operando, o se presiona el botón inferior derecho para
   reutilizar el resultado anterior.
4. Al confirmar, la calculadora ejecuta la operación y muestra el resultado.
5. Presionando nuevamente el botón superior derecho se vuelve al estado inicial.

## Informe

El informe con el diseño general, las tablas de verdad, los mapas de Karnaugh,
las expresiones booleanas y la implementación mediante compuertas se encuentra
en [`docs/informe.pdf`](docs/informe.pdf).

## Referencias

- Restricciones de pines adaptadas del
  [Pochoco SoC](https://github.com/nic0villegasc/pochoco_soc) de Nicolás Villegas.
