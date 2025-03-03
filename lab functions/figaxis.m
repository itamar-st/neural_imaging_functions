function figaxis(arg1, newfig)
%FIGAXIS  Copy an axis into a new figure
%	
%    HS, 01 May 2005
%

if nargin==0,
 	set(gcf, 'WindowButtonDownFcn', 'figaxis(-1, -1)', 'Pointer', 'fleur');
elseif (strcmp(arg1, 'on')),
	if nargin < 2, newfig = -1; end;
 	set(gcf, 'WindowButtonDownFcn', ['figaxis(-2,' int2str(newfig) ')'],...
		'Pointer', 'fleur');
elseif (strcmp(arg1, 'off')),
 	set(gcf, 'WindowButtonDownFcn','', 'Pointer', 'arrow');
elseif (arg1 > 0),
        set(gcf, 'WindowButtonDownFcn', ['figaxis(-1,' int2str(arg1) ')'],...
		'Pointer', 'fleur');
elseif (arg1 == -1) | (arg1 == -2),
	figh = gcf;
	ax = gco;
	ty = get(ax, 'type');
	while ( ~strcmp(ty, 'axes') & ~strcmp(ty, 'figure') ),
		ax = get(ax, 'Parent');
		ty = get(ax, 'Type');
	end;
	if strcmp(ty, 'figure'), return, end;

	set(ax, 'Visible', 'on'); drawnow;
	if newfig < 1,
	  newfig=figure;
	else
	  newfig = figure(newfig);
	end;
	ver = version;
	if ver(1) < '5',
	  clone = copyobj(ax);
	  set(clone, 'Parent', newfig);
	else
	  clone = copyobj(ax, newfig);
	end	
	set(clone, 'pos', [.1 .1 .8 .8])
	set(ax, 'Visible', 'off');
	if (arg1 == -1),
	 	set(figh, 'WindowButtonDownFcn', '', 'Pointer', 'arrow');
	end;
	figure(figh);

else,
	help figaxis;
end

