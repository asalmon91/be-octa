function d = decorrelation(img1, img2)
d = (img1 .* img2) ./ (0.5 .* img1.^2 + 0.5 .* img2.^2);
end