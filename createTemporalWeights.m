function wt = createTemporalWeights(y, y_prev, ROI, Ht, Htf, HtI, fmax, fps)
%CREATETEMPORALWEIGHTS Summary of this function goes here
%   Detailed explanation goes here
mb_size = 16;
[h, w] = size(y);
mb_h = floor(h / mb_size);
mb_w = floor(w / mb_size);

vectors = motionEstARPS(y, y_prev, mb_size, 32);
vectors = vectors(:,1:mb_h * mb_w);
vectors_y = reshapeVectorComponent(vectors, mb_h, mb_w, 1);
vectors_x = reshapeVectorComponent(vectors, mb_h, mb_w, 2);

vectors_y = imresize(vectors_y, mb_size);
vectors_x = imresize(vectors_x, mb_size);
[v_h, v_w] = size(vectors_y);
vectors_y = padarray(vectors_y, [h - v_h, w - v_w], 'replicate', 'post');
vectors_x = padarray(vectors_x, [h - v_h, w - v_w], 'replicate', 'post');

% imshow(y .* ROI / 255);
% pause(0.1);
avg_vector_x = mean(mean(vectors_x(ROI)));
avg_vector_y = mean(mean(vectors_y(ROI)));

vectors_x = abs(vectors_x - avg_vector_x);
vectors_y = abs(vectors_y - avg_vector_y);

vectors = sqrt(vectors_y.^2 + vectors_x.^2);

ft = vectors * fmax * fps;
wt = koefSens(y / 255, ft);
% wt = interp2(Htf, HtI, Ht, ft, y, 'bilinear', 3);
%imshow(wt / max(wt(:)))
end 

