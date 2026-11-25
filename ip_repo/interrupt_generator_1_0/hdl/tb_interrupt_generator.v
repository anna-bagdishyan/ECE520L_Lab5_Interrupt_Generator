//////////////////////////////////////////////////////////////////////////////////
// Title      : CSUN ECE 520 Lab 5
// Project    : Lab 5 Interrupt Generator
//////////////////////////////////////////////////////////////////////////////////
// File       : tb_interrupt_generator.v<tb_interrupt_generator.sim>
// Author     : Anna Bagdishyan 203475460
// Company    : CSUN
// Created    : 2026-11-22
// Last update: 2026-11-23
// Platform   :
// Standard   : Verilog
//////////////////////////////////////////////////////////////////////////////////
// Description: Testbench for interrupt_generator.v
////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module tb_interrupt_generator;

    reg sys_clk;
    reg sys_rst;
    reg int_en;
    reg int_clr;
    reg sig_in;

    wire int_out;

    // DUT
    interrupt_generator DUT (
        .sys_clk(sys_clk),
        .sys_rst(sys_rst),
        .int_en(int_en),
        .int_clr(int_clr),
        .sig_in(sig_in),
        .int_out(int_out)
    );

    // 20 ns period = 50 MHz clock
    always #10 sys_clk = ~sys_clk;

    initial begin
        sys_clk = 0;
        sys_rst = 1;
        int_en = 0;
        int_clr = 0;
        sig_in = 0;

    // holding reset for 5 clk cycles
    #100;
    sys_rst = 1;

    // Test 1 - check after reset
    #1;

    if (int_out != 1'b0) begin
        $display("FAILED: int_out should be 0 after reset");
        $finish;
    end
    @(posedge sys_clk);
    #1;
    sys_rst = 0;

    // Test 2 - Interrupt disabled
    @(posedge sys_clk);
    #1;
    sig_in = 1;

    @(posedge sys_clk);
    @(posedge sys_clk);
    @(posedge sys_clk);
    @(posedge sys_clk);
    @(posedge sys_clk);
    #1;

    if (int_out != 1'b0) begin
        $display("FAILED: int_out should be 0 when sign_in = 1");
        $finish;
    end

    @(posedge sys_clk);
    #1;
    sig_in = 0;

    @(posedge sys_clk);
    @(posedge sys_clk);
    #1;

    // Test 3 - Interrupt enabled
    @(posedge sys_clk);
    #1;
    int_en = 1;
    sig_in = 1;

    @(posedge sys_clk);
    @(posedge sys_clk);
    @(posedge sys_clk);
    @(posedge sys_clk);
    @(posedge sys_clk);
    #1;

    if (int_out != 1'b1) begin
        $display("FAILED: int_out should be 1 when interrupt enabled");
        $finish;
    end

    // Test 4 - Interrupt should remain asserted
    @(posedge sys_clk);
    #1;
    sig_in = 0;

    @(posedge sys_clk);
    @(posedge sys_clk);
    @(posedge sys_clk);
    @(posedge sys_clk);
    #1;
    
    if (int_out != 1'b1) begin
        $display("FAILED: int_out should be held");
        $finish;
    end

    
    // Test 5 - Clearing interrupt
    @(posedge sys_clk);
    #1;
    int_clr = 1;

    @(posedge sys_clk);
    #1;

    if (int_out != 1'b0) begin
        $display("FAILED: int_out should be 0 when clearing interrupt");
        $finish;
    end

    @(posedge sys_clk);
    #1;
    int_clr = 0;

    // Test 6 - sig_in = 1 should only detect one interrupt
    @(posedge sys_clk);
    #1;
    sig_in = 1;

    @(posedge sys_clk);
    @(posedge sys_clk);
    @(posedge sys_clk);
    #1;

    if (int_out != 1'b1) begin
        $display("FAILED: New interrupt not detected");
        $finish;
    end

    // clear interrupt while sig_in remains high
    @(posedge sys_clk);
    #1;
    int_clr = 1;

    @(posedge sys_clk);
    #1;
    int_clr = 0;

    @(posedge sys_clk);
    @(posedge sys_clk);
    @(posedge sys_clk);
    @(posedge sys_clk);
    @(posedge sys_clk);
    #1;

    if (int_out != 1'b0) begin
        $display("FAILED: Should not have a repeated interrupt");
        $finish;
    end

    $display("TEST PASSED");
    $finish;
    end

    initial begin
        #1000000;
        $display("TEST FAILED: TIMEOUT");
        $finish;
    end

endmodule
