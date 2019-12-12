function mse = opt_OCT_reg(dx_dy_shy, fix_img, mov_img)
%opt_OCT_reg Optimizes translation and vertical shear of OCT images

tform = affine2d();
tform.T(3,1) = dx_dy_shy(1);
tform.T(3,2) = dx_dy_shy(2);
tform.T(1,2) = dx_dy_shy(3);

% Warp the image by this matrix
fixedRefObj = imref2d(size(fix_img));
moveRefObj  = imref2d(size(mov_img));
reg_move_img = imwarp(mov_img, moveRefObj, ...
        tform, 'OutputView', fixedRefObj, ...
        'SmoothEdges', true, 'interp', 'cubic', ...
        'fillvalues', mean(mov_img(:)));

% Measure image error
mse = immse(fix_img, reg_move_img);

end

