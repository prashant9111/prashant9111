`include "router_top.v"
module router_4();
localparam N=10;

reg clk, resetn, read_enb_0, read_enb_1, read_enb_2, packet_valid;
reg [7:0]datain;

wire [7:0]data_out_0, data_out_1, data_out_2;
wire vld_out_0, vld_out_1, vld_out_2, err, busy;

reg [1:0]adrr;
reg [7:0]header, payload_data, parity;
reg [5:0]payloadlen;
	
integer i;
integer j=0;
integer k=0;

integer logfile;
integer m=0,n=0;


router_top DUT(.clock(clk),.resetn(resetn),.pkt_valid(packet_valid),.data_in(datain),
               .read_enb_0(read_enb_0),.read_enb_1(read_enb_1),.read_enb_2(read_enb_2),
               .data_out_0(data_out_0),.data_out_1(data_out_1),.data_out_2(data_out_2),
               .vld_out_0(vld_out_0),.vld_out_1(vld_out_1),.vld_out_2(vld_out_2),.busy(busy),.error(err));
               
initial
begin 
dumpfile(""router.vcd);
dumpvars(1);
end              
               

initial //clock generation
begin
	clk = 1;
	forever 
	#5 clk=~clk;
end  
	
task reset;
begin
	resetn=1'b0;
	{read_enb_0, read_enb_1, read_enb_2, packet_valid, datain}=0;
	#10;
	resetn=1'b1;
end
endtask
	
task pkt;	// packet generation payload 8	
begin
	parity=0;
	wait(!busy)
    @(negedge clk);
    payloadlen=6+({$random}%(N));
    packet_valid=1'b1;
    header={payloadlen,adrr};
    datain=header;
    parity=parity^datain;
    @(negedge clk);						
	for(i=0;i<payloadlen;i=i+1)
    begin      
        wait(!busy)				
        @(negedge clk);
        payload_data={$random}%(2**(payloadlen));
        datain=payload_data;
        parity=parity^datain;    
	end		
    wait(!busy)				
	@(negedge clk);
	packet_valid=0;				
	datain=parity;    
    if(vld_out_0)
        read_enb_0=1'b1;
    else if(vld_out_1)
        read_enb_1=1'b1;
    else if(vld_out_2)
        read_enb_2=1'b1;
    else
    begin
        read_enb_0=1'b0;
        read_enb_1=1'b0;
        read_enb_2=1'b0;
    end
    
end
endtask

initial
begin
    logfile=$fopen("test_4.log");
	reset;
	#10;
    repeat(4)
    begin
    adrr=2'b11;
	pkt;
    if((vld_out_0==1)||(vld_out_1==1)||(vld_out_2==1))
    begin
      $fdisplay(logfile,"FAIL");
        n=n+1;   
    end
    else
    begin
        $fdisplay(logfile,"PASS");
        m=m+1; 
    end    
        #150;
    end
    $fdisplay(logfile,"PASS=%0d",m);
    $fdisplay(logfile,"FAIL=%0d",n);   
    $finish ;     
end
endmodule