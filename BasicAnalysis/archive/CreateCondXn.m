
function CreateCondXn(numOfConds)

load condsXn 

flag=[];
save condXn flag
for i=numOfConds
    condName=['condsXn' int2str(i)];
    eval(['mat=',condName,';']);
    newMat= nanmean(mat,3);
    condName=['condXn' int2str(i)];
    eval([condName,'=newMat;']);
    eval(['save condXn ',condName,' ''-append''']);
end

removevar('condXn.mat','flag') ;

end