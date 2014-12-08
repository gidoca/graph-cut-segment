function out = graphCutSegment(img, fgmask, bgmask, gamma)
    img = im2double(img);
    [fgdist bgdist] = colorModel(img, fgmask, bgmask);
    % get all pixel colors in a 3 x (#pixels) array
    colors = reshape(shiftdim(img,2),3,size(img,1)*size(img,2));
    nPixels = size(colors, 2);
    
    class = zeros(1, nPixels);
    
    fgdist = -log(pdf(fgdist, colors') + .00001);
    fgdist(bgmask) = -log(.00001);
    fgdist(fgmask) = 0;
    bgdist = -log(pdf(bgdist, colors') + .00001);
    bgdist(bgmask) = 0;
    bgdist(fgmask) = -log(.00001);
    
    unary = single([fgdist'; bgdist']);
    
    labelcost = single([0, 1; 1, 0]);
    
    avg = sum(colors,2)/size(colors,2);
    beta = sum(sum( (colors - repmat(avg, 1, nPixels)).* (colors - repmat(avg, 1, nPixels)) )) / nPixels;
    beta = 1/(2*beta);
    
    range = 1:nPixels;
    p = repmat(range, 1, 8);
    % Find 8-pixel neighbourhood
    q = [range - 1, range + 1, range - size(img, 1), range + size(img, 1), range - 1 - size(img, 1), range - 1 + size(img, 1), range + 1 - size(img, 1), range + 1 + size(img, 1)];
    
    % Remove pixels outside of the image
    condition = (1 <= q) & (q <= nPixels);
    p = p(condition);
    q = q(condition);
    dist = colors(:, p) - colors(:, q);
    E = gamma * exp(-beta * (dist(1, :) .^ 2 + dist(2, :) .^ 2 + dist(3, :) .^ 2));
    pairwise = sparse(p, q, E, nPixels, nPixels);
    
    out = GCMex(class, unary, pairwise, labelcost);
    out = reshape(out, size(img, 1), size(img, 2));
end