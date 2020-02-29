%compute the hough space and accumulate if there's a line i put in that 
image=im2double(imread('coins.png'));
thresh=[0.18,0.65];
sigma=1;
BW=edge(image,'canny',thresh,1);
imshow(image+BW)

%voting algorithm
s=size(image)
radiimax=20:0.1:30;
Accumulator=zeros(s(1),s(2),length(radiimax));
for i=1:s(1)
    for j=1:s(2)
        if BW(i,j)==1
            for rID = 1:length(radiimax)
                r=radiimax(rID);
                for t= 0:360
                    a=round(i-r*cos(t*pi/180));
                    b=round(j-r*sin(t*pi/180));
                  if a>0 && b>0 && a<s(1) && b<s(2)
                
                         Accumulator(a,b,rID)=Accumulator(a,b,rID)+1;
                           end
                     end
                 end
        end
    end
end

%displaying the peaks
maximum = zeros(length(radiimax),1);
for r = 1:length(radiimax)
    maximum(r) = max(max(Accumulator(:,:,r)));
end

[mm, idxs] = findpeaks(maximum, 'SortStr', 'descend', 'MinPeakWidth', 5);
figure(2);
imshow(image);

hold on
for i=1:numel(idxs) % limit the number of maxima, we only want to find two coin sizes
   idx = idxs(i);
   % expand the peaks with a large dilate
   base = Accumulator(:,:,idx);
   dse = strel('disk', 10);
   im = imdilate(base, dse);
   rad = 0.1 * idx + 20;
   for x=1:size(im,1)
       for y=1:size(im,2)
           % if the im(x,y) was unchanged from the dilate, 
           % it's the center of a circle!
           if im(x,y) == base(x,y) && im(x,y) > 150
               % rad+1 to compansate for the width of the circle stroke
               viscircles([y,x], rad+1, 'Color', 'w');
               text(y,x, num2str(rad), ...
                    'Color', 'black', 'HorizontalAlignment', 'center');
                
           end
       end
   end
end
hold off
