`include "router_top.v"
module router_2();
localparam N=20;

reg clk, resetn, read_enb_0, read_enb_1, read_enb_2, packet_valid;
reg [7:0]datain;

wire [7:0]data_out_0, data_out_1, data_out_2;
wire vld_out_0, vld_out_1, vld_out_2, err, busy;

reg [1:0]adrr;
reg [7:0] datain_test [N:0];
reg [7:0] dataout_test [N:0];

integer i;
integer j=0;
integer k=0;
integer z=0;

reg [7:0]header, payload_data, parity;
reg [5:0]payloadlen;
reg [7:0]x,y;

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
    payloadlen=6+({$random}%(N-4));
    packet_valid=1'b1;
    header={payloadlen,adrr};
    datain=header;
    datain_test[0]=header;
    parity=parity^datain;
    @(negedge clk);						
	for(i=0;i<payloadlen;i=i+1)
    begin      
        wait(!busy)				
        @(negedge clk);
        payload_data={$random}% (2**(payloadlen));
        datain=payload_data;
        datain_test[i+1]=datain;
        parity=parity^datain;    
	end		
    wait(!busy)				
	@(negedge clk);
	packet_valid=0;				
	datain=parity;
    datain_test[payloadlen+1]=datain;
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

task test;
begin
    for(j=0;k<(payloadlen+2);k=k+1)
    begin    
        if((dataout_test[k]!=datain_test[k])&&(x==0)&&(y==0)) 
        begin
            z=z+1;    
        end
    end 
end
endtask

task check;
begin
    if(read_enb_0)
    begin
        for(j=0;j<(payloadlen+2);j=j+1)
        begin
            @(posedge clk);
            #1;
            dataout_test[j]=data_out_0;
        end
        x=data_out_1;
        y=data_out_2;
        test;
    end    
    if(read_enb_1)
    begin
        for(j=0;j<(payloadlen+2);j=j+1)
        begin
            @(posedge clk);
            #1;
            dataout_test[j]=data_out_1;
        end
        x=data_out_0;
        y=data_out_2;
        test;
    end    
    if(read_enb_2)
    begin
        for(j=0;j<(payloadlen+2);j=j+1)
        begin
            @(posedge clk);
            #1;
            dataout_test[j]=data_out_2;
        end
        x=data_out_0;
        y=data_out_1;
        test;
    end    
    if(z==0)
    begin
        $fdisplay(logfile,"PASS");
        m=m+1;
    end        
    else
    begin
        $fdisplay(logfile,"FAIL");
        n=n+1;
    end
    #200  
    reset;
    #10;    
end
endtask

initial
begin
    logfile=$fopen("test_2.log");
	reset;
	#10;
    repeat(20)
    begin
    adrr={$random}%3;
	pkt;
    check;
    end
    $fdisplay(logfile,"PASS=%0d",m);
    $fdisplay(logfile,"FAIL=%0d",n); 
    $finish;   
end
endmodule