function bindata=tm_plotspconds(condstoplot,xs,ys,nsubplots,points)
%function plotsp6(condstoplot,xs,ys,nsubplots)
% plots the traces for all the conditions

[npix,nframes,nconds]=size(condstoplot);

if nargin < 4
  nsubplots=4;
end

if nargin < 2
  xs=sqrt(npix);
  ys=sqrt(npix);
end


pixperplot=floor(xs./nsubplots);

% plotsp is broken
bindata(:,:,1)=tm_plotsp(condstoplot(:,:,1),pixperplot,pixperplot,xs,ys,0,points);



for cond=2:nconds
  bindata(:,:,cond)=tm_plotsp(condstoplot(:,:,cond),pixperplot,pixperplot,xs,ys,1,points);
end
