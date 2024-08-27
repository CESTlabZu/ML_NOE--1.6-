function y = spectrum(amp, width, off)
    max=2000;
    step=50;
    delB0 = 0.5;
    offset= -max:step:max;
    rffreq=[-4000, -3500, -3000, -2500, offset, 2500, 3000,3500,4000]*delB0;
    y = amp./(1+((((rffreq-off)*2*pi).^2)./((0.5*(abs(width))).^2)));
end