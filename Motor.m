function [sys] = Motor(u, d, M, Kt, Ts)
persistent xZ1 dxZ1 ddxZ1;
if isempty(xZ1)
    xZ1 = 0.0;
end
if isempty(dxZ1)
    dxZ1 = 0.0;
end
if isempty(ddxZ1)
    ddxZ1 = 0.0;
end
dx = 0.0;

F     = Kt*u - d;
ddx   = F/M; 
x     = xZ1 + Ts*0.5*(dx + dxZ1); 
%disp(['dx_pre   = ', num2str(dx)]);
dx    = dxZ1 + Ts*0.5*(ddx + ddxZ1);
%disp(['dx_after = ', num2str(dx)]);
xZ1   = x;
dxZ1  = dx;
ddxZ1 = ddx;

sys = x;
