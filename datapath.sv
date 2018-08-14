module datapath(input logic clk, reset,
		input logic memtoregE, memtoregM, memtoregW,
		input logic pcsrcD, branchD,bneD,jrE,jalW,lbW,sbM,multE,divE,movloW,movhiW,
		input logic alusrcE, 
		input logic [1:0] regdstE,
		input logic regwriteE, regwriteM, regwriteW,
		input logic jumpD,
		input logic [3:0] alucontrolE,
		output logic equalD,
		output logic [31:0] pcF,
		input logic [31:0] instrF,
		output logic [31:0] aluoutM, writedataM,
		input logic [31:0] readdataM,
		output logic [5:0] opD, functD,
		output logic flushE);

	logic forwardaD, forwardbD;
	logic [1:0] forwardaE, forwardbE;
	logic stallF;
	logic [4:0] rsD, rtD, rdD, rsE, rtE, rdE;
	logic [4:0] writeregE, writeregM, writeregW;
	logic [4:0] shamtD,shamtE;
	logic flushD;
	logic [31:0] pcnextFD, pcnextbrFD, pcplus4F, pcbranchD,pcnextFD1;
	logic [31:0] signimmD, signimmE, signimmshD;
	logic [31:0] srcaD, srca2D, srcaE, srca2E;
	logic [31:0] srcbD, srcb2D, srcbE, srcb2E, srcb3E;
	logic [31:0] pcplus4D, instrD,pcplus4E,pcplus4M,pcplus4W;
	logic [31:0] aluoutE, aluoutW;
	logic [31:0] readdataW, resultW,fresultW;
	logic [7:0] lbres;
	logic [31:0] lbresex;
	logic [31:0] fdatav;
	logic [7:0] sbres;
	logic [31:0] sbresex;
	logic [31:0] writedataMF;
	logic [63:0] multres;
	logic [31:0] hires;
	logic[31:0]hiresM;
	logic [31:0]hiresW ;
	logic [31:0] lowres;
	logic[31:0]lowresM;
	logic[31:0] lowresW ;
	logic [31:0] quotient;
	logic [31:0] remainder;
	logic [31:0] himuxres;
	logic [31:0] lomuxres;
	logic [31:0] aluorhi;
	logic[31:0] aluorhiorlo;
	logic mord;
        // hazard detection
	hazard h(rsD, rtD, rsE, rtE, writeregE, writeregM,
	writeregW,regwriteE, regwriteM, regwriteW,
	memtoregE, memtoregM, branchD,bneD,jrE,
	forwardaD, forwardbD, forwardaE,
	forwardbE,
	stallF, stallD, flushE);
	
	// next PC logic (operates in fetch and decode)
	mux2 #(32) pcbrmux(pcplus4F, pcbranchD, pcsrcD,
	pcnextbrFD);//first mux fetch stage (BTA)
	mux3 #(32) pcmux(pcnextbrFD,{pcplus4D[31:28],
	instrD[25:0], 2'b00},srca2E,
	{jrE,jumpD}, pcnextFD);//second mux (jump)
	//mux2 #(32) pcmuxj(pcnextbrFD1,srca2E,jrE,pcnextFD);
	
	// register file (operates in decode and writeback)
      	mux2 #(32) writebackmux(resultW,pcplus4W,jalW,fresultW);
	regfile rf(clk, regwriteW, rsD, rtD, writeregW, fresultW, srcaD, srcbD);
	
	// Fetch stage logic
	flopenr #(32) pcreg(clk, reset, ~stallF, pcnextFD, pcF);
	adder pcadd1(pcF, 32'b100, pcplus4F);
	
	// Decode stage
	flopenr #(32) r1D(clk, reset, ~stallD, pcplus4F, pcplus4D);
	flopenclr #(32) r2D(clk, reset, ~stallD, flushD, instrF, instrD);
	signext se(instrD[15:0], signimmD);
	sl2 immsh(signimmD, signimmshD);
	adder pcadd2(pcplus4D, signimmshD, pcbranchD);
	mux2 #(32) forwardadmux(srcaD, aluoutM, forwardaD, srca2D);
	mux2 #(32) forwardbdmux(srcbD, aluoutM, forwardbD, srcb2D);
	equate #(32)comp(srca2D, srcb2D, equalD);

	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	assign shamtD=instrD[10:6];
	assign flushD = pcsrcD | jumpD|jrE;

	// Execute stage
	flopclr #(32) r1E(clk, reset, flushE, srcaD, srcaE);
	flopclr #(32) r2E(clk, reset, flushE, srcbD, srcbE);
	flopclr #(32) r3E(clk, reset, flushE, signimmD, signimmE);
	flopclr #(5) r4E(clk, reset, flushE, rsD, rsE);
	flopclr #(5) r8E(clk, reset, flushE, shamtD, shamtE);
	flopclr #(5) r5E(clk, reset, flushE, rtD, rtE);
	flopclr #(5) r6E(clk, reset, flushE, rdD, rdE);
   	flopclr #(32) r7E(clk, reset, flushE, pcplus4D, pcplus4E);
	mux3 #(32) forwardaemux(srcaE, resultW, aluoutM, forwardaE, srca2E);
	mux3 #(32) forwardbemux(srcbE, resultW, aluoutM, forwardbE, srcb2E);
	mux2 #(32) srcbmux(srcb2E, signimmE, alusrcE, srcb3E);
  	alu alu(srca2E, srcb3E, alucontrolE,shamtE, aluoutE);
	mux3 #(5) wrmux(rtE, rdE,5'b11111, regdstE, writeregE);
	multiplier multiplier (srca2E,srcb3E,multres);
	divider   divider (srca2E,srcb3E,quotient,remainder);
	mux2 #(32) lomux(multres[31:0],quotient,divE,lomuxres);
	mux2 #(32) himux(multres[63:32],remainder,divE,himuxres);
  	orgate orgate(multE,divE,mord);
	flopenr #(32) hi(clk, reset, mord, himuxres, hires);
	flopenr #(32) low(clk, reset, mord, lomuxres, lowres);
	// Memory stage
	flopr #(32) r1M(clk, reset, srcb2E, writedataMF);
       	flopr #(32) r5M(clk, reset, lowres, lowresM);
     	flopr #(32) r7M(clk, reset, hires, hiresM);
	flopr #(32) r2M(clk, reset, aluoutE, aluoutM);
       	flopr #(32) r4M(clk, reset, pcplus4E, pcplus4M);
	flopr #(5) r3M(clk, reset, writeregE, writeregM);
   	mux4  #(8) sbmux(writedataMF[7:0],writedataMF[15:8],writedataMF[23:16],writedataMF[31:24],aluoutM[1:0],sbres);
	signextb sesb(sbres, sbresex);
	mux2 #(32) sbmux2(writedataMF,sbresex,sbM,writedataM);	
	// Writeback stage
	flopr #(32) r1W(clk, reset, aluoutM, aluoutW);
      	flopr #(32) r5W(clk, reset, lowresM, lowresW);
	flopr #(32) r6W(clk, reset, hiresM, hiresW);
	flopr #(32) r2W(clk, reset, readdataM, readdataW);
	flopr #(5) r3W(clk, reset, writeregM, writeregW);
    	flopr #(32) r4W(clk, reset, pcplus4M, pcplus4W);
        	mux4  #(8) lbmux(readdataW[7:0],readdataW[15:8],readdataW[23:16],readdataW[31:24],aluoutW[1:0],lbres);
    	signextb selb(lbres, lbresex);
      	mux2 #(32) lbmux2(readdataW,lbresex,lbW,fdatav);
	mux2 #(32) himuxselect(aluoutW,hiresW,movhiW,aluorhi);
  	mux2 #(32) lomuxselect(aluorhi,lowresW,movloW,aluorhiorlo);
	mux2 #(32) resmux(aluorhiorlo, fdatav, memtoregW,
	resultW); 

