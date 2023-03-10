clc
clear all
warning('off')

global Tk gp gamma ga gb r kappa lambda delata;
global MaxDelayTime HatOmega0 HatOmega Delay_tag;
clear functions

%ģ�����ƴ����ۼ���
Tag_act = 2000;

%����ʱ��
tEnd = 20;
COUNT = 0;
Switch_Time = 5;

%Motor����
gpd = 500;

%������[N/A]
Kt = 0.24;
%����[kg]
M = 0.3;

%����ģ�Ͳ���
Ktn = 0.24;
Mn = 0.3;

%��������
Kp = 2500;
%΢������
Kv = 100;

%APDOB����
%����ʱ��
Tk = 0.0001;

%Q-filter��ֹƵ��[rad/s]
gp = 1000;
%Q-filter��Ʋ���
gamma = 0.5;

%����ӳ�ʱ��
MaxDelayTime = 10;

%��ʼ����Ƶ��
HatOmega0 = 100;
HatOmega = HatOmega0;

%���
APDOB_e_Omega = 0.0;
APDOB_edt_Omega = 0.0;

%���������Ĺ�ȥֵ
APDOB_e_Omega_last = 0.0;

%Delay��tag����ֹDelay��N��<0ʱϵͳ����
Delay_tag = 0;

u  = 0.0;
y  = 0.0;
Dp = 0.0;
t  = 0.0;
E  = 0.0;

rcd_t = [];%zeros(1, Sample_amount);
rcd_HatOmega = [];%zeros(1, Sample_amount);
rcd_y = [];%zeros(1, Sample_amount);

rcd_ga = [];
rcd_gb = [];
rcd_r = [];
rcd_kappa = [];
rcd_lambda = [];
rcd_delata = [];

FuzzyC_final = readfis('Data\FuzzyControllerOptimizedByDE.fis');

Total = tEnd / Tk;

T_stag = Tag_act;

Fitness = 0;

%�ͷ�����
Minus_omega1 = 100;
Minus_omega2 = 80;
Minus_omega3 = 80;
Plus_omega1  = 110;
Plus_omega2  = 110;
Plus_omega3  = 120;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                     APDOB                       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
while 1
    %ͨ��ģ���������õ�PID����������
    if T_stag == Tag_act
        Fz_output = evalfis([APDOB_e_Omega, APDOB_edt_Omega]', FuzzyC_final);
        T_stag = 1;
        COUNT = COUNT+1;
    else
        T_stag = T_stag + 1;
    end
    
    %Q-filter������Ʋ���
    ga     = Fz_output(1);
    gb     = Fz_output(2);
    r      = Fz_output(3);
    kappa  = round(Fz_output(4));
    lambda = Fz_output(5);
    delata = Fz_output(6);

    E = InverseModel(u, y, Mn, Ktn, gpd, Tk);
    HatOmega = ANF(E);
    HatDp = Qfilter(E);
  
    xcmd = 0.0;
    ddxref = PDctr(xcmd, y, Kp, Kv, gpd, Tk) + ACCff(xcmd, gpd, Tk);
    u = (1/Ktn) * (Mn*ddxref + HatDp);
    
    for i = 1:1:100
        if (t<Switch_Time)
            Omega = 100;
            desire_Omega = Omega;
        elseif (t>=Switch_Time) && (t<2*Switch_Time)
            Omega = 110;
            desire_Omega = Omega;
            if HatOmega < Minus_omega1
                Minus_omega1 = HatOmega;
            end
            if HatOmega > Plus_omega1
                Plus_omega1 = HatOmega;
            end
        elseif (t>=2*Switch_Time) && (t<3*Switch_Time)
            Omega = 80;
            desire_Omega = Omega;
            if HatOmega < Minus_omega2
                Minus_omega2 = HatOmega;
            end
            if HatOmega > Plus_omega2
                Plus_omega2 = HatOmega;
            end
        elseif (t>=3*Switch_Time)
            Omega = 120;
            desire_Omega = Omega;
            if HatOmega < Minus_omega3
                Minus_omega3 = HatOmega;
            end
            if HatOmega > Plus_omega3
                Plus_omega3 = HatOmega;
            end
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
    
    APDOB_e_Omega   = desire_Omega - HatOmega;
    APDOB_edt_Omega = (APDOB_e_Omega - APDOB_e_Omega_last)/Tk;
    APDOB_e_Omega_last = APDOB_e_Omega;
    
    Fitness = Fitness + abs(desire_Omega-HatOmega);
    
    rcd_t(round(t/Tk)) = t;
    rcd_HatOmega(round(t/Tk)) = HatOmega;
    rcd_y(round(t/Tk)) = y;
    
    rcd_ga(round(t/Tk)) = ga;
    rcd_gb(round(t/Tk)) = gb;
    rcd_r(round(t/Tk)) = r;
    rcd_kappa(round(t/Tk)) = kappa;
    rcd_lambda(round(t/Tk)) = lambda;
    rcd_delata(round(t/Tk)) = delata;
    
    if t > tEnd 
        break;
    end
end
Fitness = Fitness / Total + 0.05*(abs(100 - Minus_omega1) + abs(80 - Minus_omega2) + abs(Plus_omega1 - 110) + abs(Plus_omega2 - 110) + abs(80 - Minus_omega3) + abs(120 - Plus_omega3)) + 100*Delay_tag;
disp(num2str(COUNT));

figure
plot(rcd_t, 1000*rcd_y);
xlabel('ʱ�� [s]'); 
ylabel('λ����� [mm]');
xlim([0, 20]);
ylim([-0.5, 0.5]);
figure
plot(rcd_t, rcd_HatOmega);
xlabel('ʱ�� [s]');
xlim([0, 20]);
%ylim([97.5, 112.5]);
ylabel('HatOmega [rad/s]');
disp(['Fitness = ', num2str(Fitness)]);

figure
plot(rcd_t, rcd_ga);
xlim([0, 20]);
xlabel('ʱ�� [s]'); 
ylabel('ga');
figure
plot(rcd_t, rcd_gb);
xlim([0, 20]);
xlabel('ʱ�� [s]'); 
ylabel('gb');
figure
plot(rcd_t, rcd_r);
xlim([0, 20]);
xlabel('ʱ�� [s]'); 
ylabel('r');
figure
plot(rcd_t, rcd_kappa);
xlim([0, 20]);
xlabel('ʱ�� [s]'); 
ylabel('kappa');
figure
plot(rcd_t, rcd_lambda);
xlim([0, 20]);
xlabel('ʱ�� [s]'); 
ylabel('lambda');
figure
plot(rcd_t, rcd_delata);
xlim([0, 20]);
xlabel('ʱ�� [s]'); 
ylabel('delata');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%