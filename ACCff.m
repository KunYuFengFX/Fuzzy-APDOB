function [sys] = ACCff(xcmd, gpd, Tk)
persistent In1Z1 Out1Z1 In2Z1 Out2Z1;
if isempty(In1Z1)
    In1Z1 = 0.0;
end
if isempty(Out1Z1)
    Out1Z1 = 0.0;
end
if isempty(In2Z1)
    In2Z1 = 0.0;
end
if isempty(Out2Z1)
    Out2Z1 = 0.0;
end

a = 2 + gpd*Tk;
b = 2 - gpd*Tk;
c = 2*gpd;
d = - 2*gpd;

In1    = xcmd; 
Out1   = (b/a)*Out1Z1 + (c/a)*In1 + (d/a)*In1Z1;
In1Z1  = In1;
Out1Z1 = Out1;
dxcmd  = Out1;

In2    = dxcmd;
Out2   = (b/a)*Out2Z1 + (c/a)*In2 + (d/a)*In2Z1;
In2Z1  = In2;
Out2Z1 = Out2;
ddxcmd = Out2;

sys = ddxcmd;