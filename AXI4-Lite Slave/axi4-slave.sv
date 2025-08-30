module slave(
    input clk,
    input reset,
    input [6:2] araddr,
    input arvalid,
    input rready,
    input [6:2] awaddr,
    input bready,
    input [31:0] wdata,
    input awvalid,
    input wvalid,
    output logic awready,
    output logic bvalid,
    output logic arready,
    output logic [1:0] response,
    output logic rvalid,
    output logic [31:0] rdata,
    output logic wready,
);

logic [31:0] internal_register [31:0];


// read logic 


logic [1:0] read_state, read_next_state;
logic [6:2] read_addr;
parameter read_idle = 0, read = 1;


always @(posedge clk, negedge reset) begin
    if (~reset) begin
        read_state <= read_idle;
        arready <= 0;
        rvalid <= 0;

    end
    else begin
        if (read_state == read_idle) begin
            rvalid <= 0;
            arready <= 1;
        end
        if (read_state == read_idle && arvalid && arready) begin
            read_addr <= araddr;
            arready <= 0;
            rvalid <= 1;
        end
        if (read_state == read) begin
            rdata <= internal_register [read_addr];
            if (rvalid & rready) begin
                rvalid <= 0;
            end
        end
    end

    read_state <= read_next_state;

end





always @(*) begin
    case(read_state)

    read_idle: if (arvalid & arready) begin
        read_next_state = read;
    end else begin
        read_next_state = read_idle;
    end

    read: if (rvalid & rready) begin
        read_next_state = read_idle;
    end else begin
        read_next_state = read;
    end

    endcase
end


// write logic

logic [1:0] write_state, next_write_state;


logic [31:0] temp_data;
logic [6:2] temp_addr;
logic handshake_add, handshake_data;

parameter write_idle = 0, write = 1;




always_ff @(posedge clk, negedge reset) begin

    if (~reset) begin
        response <= 2'b00;
        awready <= 0;
        wready <= 0;
        bvalid <= 0;
        handshake_add <= 0;
        handshake_data <= 0;
    end
    else begin
        if (awready & awvalid) begin
            handshake_add <= 1;
            temp_addr <= awaddr;
        end
        if (wready & wvalid) begin
            handshake_data <= 1;
            temp_data <= wdata;
        end
        if (write_state == write_idle && handshake_add && handshake_data) begin
            internal_register[temp_addr] <= temp_data;
            response <= 2'b00;
            bvalid <= 1;
        end
        if (write_state == write && bready && bvalid) begin
            handshake_add <= 0;
            handshake_data <= 0;
            bvalid <= 0;
        end 

    end

    write_state <= next_write_state;

end



always @(*) begin

    case (write_state)

        write_idle: begin

        awready = 1;
        wready = 1;
        if (handshake_add & handshake_data) begin
            next_write_state = write;
        end else begin
            next_write_state = write_idle;
        end

        end

        write: begin
        awready = 0;
        wready = 0;
        if (bready & bvalid) begin
            next_write_state = write_idle;
        end else begin
            next_write_state = write;
        end

        end

    endcase

end


endmodule