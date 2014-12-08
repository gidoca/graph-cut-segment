function [fdist bdist] = colorModel(img, fmask, bmask)
    img = im2double(img);
    % get all pixel colors in a 3 x (#pixels) array
    colors = reshape(shiftdim(img,2),3,size(img,1)*size(img,2));
    % get all pixel coordinates in a 2 x (#pixels) array
    x = zeros(size(img,1),size(img,2),2);
    [x(:,:,1) x(:,:,2)] = meshgrid(1:size(img,2),1:size(img,1));
    x = reshape(shiftdim(x,2),2,size(img,1)*size(img,2));
    % get the foreground and background masks in a 1 x (#pixels) array
    fmask = reshape(fmask,1,size(img,1)*size(img,2));
    bmask = reshape(bmask,1,size(img,1)*size(img,2));
    % get the indices of the foreground and background pixels
    [tt ttt findices] = intersect(x', (x.*[fmask; fmask])', 'rows');
    [tt ttt bindices] = intersect(x', (x.*[bmask; bmask])', 'rows');
    % extract only labeled foreground and background pixels
    fcolors = colors(:,findices);
    fdist = gmdistribution.fit(fcolors', 2, 'Regularize', 1e-5);
    bcolors = colors(:,bindices);
    bdist = gmdistribution.fit(bcolors', 2, 'Regularize', 1e-5);
end