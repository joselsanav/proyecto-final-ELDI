`timescale 1ns / 1ps

module cpu_prueba_tb;

reg clok = 0;
reg reset = 1;

wire [5:0] color_video;
wire [31:0] pc_observado;

cpu_prueba dut (
    .clok(clok),
    .reset(reset),
    .color_video(color_video),
    .pc_observado(pc_observado)
);

always #5 clok = ~clok;

initial begin

    #2;
    reset = 0;

    #10;
    reset = 1;

    // Ejecutar el programa
    #140;

    // Comprobar LUI
    if (dut.banco_registros.registros[1] !== 32'h40000000)
        $fatal(1, "ERROR: LUI no escribio x1");

    $display("OK: LUI");


    // Comprobar ADDI
    if (dut.banco_registros.registros[2] !== 32'd48)
        $fatal(1, "ERROR: ADDI no escribio x2");

    $display("OK: ADDI");


    // Comprobar escritura de video
    if (color_video !== 6'b110000)
        $fatal(1, "ERROR: escritura de video incorrecta");

    $display("OK: CPU escribio el color rojo");
    $display("CPU: PRIMERA PRUEBA DE INTEGRACION SUPERADA");

    $finish;

end

endmodule