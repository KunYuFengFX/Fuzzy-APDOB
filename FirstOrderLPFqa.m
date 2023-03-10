function [sys] = FirstOrderLPFqa(TildeOmega)
global ga Tk HatOmega0;
persistent LPFqa_InZ1 LPFqa_OutZ1;
if isempty(LPFqa_InZ1)
    LPFqa_InZ1 = 0.0;
end
if isempty(LPFqa_OutZ1)
    LPFqa_OutZ1 = HatOmega0;
end

a = 2 + ga*Tk;
b = 2 - ga*Tk;
c = ga*Tk;
d = ga*Tk;

LPFqa_In = TildeOmega;
LPFqa_Out = (b/a)*LPFqa_OutZ1 + (c/a)*LPFqa_In + (d/a)*LPFqa_InZ1;
LPFqa_InZ1  = LPFqa_In;
LPFqa_OutZ1 = LPFqa_Out;

sys = LPFqa_Out;