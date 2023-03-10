function [sys] = FourthOrderBPF(E, HatOmega)
persistent BPF1_InZ1 BPF1_OutZ1 BPF1_InZ2 BPF1_OutZ2;
persistent BPF2_InZ1 BPF2_OutZ1 BPF2_InZ2 BPF2_OutZ2;
global gb Tk;
if isempty(BPF1_InZ1)
    BPF1_InZ1 = 0.0;
end
if isempty(BPF1_OutZ1)
    BPF1_OutZ1 = 0.0;
end
if isempty(BPF1_InZ2)
    BPF1_InZ2 = 0.0;
end
if isempty(BPF1_OutZ2)
    BPF1_OutZ2 = 0.0;
end
if isempty(BPF2_InZ1)
    BPF2_InZ1 = 0.0;
end
if isempty(BPF2_OutZ1)
    BPF2_OutZ1 = 0.0;
end
if isempty(BPF2_InZ2)
    BPF2_InZ2 = 0.0;
end
if isempty(BPF2_OutZ2)
    BPF2_OutZ2 = 0.0;
end

a = 4 + 2*gb*Tk + HatOmega*HatOmega*Tk*Tk;
b = 8 - 2*HatOmega*HatOmega*Tk*Tk;
c = -4 + 2*gb*Tk - HatOmega*HatOmega*Tk*Tk;
d = 2*gb*Tk;
e = - 2*gb*Tk;

BPF1_In = E;
BPF1_Out = (b/a)*BPF1_OutZ1 + (c/a)*BPF1_OutZ2 + (d/a)*BPF1_In + (e/a)*BPF1_InZ2;
BPF1_InZ2  = BPF1_InZ1;
BPF1_InZ1  = BPF1_In;
BPF1_OutZ2 = BPF1_OutZ1;
BPF1_OutZ1 = BPF1_Out;

BPF2_In = BPF1_Out;
BPF2_Out = (b/a)*BPF2_OutZ1 + (c/a)*BPF2_OutZ2 + (d/a)*BPF2_In + (e/a)*BPF2_InZ2;
BPF2_InZ2  = BPF2_InZ1;
BPF2_InZ1  = BPF2_In;
BPF2_OutZ2 = BPF2_OutZ1;
BPF2_OutZ1 = BPF2_Out;

sys = BPF2_Out;

