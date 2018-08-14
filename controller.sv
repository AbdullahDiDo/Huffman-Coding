module controller(input  logic clk, reset,
				  input  logic [5:0] opD, functD,
				  input  logic flushE, equalD,
				  output logic memtoregE,memtoregM,
				  output logic memtoregW,memwriteM,
				  output logic pcsrcD,branchD, alusrcE,
				  output logic [1:0] regdstE,
			          output logic regwriteE,
				  output logic regwriteM,regwriteW,
				  output logic jumpD,
				  output logic [3:0] alucontrolE,
				  output logic   bneD,
       				  output logic jrE,
				  output logic jalW,
				  output logic lbW,
           				  output logic sbM ,
					output logic multE,divE ,movloW,movhiW);
				  
		logic [1:0] aluopD;
		logic memtoregD, memwriteD, alusrcD, regwriteD;
		logic [1:0] regdstD;
		logic [3:0] alucontrolD;
		logic memwriteE;
   		logic   jrD;
		logic multD;
		logic   jalD;
		logic lbD;
		logic sbD;
		logic divD;
		logic movloD;
		logic movhiD;
     		maindec md(opD, memtoregD, memwriteD, branchD,
				   alusrcD, regdstD, regwriteD, jumpD,
				   aluopD,bneD,jalD,lbD,sbD);
				   
		aludec ad(functD, aluopD, alucontrolD,jrD,multD,divD,movloD,movhiD);
		
		assign pcsrcD = (branchD & equalD)|(bneD & ~equalD);
		// registers needed
             		flopclr #(18) regE(clk, reset, flushE,
				{memtoregD, memwriteD, alusrcD,
				regdstD, regwriteD, alucontrolD,jrD,jalD,lbD,sbD,multD,divD,movloD,movhiD},
				{memtoregE, memwriteE, alusrcE,
				regdstE, regwriteE, alucontrolE,jrE,jalE,lbE,sbE,multE,divE,movloE,movhiE});
						
		flopr #(8) regM(clk, reset,
				{memtoregE, memwriteE, regwriteE,jalE,lbE,sbE,movloE,movhiE},
				{memtoregM, memwriteM, regwriteM,jalM,lbM,sbM,movloM,movhiM});
						
            		flopr #(6) regW(clk, reset,
				{memtoregM, regwriteM,jalM,lbM,movloM,movhiM},
				{memtoregW, regwriteW,jalW,lbW,movloW,movhiW});
endmodule


