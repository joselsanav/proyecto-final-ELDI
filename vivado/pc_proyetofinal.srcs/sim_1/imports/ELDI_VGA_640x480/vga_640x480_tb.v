`timescale 1ns / 1ps

module vga_640x480_tb;
    reg clk = 1'b0;
    reg reset = 1'b1;
    reg [5:0] pixel_rgb = 6'b101001;

    wire [9:0] h_count, v_count, pixel_x, pixel_y;
    wire hsync, vsync, video_active;
    wire [1:0] red, green, blue;

    vga_640x480 dut (
        .clk(clk), .reset(reset), .pixel_rgb(pixel_rgb),
        .h_count(h_count), .v_count(v_count),
        .pixel_x(pixel_x), .pixel_y(pixel_y),
        .hsync(hsync), .vsync(vsync), .video_active(video_active),
        .red(red), .green(green), .blue(blue)
    );

    // 100 MHz: periodo de 10 ns.
    always #5 clk = ~clk;

    integer exp_h = 0;
    integer exp_v = 0;
    integer exp_div = 0;
    integer checks = 0;
    integer errors = 0;
    integer i;
    reg exp_hsync, exp_vsync, exp_active;
    reg [5:0] exp_rgb;

    task check_outputs;
    begin
        exp_hsync = !((exp_h >= 656) && (exp_h < 752));
        exp_vsync = !((exp_v >= 490) && (exp_v < 492));
        exp_active = (exp_h < 640) && (exp_v < 480);
        exp_rgb = exp_active ? pixel_rgb : 6'b000000;
        checks = checks + 1;

        if (h_count !== exp_h[9:0] || v_count !== exp_v[9:0] ||
            pixel_x !== exp_h[9:0] || pixel_y !== exp_v[9:0] ||
            hsync !== exp_hsync || vsync !== exp_vsync ||
            video_active !== exp_active ||
            {red, green, blue} !== exp_rgb) begin
            errors = errors + 1;
            $display("ERROR t=%0t H=%0d/%0d V=%0d/%0d HS=%b/%b VS=%b/%b ACTIVE=%b/%b RGB=%b/%b",
                     $time, h_count, exp_h, v_count, exp_v,
                     hsync, exp_hsync, vsync, exp_vsync,
                     video_active, exp_active,
                     {red,green,blue}, exp_rgb);
            $fatal(1, "VGA: comprobacion fallida");
        end
    end
    endtask

    // Un flanco del reloj principal (no necesariamente un pixel nuevo).
    task tick_and_check;
    begin
        @(posedge clk);
        if (reset) begin
            exp_h = 0;
            exp_v = 0;
            exp_div = 0;
        end else if (exp_div == 3) begin
            exp_div = 0;
            if (exp_h == 799) begin
                exp_h = 0;
                if (exp_v == 524)
                    exp_v = 0;
                else
                    exp_v = exp_v + 1;
            end else begin
                exp_h = exp_h + 1;
            end
        end else begin
            exp_div = exp_div + 1;
        end
        #1; // Esperar a que se actualicen los registros del DUT.
        check_outputs;
    end
    endtask

    initial begin
        // Comprobar reset inicial.
        repeat (3) tick_and_check;
        @(negedge clk);
        reset = 1'b0;

        // Un cuadro completo: 800 * 525 pixeles, 4 ciclos de 100 MHz por pixel.
        for (i = 0; i < 800*525*4; i = i + 1)
            tick_and_check;

        if (exp_h != 0 || exp_v != 0)
            $fatal(1, "No regreso a (0,0) al terminar el cuadro");
        $display("PASS: cuadro completo 640x480, HSYNC, VSYNC y RGB222");

        // Cambiar color y comprobar tambien durante la marcha.
        @(negedge clk);
        pixel_rgb = 6'b110011;
        repeat (500) tick_and_check;
        $display("PASS: cambio de color RGB222");

        // Reset mientras el controlador ya esta contando.
        @(negedge clk);
        reset = 1'b1;
        repeat (2) tick_and_check;
        $display("PASS: reset durante funcionamiento");

        if (errors == 0)
            $display("PRUEBA VGA EXITOSA: %0d comprobaciones, 0 errores", checks);
        $finish;
    end
endmodule
