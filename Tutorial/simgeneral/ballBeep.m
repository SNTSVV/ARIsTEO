function y=ballBeep(u)
%Generate a sound when the ball hits the ground

%   Copyright 2007 The MathWorks, Inc.

    if(u(1) && (u(2) > 0))
        beep;
    end
    for i= 1:20000000*u(2);
    end
    y=u;