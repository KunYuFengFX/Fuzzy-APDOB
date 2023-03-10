function [sys] = Qfilter(E)
global gamma gp Tk HatOmega;

M_PI = 3.14159;

HatD = FirstOrderLPFQ(E);

N = round((2*M_PI*gp*gamma - HatOmega)/(Tk*gp*HatOmega*gamma));
HatDp = HatD - gamma*(HatD - Delay(HatD, N));

sys = HatDp;