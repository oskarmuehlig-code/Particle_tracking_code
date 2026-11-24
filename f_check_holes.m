function [] = f_check_holes(tracks)

    for iT = 1:length(tracks)
        
        % read out the coordinates
        coord = tracks(iT).position;
        
        % get x and y
        rX = coord(:,1);
        rY = coord(:,2);
    
        % number of entries
        
        % check for NaN <-> hole in trajectory
        if sum(isnan(rX)) > 0 || sum(isnan(rY)) > 0
           
            fprintf('Trajectory %d contains holes (total length: %d). \n',iT,length(rY))
           
%             %%% check the hole-structure in more detail
%             % get the number of frames
%             nF = length(rX);
%             
%             for iF=1:(nF-1)
%                 if isnan(rX(iF)) && isnan(rX(iF+1))
%                     fprintf(' \t -> 2 consequetive frames with NaN \n'); 
%                 end
%             end
           
        end
            
    end

end