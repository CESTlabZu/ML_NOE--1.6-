function theWidth = fwhm(signal,k)
    peakHeight = max(signal);
    x1 = find(signal >= 0.5*peakHeight, 1, 'first');
    x2 = find(signal >= 0.5*peakHeight, 1, 'last');
    theWidth = abs(k(x2)-k(x1)); 
end