function bindata=plotspconds(condstoplot,xs,ys,nsubplots)
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
bindata(:,:,1)=plotsp(condstoplot(:,:,1),pixperplot,pixperplot,xs,ys);



for cond=2:nconds
  bindata(:,:,cond)=plotsp(condstoplot(:,:,cond),pixperplot,pixperplot,xs,ys,1);
end
