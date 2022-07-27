`include "router_top.v"
module router_1();

reg clk, resetn, read_enb_0, read_enb_1, read_enb_2, packet_valid;
reg [7:0]datain;


wire [7:0]data_out_0, data_out_1, data_out_2;
wire vld_out_0, vld_out_1, vld_out_2, err, busy;

reg [1:0]adrr;
reg [7:0]header, payload_data, parity;
reg [5:0]payloadlen;
integer i,temp=0,z=0;
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



//clock generation
initial 
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
    @(negedge clk);
    payloadlen=8;
    packet_valid=1'b1;
    header={payloadlen,adrr};
    datain=header;
    parity=parity^datain;					
	for(i=0;i<payloadlen;i=i+1)
    begin 
        @(negedge clk);       
        payload_data={$random}%256;
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


always @(datain)
begin
    if(busy )
    temp = temp+1;
end

always @(data_out_0)
begin
    if(read_enb_0)
    begin
        z=z+1;
    end
end

always @(data_out_1)
begin
    if(read_enb_1)
    begin
        z=z+1;
    end
end

always @(data_out_2)
begin
    if(read_enb_2)
    begin
        z=z+1;
    end
end

task check;
begin
repeat(payloadlen+2)
    @(posedge clk);
    if((10-temp)==(z))
    begin
        $fdisplay(logfile,"PASS");
        m=m+1; 
    end        
    else
    begin
        $fdisplay(logfile,"FAIL");
        n=n+1;
    end    
    #150 ;
    temp=0;
    z=0;
    reset;
    #10;
end    
endtask
initial
begin   
    logfile=$fopen("test_1.log");
    reset;
	#10;
    repeat(4)
    begin
    adrr=2'b00;
	pkt;
    if(read_enb_0==1)
        check;
    adrr=2'b01;
    pkt;
    if(read_enb_1==1)
        check;
    adrr=2'b10;
    pkt;
    if(read_enb_2==1)
        check;
    end
    $fdisplay(logfile,"PASS=%0d",m);
    $fdisplay(logfile,"FAIL=%0d",n);    
    $finish; 
end
endmodule