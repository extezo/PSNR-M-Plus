load('psnr.mat');
figure
plot(PSNR_vec)
hold on;
plot(PSNRm);
max_val = max(max([PSNR_vec(30:end); PSNRm(30:end)]));
min_val = min(min([PSNR_vec(30:end); PSNRm(30:end)]));
ylim([min_val - 5 max_val + 5]);
yyaxis right;
plot(continuous_subj_score);
legend('PSNR', 'PSNR-2M', 'Субъективная');
set(gca,'Fontsize',20);
set(gca,'defaultAxesColorOrder',[0 0 0; 0 0 0]);
set(gca,'ycolor','k')
xlabel('Кадр')
ylabel('Субъективная оценка');
yyaxis left;
ylabel('Объективная оценка, дБ');

c_mat = corr([continuous_subj_score(30:end); PSNR_vec(30:end); PSNRm(30:end);]');