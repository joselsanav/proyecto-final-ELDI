# Proyecto ELDI — Procesador RISC-V RV32I con VGA

**Integrantes:** Juan Felipe Cubillos Marín y José Luis Sana Vásquez  
**Asignatura:** Electrónica Digital — Escuela Colombiana de Ingeniería Julio Garavito

## Descripción

Proyecto en Verilog para la FPGA **Basys 3**. Integra una CPU RISC-V RV32I segmentada en cinco etapas, memorias de instrucciones y datos, un periférico gráfico y un controlador **VGA de 640 × 480**. El programa incluido dibuja un rectángulo rojo sobre fondo azul.

## Estructura del repositorio

```text
├── vivado/       Proyecto de Vivado, código Verilog, testbenches y restricciones
├── docs/         Informe, diagramas y reportes
├── bitstream/    Archivo .bit generado para la Basys 3
└── README.md     Instrucciones para reproducir el proyecto
```

## Cómo reproducir el proyecto

### 1. Abrirlo en Vivado

1. Descarga el repositorio como ZIP desde GitHub y descomprímelo, o clónalo.
2. Abre **Vivado 2026.1**.
3. Selecciona **File > Project > Open** y abre `vivado/pc_proyetofinal.xpr`.
4. Comprueba que el dispositivo seleccionado sea `xc7a35tcpg236-1` (Basys 3) y que el módulo superior de diseño sea `top_cpu_vga_basys3`.

### 2. Ejecutar la simulación principal

1. En **Simulation Sources**, selecciona `tb_programa_rectangulo` como **Simulation Top**.
2. Haz clic en **Run Simulation > Run Behavioral Simulation**.
3. En la consola Tcl de Vivado, ejecuta `run all` para completar la prueba.
4. Si todo funciona, el testbench debe mostrar `PRUEBA RECTANGULO EXITOSA` y `Errores: 0`.

**Importante:** la CPU carga el programa desde `programa.mem`, ubicado en `vivado/pc_proyetofinal.srcs/sources_1/imports/PROYECTO FINAL/`. Si la ROM no encuentra el archivo después de mover el proyecto, revisa su inclusión en las fuentes de Vivado.

### 3. Programar la FPGA y ver la salida VGA

1. Conecta la **Basys 3** al computador y a un monitor por VGA.
2. En Vivado, utiliza **Run Synthesis > Run Implementation > Generate Bitstream**, si necesitas generar de nuevo el archivo `.bit`.
3. Abre **Hardware Manager > Open Target > Program Device** y selecciona el bitstream generado. También se incluye uno de referencia en `bitstream/top_cpu_vga_basys3.bit`.
4. Comprueba la imagen en el monitor. El botón central **BTNC** actúa como reset.

## Otras pruebas

En `vivado/pc_proyetofinal.srcs/sim_1/` hay testbenches de la CPU, el periférico gráfico y la temporización VGA. Algunas pruebas usan un programa distinto, así que revisa cuál requiere cada una antes de ejecutarla.

