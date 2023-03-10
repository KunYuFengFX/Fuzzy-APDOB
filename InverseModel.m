function [sys] = InverseModel(u, y, Mn, Ktn, gpd, Tk)
persistent In1Z1 Out1Z1 In2Z1 Out2Z1;
if isempty(In1Z1) %|| fcn_tag == 0
    In1Z1 = 0.0;
end
if isempty(Out1Z1) %|| fcn_tag == 0
    Out1Z1 = 0.0;
end
if isempty(In2Z1) %|| fcn_tag == 0
    In2Z1 = 0.0;
end
if isempty(Out2Z1) %|| fcn_tag == 0
    Out2Z1 = 0.0;
end

Fref = Ktn * u;

a = 2 + gpd*Tk;
b = 2 - gpd*Tk;
c = 2*gpd;
d = - 2*gpd;

In1 = y;
Out1 = (b/a)*Out1Z1 + (c/a)*In1 + (d/a)*In1Z1;
In1Z1 = In1;
Out1Z1 = Out1;
dy = Out1;

In2 = dy;
Out2 = (b/a)*Out2Z1 + (c/a)*In2 + (d/a)*In2Z1;
In2Z1 = In2;
Out2Z1 = Out2;
ddy = Out2;

Fact = Mn * ddy;
E = Fref - Fact;

sys = E;
