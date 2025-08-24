module uart_transmit (
    input clk,
    input [7:0] in,
    input i_tx_start,
    input reset,
    output logic message_out
);
    
    // initialise registers and tick logic
    logic [7:0] message_in;
    logic tick;
    logic [7:0] count;
    logic [2:0] tick_counter;
    logic [0:0] stop_tick_counter;

    // set parameters for the state and next_state register, makes it easier for reading
    parameter IDLE = 0, START = 1, DATA = 2, STOP = 3;
    logic [1:0] state, next_state;

    // baud generator and main message_out code, running every clock cycle
    always @(posedge clk) begin

        // if the reset input is triggered, then set all the variables to 0 EXCEPT message_out, where it is set to 1 (default state should be IDLE)
        if (reset) begin
            state <= IDLE;
            count <= 0;
            tick <= 0;
            tick_counter <= 0;
            stop_tick_counter <= 0;
            message_in <= 0;
            message_out <= 1;
        end

        // if reset is not triggered, it's time to run the main baud generation and output code
        else begin

            // as stated in README.md, this UART transmitter is based on a 1 MHz processor clock, which means that every baud is triggered around every 104 clock cycles
            if (count == 103) begin
                
                // if 104 clock cycles has been counted for using the count variable, reset the counter and set tick to high
                tick <=1;
                count <= 0;
            end
            else begin
                
                // if less than 104 clock cycles has been counted increment the counter and keep tick at low
                tick <= 0;
                count <= count + 1;
            end

            // if 104 cycles has been passed and tick is set to high, then start the message_out logic
            if (tick) begin

                // make a case statement for each state, as the bits transmitted depend on the state the UART is in (explained in README.md)
                case (state)
                    IDLE:  message_out <= 1;
                    START: begin
                        message_out <= 0;
                    end
                    DATA:  begin

                        // the input message must be sent out one bit at a time, hence a pointer counter tick_counter will be used in order to output the correct bit each tick
                        message_out <= message_in[tick_counter];
                        if (tick_counter != 7) begin
                            tick_counter <= tick_counter + 1;
                        end
                    end
                    STOP:  begin

                        // 2 STOP bits are used instead of one, explained in README.me but the logic works similaryly to the DATA state above
                        message_out <= 1;
                        if (stop_tick_counter == 1) begin
                            stop_tick_counter <= 0;
                        end
                        else begin
                            stop_tick_counter <= stop_tick_counter + 1;
                        end
                    end
                endcase
            end
            
            // if at the START state and a tick has been registered then set the message_in register to the input message and reset the tick counter to 0 for use in the DATA state
            if (state == START && tick) begin
                message_in <= in;
                tick_counter <= 0;
            end

            // triggers state transition
            state <= next_state;
        end
        
    end



    // state transition logic
    always @(*) begin

        // by default the next_state is the current state
        next_state = state;

        // the next_state is dependant on the current state so a case statement is used
        case (state)

            // if the transmission start bit is triggered then set the next state to START or stay at IDLE
            IDLE: if (i_tx_start) begin
                next_state = START;
            end else begin
                next_state = IDLE;
            end

            // if a tick is registered high then set the next state to DATA if not stay at START
            START: if (tick) begin
                next_state = DATA;
            end else begin
                next_state = START;
            end

            // if a tick is high and the tick_counter is 7 then set the next state to STOP, if not then stay at DATA, regardless of if tick is high or low
            DATA: if (tick) begin
                if (tick_counter == 7) begin
                next_state = STOP;
            end else begin
                next_state = DATA;
            end
            end else begin
                next_state = DATA;
            end

            // if a tick is high and the stop_tick_counter is 1 then set the next state to IDLE, if not then stay at STOP, regardless of if the tick is high or low
            STOP: if (tick) begin
                if (stop_tick_counter == 1) begin
                next_state = IDLE;
            end else begin
                next_state = STOP;
            end
            end else begin
                next_state = STOP;
            end 
        endcase
    end


endmodule
