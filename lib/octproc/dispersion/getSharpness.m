function s = getSharpness(b_scan)
%returns the mean vertical gradient magnitude from a Sobel filter

% [~,~,Gv] = edge(a_scan, 'sobel', 0, 'vertical');
% s = max(abs(Gv))/mean(abs(Gv));

s = -sum(sum(b_scan.^4));

end

% Other metrics that haven't worked out:
% s = iqr(abs(Gv));
% s = mean(abs(Gv));