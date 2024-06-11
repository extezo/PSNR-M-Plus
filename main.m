close all;
clear variables;
VIDEO_FOLDER='C:\123\456\';
CURRENT_VIDEO_FOLDER='789';
REFERENCE_NAME='1.yuv';
DISTORTED_NAME='2.yuv';
WIDTH = 1920;
HEIGHT = 1080;

videoPlayer = vision.VideoPlayer('Position', [100 100 1920*0.6 1080*0.6]);
folder = fullfile(VIDEO_FOLDER, CURRENT_VIDEO_FOLDER);
figure


plot(continuous_subj_score)

fid = fopen(fullfile(folder, DISTORTED_NAME) ,'r');
fid_r = fopen(fullfile(folder, REFERENCE_NAME), 'r');
figure

load('H.mat')
f_max = 1 / 32;


[yr_prev, ~, ~] = yuvRead(fid_r, WIDTH, HEIGHT);
[~,~,~] = yuvRead(fid, WIDTH, HEIGHT);
PSNRm = zeros(1,Nframes);
Ws = ones(HEIGHT, WIDTH, vid_fps);
Wt = ones(HEIGHT, WIDTH, vid_fps);
Wp = ones(HEIGHT, WIDTH, vid_fps);

cur_w_idx = 1;
i = 1;
for idx = 2:Nframes
    [y,~,~] = yuvRead(fid, WIDTH, HEIGHT);
    if (BASE == 2 && is_rebuffered_bool(idx) == 1)
        continue
    end
    i = i + 1;
    [yr, ur, vr] = yuvRead(fid_r, WIDTH, HEIGHT);
    Ir = yuv2rgb(yr, ur, vr);
    yr = double(yr);
    ROI = segm(yr);
    w_s = createSpatialWeights(yr, hs);
    w_t = createTemporalWeights(yr, yr_prev,ROI, Ht, Htf, HtI, f_max, vid_fps);
    [w_p, y_roi, x_roi] = createPeriphericalWeights(yr, ROI);
    Ws(:,:,cur_w_idx) = w_s;
    Wt(:,:,cur_w_idx) = w_t;
    Wp(:,:,cur_w_idx) = w_p;
    PSNRm(i) = psnrM(double(yr), double(y), Ws, Wt, Wp, cur_w_idx);
    fprintf('Frame:%u (%u%%), PSNRm = %f, PSNR = %f, diff = %f\n', ...
        i, floor(i * 100 / Nframes), PSNRm(i), PSNR_vec(i), ...
        PSNRm(i) - PSNR_vec(i));
    yr_prev = yr;
    cur_w_idx = rem(cur_w_idx, vid_fps) + 1;
    y_roi = floor(max(y_roi,2));
    x_roi = floor(max(x_roi,2));
    Ir(y_roi-1:y_roi+1, x_roi-1:x_roi+1,:) = 0;
    Ir(y_roi, x_roi,2) = 255;
    
    videoPlayer.step(Ir);
end

if (BASE == 2)
    continuous_subj_score = continuous_subj_score(~is_rebuffered_bool);
    PSNRm = PSNRm(1:N_playback_frames);
end
