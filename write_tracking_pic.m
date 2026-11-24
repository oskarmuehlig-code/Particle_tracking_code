%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot tracks on top of original images

% ignore warnings
w = warning ('off','all');

% open a waitbar
f = waitbar(0,'Writing pictures with tracks...');

% save a color for each track
cc=hsv(numtracks);

% randomize the order of colors
p = randperm(numtracks);
cc = cc(p,:);

% loop over images
for iPic=1:nPic

    % update the waitbar
     waitbar((iPic-1)/(nPic-1),f);

    % get the current file
    fName = piclist(iPic).name;
    
    % path to source file
    fPath = strcat(tifPath,filesep,fName);

    % load the image image
    t = Tiff(fPath);
    img = read(t);

    % show the image
    figure1 = imshow(img);

    % superpose tracks
    hold on
    for j=1:numtracks

        % select the color of the trajectory
        farbe=cc(j,:);
    
        % check: trajectory must exist 
        if tracks(j).time(1)<=iPic
    
            % how much of the track should be shown
            if tracks(j).time(end) <=iPic
    
                % plot the entire track
                plot(tracks(j).position(:,1), ...
                    tracks(j).position(:,2), ...
                    'color',farbe);

                % coordinates of final position
                xEnd = tracks(j).position(end,1);
                yEnd = tracks(j).position(end,2);

                % permanent label
                text(xEnd + 10, yEnd + 10, num2str(j), ...
                    'Color', farbe, ...
                    'FontSize', 8, ...
                    'FontWeight', 'bold', ...
                    'BackgroundColor', 'black', ...
                    'Margin', 1);
    
            else
    
                % show only a snippet of the track 
                % tMin = tracks(j).time(1);
                tMax = 1 + (iPic - tracks(j).time(1));
    
                % plot the trajectory
                plot (tracks(j).position(1:tMax,1),tracks(j).position(1:tMax,2),'color',farbe);                                           
                % ---- plot ellipse at current frame ----
                % check if this track exists at this frame
                idx = find(tracks(j).time == iPic);

                if ~isempty(idx)

                    x = tracks(j).position(idx,1);
                    y = tracks(j).position(idx,2);

                    % skip if NaN (missing point)
                    if ~isnan(x)

                        a = tracks(j).properties.Maj_ax(idx)/2; % semi-major
                        b = tracks(j).properties.Min_ax(idx)/2; % semi-minor
                        theta = tracks(j).properties.Orint(idx);

                        % MATLAB regionprops gives angle in degrees → convert
                        theta = -deg2rad(theta);

                        t = linspace(0,2*pi,50);

                        % ellipse before rotation
                        xe = a*cos(t);
                        ye = b*sin(t);

                        % rotation matrix
                        R = [cos(theta), -sin(theta); sin(theta), cos(theta)];

                        ellipse = R * [xe; ye];

                        % plot ellipse
                        plot(x + ellipse(1,:), y + ellipse(2,:), 'Color', farbe, 'LineWidth', 1)

                    end
                end    
            end
    
        end

    end
    hold off

    %write result to disk
    saveas(gcf,fullfile(picturepath, fName),'tif');

end

% close the open figure
close(1);

% close the waitbar
close(f)

% switch warnings on again
w = warning ('on','all');
