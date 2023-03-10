function [sys] = Delay(HatD, N)
global MaxDelayTime Tk Delay_tag;
persistent DelayCount DelayMemory;
if isempty(DelayCount)
    DelayCount = 0;
end
if isempty(DelayMemory)
    DelayMemory = zeros(1,round((MaxDelayTime+0.1)/Tk));
end

DelayCountReset = round(MaxDelayTime/Tk);

%if (DelayCount+1) < 1
%    disp('DelayCount is minus');
%end
%if (DelayCount+1) > DelayCountReset
%    disp('DelayCount exceeds');
%end

DelayMemory(DelayCount+1) = HatD;

DelayNum = DelayCount - N;

if (DelayNum < 0)
    DelayNum = DelayNum + DelayCountReset + 1;
    if (DelayNum < 0)
        DelayNum = 0;
        Delay_tag = 1;
    end
end

DelayCount = DelayCount + 1;

if (DelayCount > DelayCountReset) 
    DelayCount = 0;
end

sys = DelayMemory(DelayNum+1);