module tb_asynchronous_fifo;
    reg wr_clk;
    reg rd_clk;
    reg rst;
    reg [7:0] data_in;
    reg wr_en;
    reg rd_en;

    wire [7:0] data_out;
    wire fifo_full;
    wire fifo_empty;

    asynchronous_fifo uut (
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .rst(rst),
        .data_in(data_in),
        .data_out(data_out),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .fifo_full(fifo_full),
        .fifo_empty(fifo_empty)
    );

    always begin
        #5 wr_clk = ~wr_clk; 
    end

    always begin
        #7 rd_clk = ~rd_clk; 
    end

    initial begin
        wr_clk = 0;
        rd_clk = 0;
        rst = 0;
        data_in = 8'b0;
        wr_en = 0;
        rd_en = 0;

        rst = 1;
        #20;
        rst = 0;
        #20;

        wr_en = 1;
        data_in = 8'hA5; #10;
        data_in = 8'h5A; #10;

        wr_en = 0; rd_en = 1; #14;

        wr_en = 1; rd_en = 0;
        data_in = 8'h3C; #10;
        data_in = 8'h7F; #10;

        wr_en = 0; rd_en = 1; #14;

        wr_en = 1; rd_en = 0;
        data_in = 8'hFF; #10;
        data_in = 8'h01; #10;
        data_in = 8'hA0; #10;
        data_in = 8'hB0; #10;
        data_in = 8'hC0; #10;
        data_in = 8'hD0; #10;
        data_in = 8'hE0; #10;
        data_in = 8'hF0; #10;

        data_in = 8'h11; #10;

        wr_en = 0; rd_en = 1;
        repeat(8) #14;

        $stop;  
    end
endmodule