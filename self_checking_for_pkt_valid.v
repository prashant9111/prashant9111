`include "router_top.v"
`timescale 1ns/1ps
module router_top_tb();
  parameter time_period = 5 ;

  reg clk, resetn, read_enb_0, read_enb_1, read_enb_2, packet_valid;
  reg [7:0]datain;
  wire [7:0]data_out_0, data_out_1, data_out_2;
  wire vld_out_0, vld_out_1, vld_out_2, err, busy;
  integer i;

  router_top DUT(clk,resetn,packet_valid,datain,read_enb_0,read_enb_1,
                 read_enb_2,data_out_0,data_out_1,data_out_2,vld_out_0,vld_out_1,vld_out_2,busy,err);



  initial
  begin:GTKWAVE
    $dumpfile("a.vcd");
    $dumpvars(1);
  end

  //clock generation
  initial
  begin:CLOCK
    clk = 1;
    forever
      #time_period clk=~clk;
  end



  task packet_valid_verify_data_out_0;
    reg [7:0]header, payload_data, parity;
    reg [10:0]payloadlen;

    begin
      resetn=1'b0;
      #time_period  resetn=1'b1;
      parity=0;
      read_enb_0=1'b1; 

          //NOTE Header Loading
          wait(!busy)
              begin
                @(negedge clk);
                payloadlen=8;
                // packet_valid=1'b1;
                header={payloadlen,2'b00};
                datain=header;
                parity=parity^datain;
              end
              @(negedge clk);
              

              
              
              
              //NOTE Payload Data loadiing
              for(i=0;i<payloadlen;i=i+1)
              begin
                
                wait(!busy)
                begin
                  @(negedge clk);
                  payload_data={$random}%(256*$time);
                  datain=payload_data;
                  parity=parity^datain;
                end
              end


              
              //NOTE Parity Loading
              wait(!busy)
                @(negedge clk);
                packet_valid=0;
                datain=parity;
                

    end
    endtask



task packet_valid_verify_data_out_1;
    reg [7:0]header, payload_data, parity;
    reg [10:0]payloadlen;

    begin
      resetn=1'b0;
      #time_period  resetn=1'b1;
      parity=0;
      read_enb_1=1'b1; 

          //NOTE Header Loading
          wait(!busy)
              begin
                @(negedge clk);
                payloadlen=8;
                // packet_valid=1'b1;
                header={payloadlen,2'b01};
                datain=header;
                parity=parity^datain;
              end
              @(negedge clk);
              

              
              
              
              //NOTE Payload Data loadiing
              for(i=0;i<payloadlen;i=i+1)
              begin
                
                wait(!busy)
                begin
                  @(negedge clk);
                  payload_data={$random}%(256*$time);
                  datain=payload_data;
                  parity=parity^datain;
                end
              end


              
              //NOTE Parity Loading
              wait(!busy)
                @(negedge clk);
                packet_valid=0;
                datain=parity;
                

    end
    endtask

task packet_valid_verify_data_out_2;
    reg [7:0]header, payload_data, parity;
    reg [10:0]payloadlen;

    begin
      resetn=1'b0;
      #time_period  resetn=1'b1;
      parity=0;
      read_enb_2=1'b1; 

          //NOTE Header Loading
          wait(!busy)
              begin
                @(negedge clk);
                payloadlen=8;
                // packet_valid=1'b1;
                header={payloadlen,2'b10};
                datain=header;
                parity=parity^datain;
              end
              @(negedge clk);
              

              
              
              
              //NOTE Payload Data loadiing
              for(i=0;i<payloadlen;i=i+1)
              begin
                
                wait(!busy)
                begin
                  @(negedge clk);
                  payload_data={$random}%(256*$time);
                  datain=payload_data;
                  parity=parity^datain;
                end
              end


              
              //NOTE Parity Loading
              wait(!busy)
                @(negedge clk);
                packet_valid=0;
                datain=parity;
                

    end
    endtask

    task packet_valid_verify_when_de_asserted;
      begin
        
        packet_valid_verify_data_out_0;
        #(10*time_period) packet_valid_verify_data_out_1;
        #(10*time_period) packet_valid_verify_data_out_2;
        if (data_out_0) begin
            $display("packet_valid when de-asserted still the data_out_0 is non-zero hence packet_valid is not working correct: FAILED\n");
        end
        else
            $display("packet_valid when de-asserted still the data_out_0 is zero hence packet_valid is working correct: PASS\n");

        if (data_out_1) begin
            $display("packet_valid when de-asserted still the data_out_1 is non-zero hence packet_valid is not working correct: FAILED\n");

        end
        else
            $display("packet_valid when de-asserted still the data_out_1 is zero hence packet_valid is working correct: PASS\n");


        if (data_out_2) begin
            $display("packet_valid when de-asserted still the data_out_2 is non-zero hence packet_valid is not working correct: FAILED\n");

        end
        else
            $display("packet_valid when de-asserted still the data_out_2 is zero hence packet_valid is working correct: PASS\n");
      end
    endtask
    task packet_valid_verify_when_asserted;
      begin
        packet_valid=1'b1;
        packet_valid_verify_data_out_0;
        #(10*time_period) packet_valid_verify_data_out_1;
        #(10*time_period) packet_valid_verify_data_out_2;
        if (data_out_0) begin
            $display("packet_valid when asserted still the data_out_0 is zero hence packet_valid is not working correct: FAILED\n");
        end
        else
            $display("packet_valid when asserted still the data_out_0 is non-zero hence packet_valid is working correct: PASS\n");

        if (data_out_1) begin
            $display("packet_valid when asserted still the data_out_1 is zero hence packet_valid is not working correct: FAILED\n");

        end
        else
            $display("packet_valid when asserted still the data_out_1 is non-zero hence packet_valid is working correct: PASS\n");


            if (data_out_2) begin
                $display("packet_valid when asserted still the data_out_2 is zero hence packet_valid is not working correct: FAILED\n");
    
            end
            else
                $display("packet_valid when asserted still the data_out_2 is non-zero hence packet_valid is working correct: PASS\n");
    
      end
    endtask


    initial
    begin
      packet_valid_verify_when_asserted;
      packet_valid_verify_when_de_asserted;
      #1000 $finish;
    end

  endmodule
