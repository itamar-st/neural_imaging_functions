function roi = choose_polygon(pixels)
% choose polygon (open an image first on figure 100)
% The function returns a vector of all the pixels indices in a chosen polygon

figure(100);
set(gcf, 'Position',  [500,170,500,500]);shg;
title(sprintf('ROI: left click for choosing point, right click for finish,\n middle mouse button for deleting the previous point.'));


count=1;
[Xsp,Ysp,cc] = ginput(1);
hold on
plot_sp = plot(Xsp(1),Ysp(1),'b','linewidth',1);

while cc~=3
    count=count+1;
      [Xsp(count),Ysp(count),cc]=ginput(1);
    if cc==2
        Xsp(count)=[];
        Ysp(count)=[];
        count=count-1;
        if count >= 1
            Xsp(count)=[];
            Ysp(count)=[];
            count=count-1;
            set(plot_sp,'xdata',Xsp,'ydata',Ysp);
        end
    else
        set(plot_sp,'xdata',Xsp,'ydata',Ysp);
    end
end

Xind = ones(pixels,1)*(1:pixels);
Yind = (1:pixels)'*ones(1,pixels);
in_pol = inpolygon(Xind,Yind,Xsp,Ysp);
in_pol = in_pol';
vec = double(in_pol);
vec = reshape(vec,pixels^2,1);
roi = find(vec==1);

%% Check
 mat = zeros(100);
 mat(roi) = 1;
 mat = reshape(mat,10000,1);
 figure;mimg(mat,100,100);

