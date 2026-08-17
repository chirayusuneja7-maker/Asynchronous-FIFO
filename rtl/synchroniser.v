`timescale 1ns / 1ps
module synchroniser(
    input clk,              
    input [2:0] ptr_in,     
    output reg [2:0] ptr_out 
);
    reg [2:0] signal_1;
    reg [2:0] signal_2;

    always @(posedge clk) begin
        signal_1 <= ptr_in;
        signal_2 <= signal_1;
        ptr_out  <= signal_2;
    end
endmodule

module asynchronous_fifo(
    input wr_clk, input rd_clk,
    input rst, input [7:0] data_in,
    output reg [7:0] data_out,
    input wr_en, input rd_en,
    output reg fifo_full, output reg fifo_empty
);
    parameter depth = 8;
    reg [7:0] fifo [depth-1:0];
    reg [2:0] wr_ptr;  
    reg [2:0] rd_ptr;  

    wire [2:0] rd_sync_ptr;
    wire [2:0] wr_sync_ptr;

    synchroniser sync_wr_to_rd(.clk(rd_clk), .ptr_in(wr_ptr), .ptr_out(rd_sync_ptr));
    synchroniser sync_rd_to_wr(.clk(wr_clk), .ptr_in(rd_ptr), .ptr_out(wr_sync_ptr));

    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            wr_ptr <= 3'b000;
        end else if (wr_en && !fifo_full) begin
            fifo[wr_ptr] <= data_in;
            wr_ptr <= (wr_ptr + 1) % depth;
        end
    end

    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            rd_ptr   <= 3'b000;
            data_out <= 8'b0;
        end else if (rd_en && !fifo_empty) begin
            data_out <= fifo[rd_ptr];
            rd_ptr   <= (rd_ptr + 1) % depth;
        end
    end

    always @(posedge wr_clk or posedge rst) begin
        if (rst) begin
            fifo_empty <= 0;
        end else begin
            fifo_empty <= (rd_ptr == rd_sync_ptr);
        end
    end

    always @(posedge rd_clk or posedge rst) begin
        if (rst) begin
            fifo_full <= 0;
        end else begin
            fifo_full <= ((wr_ptr + 1) % depth == wr_sync_ptr);
        end
    end
endmodule