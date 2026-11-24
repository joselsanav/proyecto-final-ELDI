`timescale 1ns / 1ps

module vga_640x480 (
    input  wire       clk,           // Reloj de 100 MHz de Basys 3
    input  wire       reset,         // Reset sincrono activo en alto
    input  wire [5:0] pixel_rgb,     // {R[1:0], G[1:0], B[1:0]}
    output reg  [9:0] h_count,
    output reg  [9:0] v_count,
    output wire [9:0] pixel_x,
    output wire [9:0] pixel_y,
    output wire       hsync,
    output wire       vsync,
    output wire       video_active,
    output wire [1:0] red,
    output wire [1:0] green,
    output wire [1:0] blue
);
    localparam integer H_VISIBLE = 640;
    localparam integer H_FRONT   = 16;
    localparam integer H_SYNC    = 96;
    localparam integer H_BACK    = 48;
    localparam integer H_TOTAL   = H_VISIBLE + H_FRONT + H_SYNC + H_BACK;

    localparam integer V_VISIBLE = 480;
    localparam integer V_FRONT   = 10;
    localparam integer V_SYNC    = 2;
    localparam integer V_BACK    = 33;
    localparam integer V_TOTAL   = V_VISIBLE + V_FRONT + V_SYNC + V_BACK;

    // Habilitacion de pixel: un avance cada cuatro flancos de 100 MHz.
    reg [1:0] divisor;
    wire pixel_enable = (divisor == 2'd3);

    always @(posedge clk) begin
        if (reset)
            divisor <= 2'd0;
        else
            divisor <= divisor + 2'd1;
    end

    always @(posedge clk) begin
        if (reset) begin
            h_count <= 10'd0;
            v_count <= 10'd0;
        end else if (pixel_enable) begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 10'd0;
                if (v_count == V_TOTAL - 1)
                    v_count <= 10'd0;
                else
                    v_count <= v_count + 10'd1;
            end else begin
                h_count <= h_count + 10'd1;
            end
        end
    end

    assign pixel_x = h_count;
    assign pixel_y = v_count;

    assign hsync = ~((h_count >= H_VISIBLE + H_FRONT) &&
                     (h_count <  H_VISIBLE + H_FRONT + H_SYNC));
    assign vsync = ~((v_count >= V_VISIBLE + V_FRONT) &&
                     (v_count <  V_VISIBLE + V_FRONT + V_SYNC));

    assign video_active = (h_count < H_VISIBLE) && (v_count < V_VISIBLE);

    assign red   = video_active ? pixel_rgb[5:4] : 2'b00;
    assign green = video_active ? pixel_rgb[3:2] : 2'b00;
    assign blue  = video_active ? pixel_rgb[1:0] : 2'b00;
endmodule
