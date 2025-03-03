function mark(command, arg)
%
% Just type "mark" and have fun...
%
%	No args: Initialization
% 	mark('init', figs) where figs is a vector of figure handles,
%
%	Internal use:
%	MARK(1, fig): called by cursor motion to update cursors
%	MARK(2): called by ButtonDown to add/delete marks
%	MARK(3): called by right button to delete all marks
%	MARK(4): reset (turn MARK off, leave marks on figures)
%	
%
%	Right button   : add mark
%	Middle button : delete last mark (can be used succesively)
%	Left button      : delete all marks
%
%   Dec 2017: Revised to work with newer (post 2014) Matlab versions. R.O.

global figures cursors marks positions
warning('off','MATLAB:hg:EraseModeIgnored')
% warning('off','MATLAB:hg:EraseModeIgnored')

if (nargin == 0),		% initialization
	command = 'init';
end;

if isstr(command),
	if strcmp(lower(command), 'init') | strcmp(lower(command), 'new'),
		command = 0;
	elseif strcmp(lower(command), 'button_motion'),
		command = 1;
	elseif strcmp(lower(command), 'button_down'),
		command = 2;
	elseif strcmp(lower(command), 'delete_all'),
		command = 3;
	elseif strcmp(lower(command), 'off'),
		command = 4;
	end;
end;

if (command == 0),	% initialization
	if nargin < 2,	% default is to use all figures
		figures = get(0, 'Children')';
	else,
		figures = arg(:)';
	end;

	set(figures, 'Interruptible', 'on');	% to make QUESTDLG work properly
	eval('delete(cursors);',';');
	marks = [];
	positions = [];
	cursors = [];
	for fig = figures,
        figure(fig);
        if ~isa(fig,'double')
            fig=fig.Number;
        end
		for ax = findobj(fig,'type','axes')',
			axes(ax);
			cursors = [cursors text(0,0,'+')];
		end;
		set(fig, 'WindowButtonMotionFcn', ['mark(''button_motion'',' int2str(fig) ')']);
		set(fig, 'WindowButtonDownFcn', 'mark(''button_down'')');
	end;

	set(cursors, 'Units', 'norm', ...
		'VerticalAlignment', 'middle',  ...
		'HorizontalAlignment', 'center', ...
		'EraseMode', 'xor'); 

elseif (command == 1),	% called by cursor motion
	ax = get(arg, 'CurrentAxes');
	axpos = get(ax, 'Position');
	curr_point = get(ax, 'CurrentPoint');
	xlim = get(ax, 'XLim');
	ylim = get(ax, 'YLim');
	if strcmp(get(ax, 'XDir'), 'reverse'), xlim = xlim([2 1]); end;
	if strcmp(get(ax, 'YDir'), 'reverse'), ylim = ylim([2 1]); end;
	curs_pos(1) = (curr_point(1,1) - xlim(1)) / (xlim(2) - xlim(1));
	curs_pos(2) = (curr_point(1,2) - ylim(1)) / (ylim(2) - ylim(1));
	set(cursors, 'Position', curs_pos);
elseif (command == 2),	% called by button down
	sel = get(gcf, 'SelectionType');
	if strcmp(sel, 'normal'),	% right button: add mark
		newmarks = [];
		for cursor = cursors,
			new = copyobj(cursor,get(cursor, 'Parent'));
% 			set(new, 'Parent', get(cursor, 'Parent'));
			newmarks = [newmarks; new];
		end;
		marks = [marks newmarks];
		positions = [positions get(cursor,'pos')'];
		set(newmarks, 'Units', 'norm', ...
			'VerticalAlignment', 'middle',  ...
			'HorizontalAlignment', 'center', ...
			'EraseMode', 'xor', ...
			'Position', get(cursors(1), 'Position'));
	elseif strcmp(sel, 'extend'),	% middle button: delete last mark
		n = size(marks, 2);
		if n,
			for m = marks(:, n)',
				eval('delete(m);', ';');
			end;
			marks(:, n) =[];
		end;
	elseif strcmp(sel, 'alt'),	% right button: delete all marks
% 		beep(2);
		ans = questdlg('Delete all marks?', 'Delete marks?', 'Delete', 'Don''t Delete', 'Delete');
        	if strcmp(ans, 'Delete'),
        		mark('delete_all');
		end;
	end;
elseif (command == 3),	% called by delete all
			for m = marks(:)',
				eval('delete(m);', ';');
			end;
			marks =[];
elseif (command == 4),	% reset
	eval('delete(cursors);',';');
	marks = [];
	positions = [];
	cursors = [];
	for fig = figures,
		set(fig, 'WindowButtonMotionFcn', '');
		set(fig, 'WindowButtonDownFcn', '');
	end;

else,
	error('mark.m was called with ileagal command');
end;
