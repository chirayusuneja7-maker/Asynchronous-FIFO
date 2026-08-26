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

    output fifo_full,
    output fifo_empty

);

parameter DEPTH = 8;

//--------------------------------------------------
// Memory
//--------------------------------------------------

reg [7:0] fifo [0:DEPTH-1];

//--------------------------------------------------
// Binary Pointers
//--------------------------------------------------

reg [3:0] wr_ptr_bin;
reg [3:0] rd_ptr_bin;

//--------------------------------------------------
// Gray Pointers
//--------------------------------------------------

wire [3:0] wr_ptr_gray;
wire [3:0] rd_ptr_gray;

assign wr_ptr_gray = wr_ptr_bin ^ (wr_ptr_bin >> 1);
assign rd_ptr_gray = rd_ptr_bin ^ (rd_ptr_bin >> 1);

//--------------------------------------------------
// Synchronised Gray Pointers
//--------------------------------------------------

wire [3:0] wr_gray_sync;
wire [3:0] rd_gray_sync;

synchroniser sync_wr_to_rd
(
    .clk(rd_clk),
    .ptr_in(wr_ptr_gray),
    .ptr_out(wr_gray_sync)
);

synchroniser sync_rd_to_wr
(
    .clk(wr_clk),
    .ptr_in(rd_ptr_gray),
    .ptr_out(rd_gray_sync)
);

//--------------------------------------------------
// Next Write Pointer
//--------------------------------------------------

wire [3:0] wr_bin_next;
wire [3:0] wr_gray_next;

assign wr_bin_next  = wr_ptr_bin + 1'b1;
assign wr_gray_next = wr_bin_next ^ (wr_bin_next >> 1);

//--------------------------------------------------
// Empty Detection
//--------------------------------------------------

assign fifo_empty =
        (rd_ptr_gray == wr_gray_sync);

//--------------------------------------------------
// Full Detection
//--------------------------------------------------

assign fifo_full =
        (wr_gray_next ==
        {~rd_gray_sync[3:2],
          rd_gray_sync[1:0]});

//--------------------------------------------------
// Write Logic
//--------------------------------------------------

always @(posedge wr_clk or posedge rst)
begin

    if(rst)
        wr_ptr_bin <= 4'b0000;

    else if(wr_en && !fifo_full)
    begin
        fifo[wr_ptr_bin[2:0]] <= data_in;
        wr_ptr_bin <= wr_bin_next;
    end

end

//--------------------------------------------------
// Read Logic
//--------------------------------------------------

always @(posedge rd_clk or posedge rst)
begin

    if(rst)
    begin
        rd_ptr_bin <= 4'b0000;
        data_out <= 8'b0;
    end

    else if(rd_en && !fifo_empty)
    begin
        data_out <= fifo[rd_ptr_bin[2:0]];
        rd_ptr_bin <= rd_ptr_bin + 1'b1;
    end

end

endmodule
