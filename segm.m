function ROI = segm(GG)

%Ввод значения площади в процентном соотношении, которая отводится для ROI.
smpr=15;
%Вычисление градиента.
hy = fspecial('sobel');
hx = hy';
Gy = imfilter(double(GG), hy, 'replicate');
Gx = imfilter(double(GG), hx, 'replicate');
gradmag = sqrt(Gx.^2 + Gy.^2);
%Морфологические операции: размыкание, эрозия, реконструкция, замыкание, дилатация.
se = strel('disk',20); 
Ge = imerode(GG, se);
Gobr = imreconstruct(Ge, GG);
Gobrd = imdilate(Gobr, se);
Gobrcbr = imreconstruct(imcomplement(Gobrd), imcomplement(Gobr)); 
Gobrcbr = imcomplement(Gobrcbr);
%Нахождение всех локальных максимумов.
fgm = imregionalmax(Gobrcbr);
%Разметка изображения маркерами переднего плана.
G2 = GG;
G2(fgm) = 255;
%Уменьшение размеров маркеров, что позволяет избежать попадания их за границы объектов.
se2 = strel(ones(5,5));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);
%Уменьшение изолированных маркеров, размеры которых меньше заданного числа пикселей.
fgm4 = bwareaopen(fgm3, 20);
G3 = GG;
G3(fgm4) = 255;
%Вычисление маркеров фона.
bw = im2bw(Gobrcbr, graythresh(Gobrcbr));

%Уменьшение размеров маркеров фона во избежание их соприкосновения вплотную с маркерами переднего плана.
D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
%Выполнение процедуры минимального подъема.
gradmag2 = imimposemin(gradmag, bgm | fgm4);
%Вычисление сегментации по водоразделам.
L = watershed(gradmag2);
%Вычисление максимального количества выделенных сегментов.
lmax=max(L(:));
%Нахождение центра изображения.
[y, x]=size(GG);
Cx=round(x/2);
Cy=round(y/2);

%Вычисление квадратов расстояний от центра изображения до центров выделенных сегментов.

q = zeros(lmax, 1);
for k = 1: lmax
    bw_img = L == k;
    stats = regionprops(bw_img, 'Centroid');
    centroid = stats.Centroid;
    diffx=(centroid(1)-Cx); 
    diffy=(centroid(2)-Cy);
    q(k)=diffx^2+diffy^2;
end

%Сортировка элементов по возрастанию. 
[~, ind]=sort(q);

%Нахождение численного значения площади, которая отводится для ROI.
smax= numel(GG)*smpr/100;
%В цикле выполняется переупорядочение значений массива L в соответствии с увеличением удаленности сегментов от центра изображения.
SL=L;

for k = 1:lmax
    SL(L==ind(k))=k;
end

%В цикле происходит вычисление площадей сегментов, которые были переупорядочены в предыдущем цикле.

tcnt=zeros(lmax,1); 

for a=1:lmax
   bw_img = SL == a;
   tcnt(a) = sum(bw_img(:));
end

%В цикле производится оценка количества сегментов, которые необходимо отнести к ROI в соответствии с smax.
s0=0;
a=1;
while s0<=smax && a<=lmax
      s0=s0+tcnt(a);
      a=a+1;
end
nobjS=a-1;

%В цикле создается двоичная маска. Из упорядоченного массива SL выбирается nobjS сегментов, которым присваивается значение «1», остальным значениям присваивается «0». 
ROI = SL <= nobjS;
%Медианная фильтрация применяется для удаления ложных контуров.
ROI=medfilt2(ROI, [7,7]);
end