function [sys] = PDctr(xcmd, y, Kp, Kv, gpd, Tk)
persistent In1Z1 Out1Z1 
if isempty(In1Z1)
    In1Z1 = 0.0;
end
if isempty(Out1Z1)
    Out1Z1 = 0.0;
end

e = xcmd - y;
a = 2 + gpd*Tk;
b = 2 - gpd*Tk;
c = 2*gpd;
d = - 2*gpd;
    
In1    = e; 
Out1   = (b/a)*Out1Z1 + (c/a)*In1 + (d/a)*In1Z1;
In1Z1  = In1;
Out1Z1 = Out1;
de     = Out1; 

Output = Kp*e + Kv*de;
sys  = Output;