function [sys] = FirstOrderLPFQ(E)
global gp Tk;
persistent LPFQ_InZ1 LPFQ_OutZ1;
if isempty(LPFQ_InZ1)
    LPFQ_InZ1 = 0.0;
end
if isempty(LPFQ_OutZ1)
    LPFQ_OutZ1 = 0.0;
end

a = 2 + gp*Tk;
b = 2 - gp*Tk;
c = gp*Tk;
d = gp*Tk;

LPFQ_In = E;
LPFQ_Out = (b/a)*LPFQ_OutZ1 + (c/a)*LPFQ_In + (d/a)*LPFQ_InZ1;
LPFQ_InZ1  = LPFQ_In;
LPFQ_OutZ1 = LPFQ_Out;

sys = LPFQ_Out;