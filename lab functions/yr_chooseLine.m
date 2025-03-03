function [xVals,yVals,alpha] = yr_chooseLine(figure_num)
% choose line (open an image first on the specified figure)
% The function returns a vector of the x values of the line, the y values
% and the angle of the line

figure(figure_num);
set(gcf, 'Position',  [500,170,500,500]);shg;
title(sprintf('Draw a line: left click for choosing point, right click for finish,\n middle mouse button for deleting the previous point.'));


count=1;
[xVals,yVals,cc] = ginput(1);
hold on
plot_sp = plot(xVals(1),yVals(1),'b','linewidth',1);

while cc~=3
    if count<3
        count=count+1;
        [xVals(count),yVals(count),cc]=ginput(1);
        if cc==2
            xVals(count)=[];
            yVals(count)=[];
            count=count-1;
            if count >= 1
                xVals(count)=[];
                yVals(count)=[];
                count=count-1;
                set(plot_sp,'xdata',xVals,'ydata',yVals);
            end
        else
            set(plot_sp,'xdata',xVals,'ydata',yVals);
        end
    else
        error('Draw line and not polygon');
    end
end

if size(xVals,2)>2
    xVals(3:end)=[];
    yVals(3:end)=[];
end
alpha=atan((yVals(2)-yVals(1))./(xVals(2)-xVals(1)));
if (alpha<0)
    alpha=alpha+2.*pi;
end