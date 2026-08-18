`timescale 1ns / 1ps

//====================================================
// 2-FF Synchronizer
//====================================================
module synchroniser(
    input clk,
    input [3:0] ptr_in,
    output reg [3:0] ptr_out
);

    reg [3:0] ff1;
    reg [3:0] ff2;
    always @(posedge clk) begin
        ff1 <= ptr_in;
        ff2 <= ff1;
        ptr_out <= ff2;
    end

endmodule


//====================================================
// Asynchronous FIFO
//====================================================
module asynchronous_fifo(

    input wr_clk,
    input rd_clk,
    input rst,

    input [7:0] data_in,
    output reg [7:0] data_out,

    input wr_en,
    input rd_en,

    output reg fifo_full,
    output reg fifo_empty

);

parameter DEPTH = 8;

reg [7:0] fifo [0:DEPTH-1];

reg [3:0] wr_ptr;
reg [3:0] rd_ptr;

//----------------------------------------------------
// Gray Pointers
//----------------------------------------------------
wire [3:0] wr_gray;
wire [3:0] rd_gray;
wire [3:0] wr_ptr_next;

assign wr_ptr_next = wr_ptr + 1'b1;

assign wr_gray = wr_ptr ^ (wr_ptr >> 1);
assign rd_gray = rd_ptr ^ (rd_ptr >> 1);

//----------------------------------------------------
// Synchronized Gray Pointers
//----------------------------------------------------
wire [3:0] wr_gray_sync;
wire [3:0] rd_gray_sync;

synchroniser sync_wr_to_rd(
    .clk(rd_clk),
    .ptr_in(wr_gray),
    .ptr_out(wr_gray_sync)
);

synchroniser sync_rd_to_wr(
    .clk(wr_clk),
    .ptr_in(rd_gray),
    .ptr_out(rd_gray_sync)
);

//----------------------------------------------------
// Gray -> Binary Function
//----------------------------------------------------
function [3:0] gray2bin;

    input [3:0] gray;

    begin
        gray2bin[3] = gray[3];
        gray2bin[2] = gray[3] ^ gray[2];
        gray2bin[1] = gray[3] ^ gray[2] ^ gray[1];
        gray2bin[0] = gray[3] ^ gray[2] ^ gray[1] ^ gray[0];
    end

endfunction
wire [3:0] wr_sync_ptr;
wire [3:0] rd_sync_ptr;
assign wr_sync_ptr = gray2bin(wr_gray_sync);
assign rd_sync_ptr = gray2bin(rd_gray_sync);

//----------------------------------------------------
// Write Logic
//----------------------------------------------------
always @(posedge wr_clk or posedge rst)
begin

    if(rst)
        wr_ptr <= 4'b0000;
        

    else if(wr_en && !fifo_full)
    begin
        fifo[wr_ptr[2:0]] <= data_in;
        wr_ptr <= wr_ptr + 1;
    end

end

//----------------------------------------------------
// Read Logic
//----------------------------------------------------
always @(posedge rd_clk or posedge rst)
begin

    if(rst)
    begin
        rd_ptr <= 4'b0000;
        data_out <= 8'b0;
    end

    else if(rd_en && !fifo_empty)
    begin
        data_out <= fifo[rd_ptr[2:0]];
        rd_ptr <= rd_ptr + 1;
    end

end

//----------------------------------------------------
// Empty Detection
// FIFO empty when read pointer catches write pointer
//----------------------------------------------------
always @(posedge rd_clk or posedge rst)
begin

    if(rst)
        fifo_empty <= 1'b1;

    else
        fifo_empty <= (rd_ptr == wr_sync_ptr);

end

//----------------------------------------------------
// Full Detection
// FIFO full when next write pointer reaches read ptr
//----------------------------------------------------
always @(posedge wr_clk or posedge rst)
begin

    if(rst)
        fifo_full <= 1'b0;

    else
        fifo_full <=
        (
            (wr_ptr_next[2:0] == rd_sync_ptr[2:0]) &&
            (wr_ptr_next[3]   != rd_sync_ptr[3])
        );

end

endmodule