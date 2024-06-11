function ROI = segm(GG)

%���� �������� ������� � ���������� �����������, ������� ��������� ��� ROI.
smpr=15;
%���������� ���������.
hy = fspecial('sobel');
hx = hy';
Gy = imfilter(double(GG), hy, 'replicate');
Gx = imfilter(double(GG), hx, 'replicate');
gradmag = sqrt(Gx.^2 + Gy.^2);
%��������������� ��������: ����������, ������, �������������, ���������, ���������.
se = strel('disk',20); 
Ge = imerode(GG, se);
Gobr = imreconstruct(Ge, GG);
Gobrd = imdilate(Gobr, se);
Gobrcbr = imreconstruct(imcomplement(Gobrd), imcomplement(Gobr)); 
Gobrcbr = imcomplement(Gobrcbr);
%���������� ���� ��������� ����������.
fgm = imregionalmax(Gobrcbr);
%�������� ����������� ��������� ��������� �����.
G2 = GG;
G2(fgm) = 255;
%���������� �������� ��������, ��� ��������� �������� ��������� �� �� ������� ��������.
se2 = strel(ones(5,5));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);
%���������� ������������� ��������, ������� ������� ������ ��������� ����� ��������.
fgm4 = bwareaopen(fgm3, 20);
G3 = GG;
G3(fgm4) = 255;
%���������� �������� ����.
bw = im2bw(Gobrcbr, graythresh(Gobrcbr));

%���������� �������� �������� ���� �� ��������� �� ��������������� �������� � ��������� ��������� �����.
D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
%���������� ��������� ������������ �������.
gradmag2 = imimposemin(gradmag, bgm | fgm4);
%���������� ����������� �� ������������.
L = watershed(gradmag2);
%���������� ������������� ���������� ���������� ���������.
lmax=max(L(:));
%���������� ������ �����������.
[y, x]=size(GG);
Cx=round(x/2);
Cy=round(y/2);

%���������� ��������� ���������� �� ������ ����������� �� ������� ���������� ���������.

q = zeros(lmax, 1);
for k = 1: lmax
    bw_img = L == k;
    stats = regionprops(bw_img, 'Centroid');
    centroid = stats.Centroid;
    diffx=(centroid(1)-Cx); 
    diffy=(centroid(2)-Cy);
    q(k)=diffx^2+diffy^2;
end

%���������� ��������� �� �����������. 
[~, ind]=sort(q);

%���������� ���������� �������� �������, ������� ��������� ��� ROI.
smax= numel(GG)*smpr/100;
%� ����� ����������� ���������������� �������� ������� L � ������������ � ����������� ����������� ��������� �� ������ �����������.
SL=L;

for k = 1:lmax
    SL(L==ind(k))=k;
end

%� ����� ���������� ���������� �������� ���������, ������� ���� ��������������� � ���������� �����.

tcnt=zeros(lmax,1); 

for a=1:lmax
   bw_img = SL == a;
   tcnt(a) = sum(bw_img(:));
end

%� ����� ������������ ������ ���������� ���������, ������� ���������� ������� � ROI � ������������ � smax.
s0=0;
a=1;
while s0<=smax && a<=lmax
      s0=s0+tcnt(a);
      a=a+1;
end
nobjS=a-1;

%� ����� ��������� �������� �����. �� �������������� ������� SL ���������� nobjS ���������, ������� ������������� �������� �1�, ��������� ��������� ������������� �0�. 
ROI = SL <= nobjS;
%��������� ���������� ����������� ��� �������� ������ ��������.
ROI=medfilt2(ROI, [7,7]);
end