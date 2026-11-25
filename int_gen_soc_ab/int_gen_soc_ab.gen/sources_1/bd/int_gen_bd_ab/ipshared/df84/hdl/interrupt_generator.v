//////////////////////////////////////////////////////////////////////////////////
// Title      : CSUN ECE 520 Lab 5
// Project    : Lab 5 Interrupt Generator
//////////////////////////////////////////////////////////////////////////////////
// File       : interrupt_generator.v<interrupt_generator.srcs>
// Author     : Anna Bagdishyan 203475460
// Company    : CSUN
// Created    : 2026-11-22
// Last update: 2026-11-23
// Platform   :
// Standard   : Verilog
//////////////////////////////////////////////////////////////////////////////////
// Description: Top file for interrupt_generator.v
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module interrupt_generator (
    input sys_clk, // 50 MHz clock coming from Zynq PS 
    input sys_rst,
    input int_en,
    input int_clr,
    input sig_in,

    output reg int_out
);
   // Internal Signals
    reg sig_in_d1;
    reg sig_in_d2;
    wire sig_pos_edge;

    // Pos edge detector
    always @(posedge sys_clk) begin
        if (sys_rst) begin
            sig_in_d1 <= 1'b0;
            sig_in_d2 <= 1'b0;
        end
        else begin
            if (int_en) begin
                sig_in_d1 <= sig_in;
                sig_in_d2 <= sig_in_d1;
            end
            else begin
                sig_in_d1 <= 1'b0;
                sig_in_d2 <= 1'b0;
            end
        end
    end
    // generator level-triggered interrupt
    assign sig_pos_edge = sig_in_d1 & ~sig_in_d2;

    always @(posedge sys_clk) begin
        if (sys_rst) begin
            int_out <= 1'b0;
        end
        else begin
            if (int_en) begin
                if (int_clr) begin
                    int_out <= 1'b0;
                end
                else if (sig_pos_edge) begin
                    int_out <= 1'b1;
                end
                else begin
                    int_out <= int_out; // hold value
                end
            end
            else begin
                int_out <= 1'b0;
            end
        end
    end
endmodule