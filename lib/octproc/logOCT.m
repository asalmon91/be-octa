function logvol = logOCT(vol)
%logOCT generates the default log intensities for a Bioptigen OCT

logvol = uint16(log10((vol./2048)+1).*25000);

end

