function SafeCreateDir(target)
    if (~exist(target, 'dir'))
        mkdir(target);
    end
end

