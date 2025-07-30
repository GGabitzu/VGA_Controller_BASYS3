// ==========================================================================
// Autor         : Dincă Gabriel
// Proiect       : Practică - Capgemini Brașov
// Statut        : Student - Facultatea ETTI, specializarea EA
// Modul         : vga_controllerHD
// Descriere     : Generator de semnal VGA 1920x1080 care afișează o față
//                 (cerc cu ochi și gură) ce se mișcă pe ecran în funcție
//                 de apăsarea butoanelor. Culoare de fundal diferită.
// ==========================================================================

module vga_controllerHD(

    input wire clk,
    input wire reset,    // reset activ pe 1
    input wire btnR,//buton dreapta
    input wire btnL,//buton stanga
    input wire btnD,//buton jos
    input wire btnU,//buton sus
    output wire Hsync,
    output wire Vsync,
    output reg[3:0] vgaRed,
    output reg[3:0] vgaGreen,
    output reg[3:0] vgaBlue

);

	
    localparam HV = 1920; //Active Video(porțiunea vizibilă )
    localparam HFP = 88; //Front Porch(o mică pauză după ce s-au transmis pixelii)
    localparam HSP = 44; //Sync Pulse (impuls de sincronizare)
    localparam HBP = 148; //Back Porch(pauză după impuls, înainte de a începe următoarea linie/cadru)
    localparam HTOT = HV + HFP + HSP + HBP; //totalul timpului

    localparam VV = 1080;
    localparam VFP = 4;
    localparam VSP = 5;
    localparam VBP = 36;
    localparam VTOT = VV + VFP + VSP + VBP;


    //acopera toata rezolutia,definește o lățime de 12 biți,
    reg [11:0] h_count=0 ;
    reg [11:0] v_count=0;
    wire video_on=((h_count<HV) && (v_count<VV));

    // 
    assign Hsync=(( h_count >= HV+HFP)&&(h_count<HV+HFP+HSP));
    assign Vsync=((v_count>=VV+VFP)&&(v_count<VV+VFP+VSP));
	
	reg[10:0] circle_h=960;
	reg[10:0] circle_v=540;
	localparam RADIUS=60;

	wire [10:0] CERC;
	// Capul (fața)
wire face = ((h_count - circle_h)*(h_count - circle_h) + (v_count - circle_v)*(v_count - circle_v)) <= RADIUS*RADIUS;

// Ochi stânga
wire eye_left = ((h_count - (circle_h - 20))**2 + (v_count - (circle_v - 15))**2) <= 8*8;

// Ochi dreapta
wire eye_right = ((h_count - (circle_h + 20))**2 + (v_count - (circle_v - 15))**2) <= 8*8;

// Gura (semicerc jos)
wire mouth = ((h_count - circle_h)*(h_count - circle_h) + (v_count - (circle_v + 20))*(v_count - (circle_v + 20)) <= 25*25) &&
             (v_count > circle_v + 20);

// Fundalul feței (fără trăsături)
wire face_fill = face && !(eye_left || eye_right || mouth);

// Trăsăturile feței (ochi și gură)
wire face_detail = eye_left || eye_right || mouth;
	//detectie front pozitiv
reg btnR_prev, btnL_prev, btnU_prev,btnD_prev;

	wire en_r= btnR & ~btnR_prev;
	wire en_l= btnL & ~btnL_prev;
	wire en_u= btnU & ~btnU_prev;
	wire en_d= btnD & ~btnD_prev;

		//REGISTRU memorare stari
always@(posedge clk or posedge reset)begin
	if(reset)begin
		btnR_prev <=0;
		btnL_prev <=0;
		btnU_prev <=0;
		btnD_prev <=0;
	end else begin 
		btnR_prev <=btnR;
		btnL_prev <=btnL;
		btnU_prev <=btnU;
		btnD_prev <=btnD;
		end
end
	
	//Miscare Orizontala
always@ (posedge clk or posedge reset) begin
    if (reset)
        circle_h <= 960;
    else if (circle_h <= RADIUS || circle_h >= HV - RADIUS)
        circle_h <= 960;
    else begin
        if (en_l && circle_h > RADIUS)
            circle_h <= circle_h - 20;
        else if (en_r && circle_h < HV - RADIUS)
            circle_h <= circle_h + 20;
    end
end

	
	//Miscare Verticala
always@ (posedge clk or posedge reset) begin
    if (reset)
        circle_v <= 540;
    else if ((en_u && circle_v <= RADIUS) || (en_d && circle_v >= VV - RADIUS))
        circle_v <= 540;  // Reset când atinge marginea
    else begin
        if (en_u && circle_v > RADIUS)
            circle_v <= circle_v - 20;
        else if (en_d && circle_v < VV - RADIUS)
            circle_v <= circle_v + 20;
    end
end
	
always@(posedge clk or posedge reset)begin
	if(reset) 
	h_count<=0;
	 else if(h_count == HTOT-1)
		h_count <= 0;
	else
	h_count <= h_count+1;
end

always@(posedge clk or posedge reset)begin
	if(reset) 
	v_count<=0;
	else if(v_count == VTOT-1)
		v_count <= 0;
	else if (h_count== HTOT-1)
	v_count <= v_count+1;
end
always @(posedge clk or posedge reset) begin
    if (reset) begin
        vgaRed   <= 4'b0000;
        vgaGreen <= 4'b0000;
        vgaBlue  <= 4'b0000;
    end else if (video_on) begin
      if (face) begin
    if (face_fill) begin
        vgaRed   <= 4'b1111;
        vgaGreen <= 4'b1111;
        vgaBlue  <= 4'b0000;  // Galben față
    end else if (face_detail) begin
        vgaRed   <= 4'b0000;
        vgaGreen <= 4'b0000;
        vgaBlue  <= 4'b0000;  // Negru ochi/gură
    end
        end else begin
            vgaRed   <= 4'b1111;
            vgaGreen <= 4'b0000;
            vgaBlue  <= 4'b1111; 
        end
    end else begin
        vgaRed   <= 4'b0000;
        vgaGreen <= 4'b0000;
        vgaBlue  <= 4'b0000;
    end
end

endmodule