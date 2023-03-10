function [sys] = ANF(E)
persistent HatEtaZ1 HatEtaZ2 TildeDZ1 TildeDZ2;
persistent P count xi; 

global HatOmega0 HatOmega;
global Tk r kappa lambda delata;

if isempty(HatEtaZ1)
    HatEtaZ1 = 0.0;
end
if isempty(HatEtaZ2)
    HatEtaZ2 = 0.0;
end
if isempty(TildeDZ1)
    TildeDZ1 = 0.0;
end
if isempty(TildeDZ2)
    TildeDZ2 = 0.0;
end
if isempty(P)
    P = 1/delata;
end
if isempty(count)
    count = 0.0;
end
if isempty(xi)
    xi = -2*cos(HatOmega0*Tk);
end

TildeD = FourthOrderBPF(E, HatOmega);

alpha = -r*HatEtaZ1 + TildeDZ1;
beta = -r*r*HatEtaZ2 + TildeD + TildeDZ2;
HatEta = alpha*xi + beta;

TildeDZ2 = TildeDZ1;
TildeDZ1 = TildeD;
HatEtaZ2 = HatEtaZ1;
HatEtaZ1 = HatEta;

if count > (kappa-1)
    g     = (P*alpha)/(lambda+P*alpha*alpha);
    e     = 0.0 - HatEta;
    xi    = xi + g*e;
    P     = (1/lambda)*(P-g*alpha*P);
    count = 0;
end
count = count+1;

if xi < -2
    TildeOmega = (1/Tk)*acos(-0.5*-2);
elseif xi > 2
    TildeOmega = (1/Tk)*acos(-0.5*2);
else
    TildeOmega = (1/Tk)*acos(-0.5*xi);
end

HatOmega = FirstOrderLPFqa(TildeOmega);

sys = HatOmega;

