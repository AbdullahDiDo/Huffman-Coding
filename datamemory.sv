module dmem(input  logic        clk, we,
            input  logic [31:0] a, wd,
            output logic [31:0] rd,
		output logic sbM);

  logic [31:0] RAM[63:0];

  assign rd = RAM[a[31:2]]; // word aligned

  always @(posedge clk)
    if (we)begin 
if(sbM)
begin
 RAM[a[31:0]] <= wd;
end
else
      RAM[a[31:2]] <= wd;
end
endmodule
