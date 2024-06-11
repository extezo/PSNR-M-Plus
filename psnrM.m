function PSNRM = psnrM(Y, Yref, Ws, Wt, Wp, idx)

Ws = Ws.^2;
Wt = Wt.^2;
Wp = Wp.^2;

Ws_cur = Ws(:,:, idx);
Wt_cur = Wt(:,:, idx);
Wp_cur = Wp(:,:, idx);

Yref = Yref(:);
Y = Y(:);

Ws = Ws(:);
Wt = Wt(:);
Wp = Wp(:);
Ws_cur = Ws_cur(:);
Wt_cur = Wt_cur(:);
Wp_cur = Wp_cur(:);

MSEM = sum((Yref-Y).^2 .*Ws_cur.*Wt_cur.* Wp_cur)/ numel(Y);
MSEM = MSEM / sum(Ws .* Wt .* Wp) * numel(Ws);
PSNRM = 255 / sqrt(MSEM);
PSNRM = 20 * log10(PSNRM);