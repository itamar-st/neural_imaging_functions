function lowest_level = getcell(Ce)

lowest_level = Ce;

if ~iscell(lowest_level) 
    return
end

while iscell(lowest_level)
    if size(lowest_level) ~= [1 1]
        disp('Warning: input cell is not 1x1 size, this may cause data loss, because the function returns only first dimension')
    end
    lowest_level = lowest_level{1};

end