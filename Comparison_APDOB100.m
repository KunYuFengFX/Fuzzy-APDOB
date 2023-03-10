close all
clc
clear all

global Tk gp gamma ga gb r kappa lambda delata;
global MaxDelayTime HatOmega0 HatOmega;
%Sim. time
tEnd = 20;
Switch_Time = 5;

%Motor parameter
gpd = 500;

%Thrust/Torque constant[N/A]
Kt = 0.24;
%Mass[kg]
M = 0.3;

%Nominal model
Ktn = 0.24;
Mn = 0.3;

%Gain
Kp = 2500;
Kv = 100;

%APDOB parameters
%Sampling time
Tk = 0.0001;

%Q-filter cut-off frequency [rad/s]
gp = 1000;
%Q-filter design parameter
gamma = 0.5;

mode = input('1 -- Comparison method: DELS-based APDOB   2 -- Comparison method: APDOB\n');
switch(mode)
    case 1
        % Additional design parameters optimized by DELS (comparison method)
        ga = 45.1;
        gb = 21.01;
        r = 0.1;
        kappa = 28;
        lambda = 0.9962;
        delata = 5030;
    case 2
        % Additional design parameters (comparison method)
        ga = 25;
        gb = 15;
        r = 0.5;
        kappa = 30;
        lambda = 0.999;
        delata = 1000;
end

%Max delay time
MaxDelayTime = 10;
%Initial fundamental frequency
HatOmega0 = 100;
HatOmega = HatOmega0;

tag = 1;

%Data record    
rcd_t = [];
rcd_HatOmega = [];
rcd_y = [];

u  = 0.0;
y  = 0.0;
Dp = 0.0;
t  = 0.0;
E  = 0.0;

while 1
    
    E = InverseModel(u, y, Mn, Ktn, gpd, Tk);
    HatOmega = ANF(E);
    HatDp = Qfilter(E);
  
    xcmd = 0.0;
    ddxref = PDctr(xcmd, y, Kp, Kv, gpd, Tk) + ACCff(xcmd, gpd, Tk);
    u = (1/Ktn) * (Mn*ddxref + HatDp);
    
    for i = 1:1:100
        if (t<Switch_Time)
            Omega = 100;
        elseif (t>=Switch_Time) && (t<2*Switch_Time)
            Omega = 110;
        elseif (t>=2*Switch_Time) && (t<3*Switch_Time)
            Omega = 80;
        elseif (t>=3*Switch_Time)
            Omega = 120;
        end
        
        Dp = 0.0;
        
        for j = 1:1:10
            Dp = Dp + sin(j*Omega*t);
        end  
        
        y = Motor(u, Dp, M, Kt, 0.01*Tk);
        t = t + 0.01*Tk;
    end
    
    
    if mod(round(t/Tk), round(1/Tk)) == 0
        disp([ '---------------- ', num2str(t), ' s', ' ----------------'])
        disp(['Fundamental Frequency :', num2str(Omega), ' rad/s']);
        disp(['Estimated Frequency   :', num2str(HatOmega), ' rad/s']);
        disp(['Control Error         :', num2str(1000*(xcmd - y)), ' mm']);
    end
    
    rcd_t(round(t/Tk)) = t;
    rcd_HatOmega(round(t/Tk)) = HatOmega;
    rcd_y(round(t/Tk)) = y;
    
    if t > tEnd 
        break;
    end
end

if tag == 1
    figure
    p1 = plot(rcd_t, 1000*rcd_y);
    xlabel('Time [s]'); 
    ylabel('Position Error [mm]');
    xlim([0, 20]);
    ylim([-0.5, 0.5]);
    figure
    p2 = plot(rcd_t, rcd_HatOmega);
    xlabel('Time [s]');
    xlim([0, 20]);
    ylabel('Hatomega [rad/s]');
end