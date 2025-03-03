function removevar(matfiles,varargin)
%% removevar removes variable(s) from selected Mat file(s)
%% removevar selects MAT file(s) matfiles and ask user to select which 
% variables to delete. If more than one MAT file, matfiles is of cell
% format. Otherwise, matfiles can be either of char or cell class.
%% removevar(matfiles) ask user to select which variables in matfiles to delete
%% removevar(matfiles,varargin) deletes variables that matches varargin in
% matfiles. For example,
% removevar
% removevar('temp.mat','abc','img')
% removevar({'temp1.mat','temp2.mat'},'abc','img')
%
% Verison 1.0 2/26/2013
% Chao-Wei Chen


switch(nargin)
    case 0,
        [matfiles,p]=uigetfile('*.mat','select MAT file(s)','multiselect','on');
        if p==0,return;end
        if ~iscell(matfiles), matfiles={fullfile(p,matfiles)};
        else matfiles=cellfun(@fullfile,repmat({p},size(matfiles)),matfiles,'uniformoutput',false);end
        
        select_var_to_delete(matfiles);
    case 1,
        if ischar(matfiles),matfiles={matfiles};end
        select_var_to_delete(matfiles);
    otherwise
        if ischar(matfiles),matfiles={matfiles};end
        select_var_to_delete(matfiles,varargin);
end


end



function select_var_to_delete(matfiles,var_to_delete)
% use the first file to collect vars to be deleted
if ~exist('var_to_delete','var')
    var_to_delete=select_var_routine(matfiles{1});
end
if isempty(var_to_delete) || numel(var_to_delete)==0,
    disp('removevar:No var to be deleted');return
else
    msgstring=generate_msgstring(var_to_delete);
end
fs=10e3;
t = 0:1/fs:0.5;
soundsc([chirp(t,110,1,2*110,'logarithmic'),chirp(t,110,1,1/2*110,'logarithmic')],fs);

choice = 'Ok'; %questdlg([{msgstring},matfiles],'Confirmation','Ok','Cancel','Ok');
switch choice
    case 'Ok'        
        for k=1:numel(matfiles)
            delete_routine(matfiles{k},var_to_delete);
        end 
    case 'Cancel'
        disp('removevar:action cancelled');
end

end

function msgstring=generate_msgstring(var_to_delete)
msgstring='About to delete {';
for k=1:numel(var_to_delete)
    msgstring=[msgstring var_to_delete{k} ', '];
end
msgstring=[msgstring(1:end-2) '} in '];
end
function delete_routine(matfile,var_to_delete)
if is_matfile_exist(matfile),
    varlist=who('-file',matfile);
    var_to_keep=setdiff(varlist,var_to_delete);
    load(matfile,var_to_keep{:});
    save(matfile,var_to_keep{:});  
else % matfile not existed
    disp(['removevar:' matfile ' not existed']);
end
end
function tf=is_matfile_exist(matfile)
assert(ischar(matfile),'matfile must be a string');
[~,~,ext]=fileparts(matfile);
if isempty(ext), matfile=[matfile '.mat'];end

tf=~isempty(which(matfile));
end
function [var_to_delete,var_to_keep]=select_var_routine(matfile)
varlist=who('-file',matfile);
var_to_keep=varlist;    
choice=menu('delete which var?(click cross to exit)',var_to_keep);
while(choice~=0)    
    var_to_keep=setdiff(var_to_keep,var_to_keep(choice));
    choice=menu('delete which var?(click cross to exit)',var_to_keep);
end
var_to_delete=setdiff(varlist,var_to_keep);
end