endmodule
	
module hazard(input logic [4:0] rsD, rtD, rsE, rtE,
	      input logic [4:0] writeregE, writeregM, writeregW,
	      input logic regwriteE, regwriteM, regwriteW,
	      input logic memtoregE, memtoregM, branchD,bneD,jrE,
	      output logic forwardaD, forwardbD,
	      output logic [1:0] forwardaE, forwardbE,
	      output logic stallF, stallD, flushE);
	
	logic lwstallD, branchstallD;

	// forwarding sources to D stage (branch equality)
	assign forwardaD = (rsD !=0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD !=0 & rtD == writeregM & regwriteM);
	
	// forwarding sources to E stage (ALU)
	always_comb
	begin
		forwardaE = 2'b00; forwardbE = 2'b00;
		if (rsE != 0)
		if (rsE == writeregM & regwriteM)
			forwardaE = 2'b10;
		else if (rsE == writeregW & regwriteW)
			forwardaE = 2'b01;
		if (rtE != 0)
		if (rtE == writeregM & regwriteM)
			forwardbE = 2'b10;
		else if (rtE == writeregW & regwriteW)
			forwardbE = 2'b01;
	end

	// stalls
	assign #1 lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	assign #1 branchstallD = (bneD|branchD) & (regwriteE & (writeregE == rsD | writeregE == rtD) | memtoregM & (writeregM == rsD | writeregM == rtD));
	assign #1 stallD = lwstallD | branchstallD;
	assign #1 stallF = stallD;
	
	// stalling D stalls all previous stages
	assign #1 flushE = stallD|jrE;
	
	// stalling D flushes next stage
	// Note: not necessary to stall D stage on store
	// if source comes from load;
	// instead, another bypass network could
	// be added from W to M
	
endmodule

