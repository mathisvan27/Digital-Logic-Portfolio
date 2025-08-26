module slave(
    input clk,
    input ARESETN,
    input [7:0] ARAADDR,
    input ARVALID,
    input RREADY,
    input BREADY,
    input [6:2] AWADDR,
    input AWVALID,
    input WVALID,
    input [31:0] WDATA, 
    input [1023:0] REGISTERS_IN,
    output logic [1023:0] REGISTERS_OUT,
    output logic AWREADY,
    output logic WREADY,
    output logic BVALID,
    output logic [1:0] BRESP,
    output ARREADY,
    output RVALID,
    output [7:0] RDATA
);


// WRITE operations

logic [6:2] write_addr;
logic [31:0] write_data;
logic cap_add, cap_data;

parameter WRITE_IDLE = 0, WRITE = 1, WRITE_RESP = 2;
logic [2:0] write_state, next_write_state;


always @(posedge clk, negedge ARESETN) begin

    if (~ARESETN) begin
        WREADY <= 0;
        AWREADY <= 0;
        BVALID <= 0;
        cap_add <= 0;
        cap_data <= 0;
        write_state <= WRITE_IDLE;
    end
    else begin
        if (write_state == WRITE_IDLE) begin
            if (AWVALID & AWREADY) begin 
                write_addr <= AWADDR;
                cap_add <= 1;
            end

            if (WVALID & WREADY) begin
                cap_data <= 1;
            end
            
        end

        write_state <= next_write_state;
    end

end


always @(*) begin

    WREADY = 1;
    AWREADY = 1;

    case (write_state)
        WRITE_IDLE:  begin
            BVALID = 0;
            if (cap_add & cap_data) begin
                BVALID = 1;
                next_write_state = WRITE;
                write_data = WDATA;
                REGISTERS_OUT[((32*write_addr) + 31) -: 32] = write_data;
            end
            else begin
                next_write_state = WRITE_IDLE;
            end
        end

        WRITE: begin

            AWREADY = 0;
            WREADY = 0;

            if (BREADY) begin
                BREADY = 0;
                next_write_state = WRITE_RESP;
            end
            else next_write_state = WRITE;
        end

        WRITE_RESP: begin

            BRESP = 2'b00;
            
            
            if (BREADY) next_write_state = WRITE_IDLE;
            else next_write_state = WRITE_RESP;

        end
    endcase

end


// READ operations

logic [31:0] addr_reg;

parameter READ_IDLE = 0, READ = 1;
logic [1:0] read_state, next_read_state;

always @(posedge clk, negedge ARESETN) begin
    
    if (~ARESETN) begin
        RREADY <= 0;
        ARREADY <= 0;
        RDATA <= {32{1'b0}};

        read_state <= READ_IDLE;
    end
    else begin
        if (read_state == READ_IDLE) addr_reg <= ARADDR; 
        read_state <= next_read_state;
    end 


end


always @(*) begin

    ARREADY = 1;
    RVALID = 0;
    RDATA = {32{1'b0}};


    if (read_state == READ_IDLE) begin

        RVALID = 0;
        if (ARREADY & ARVALID) begin
            next_read_state = READ;
        end else begin
            next_read_state = READ_IDLE;
        end


    end
    else if (read_state == READ) begin

        ARREADY = 0;
        RDATA = REGISTERS_IN[(32*addr_reg + 31) -: 32];;
        RVALID = 1;

        if (RREADY) next_read_state = READ_IDLE;
        else next_read_state = READ;
        

    end
end




endmodule
