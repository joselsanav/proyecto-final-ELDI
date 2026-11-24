`timescale 1ns / 1ps

module tb_top_cpu_basys3;

reg clok;
reg btnC;

wire [15:0] led;

reg escritura_detectada;
integer cantidad_escrituras;

// ==========================================
// INSTANCIA DEL SISTEMA
// ==========================================

top_cpu_basys3 dut (
    .clok(clok),
    .btnC(btnC),
    .led(led)
);

// ==========================================
// RELOJ DE 100 MHz
// ==========================================

initial clok = 1'b0;

always #5 clok = ~clok;

// ==========================================
// MONITOREO DEL BUS VGA TEMPORAL
// ==========================================

initial begin
    escritura_detectada = 1'b0;
    cantidad_escrituras = 0;
end

always @(posedge clok) begin

    if (!btnC && dut.escribir_video) begin

        escritura_detectada = 1'b1;
        cantidad_escrituras = cantidad_escrituras + 1;

        $display("Escritura de video detectada");
        $display("Direccion = %h", dut.direccion_video);
        $display("Dato = %h", dut.dato_escritura_video);
        $display("Bytes = %b", dut.habilitar_bytes_video);

        if (
            dut.direccion_video !== 32'h40000000 ||
            dut.dato_escritura_video !== 32'h00000030 ||
            dut.habilitar_bytes_video !== 4'b1111
        ) begin

            $display("ERROR: Escritura incorrecta");
            $stop;

        end

    end

end

// ==========================================
// SECUENCIA DE PRUEBA
// ==========================================

initial begin

    btnC = 1'b1;

    // Mantener reset durante tres ciclos
    repeat (3) @(negedge clok);

    btnC = 1'b0;

    // Ejecutar el programa
    repeat (20) @(negedge clok);

    #1;

    // Verificar escritura al periferico
    if (!escritura_detectada) begin
        $display("ERROR: La CPU no escribio en video");
        $stop;
    end

    // Verificar el color almacenado
    if (led[5:0] !== 6'h30) begin
        $display("ERROR: Color incorrecto");
        $display("Color obtenido = %h", led[5:0]);
        $stop;
    end

    // Verificar que la CPU no se detuvo
    if (led[7] !== 1'b0) begin
        $display("ERROR: CPU detenida");
        $display("Motivo = %b", led[10:8]);
        $stop;
    end

    $display("================================");
    $display("PRUEBA DE CPU COMPLETA EXITOSA");
    $display("Escrituras detectadas: %0d", cantidad_escrituras);
    $display("Color final: %h", led[5:0]);
    $display("================================");

    $finish;

end

endmodule