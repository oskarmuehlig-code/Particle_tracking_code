function [] = p_tracks(figInd,tracks)

    % open a figure
    figure(figInd)
    
    title('trajectories')
    hold on
    for iP=1:length(tracks)
       plot(tracks(iP).position(:,1),tracks(iP).position(:,2),'-') 
    end
    
    axis([0 2048 0 2048])
    pbaspect([1 1 1])
    hold off
    xlabel('x')
    ylabel('y')

end