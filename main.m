%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% tracking of colloids 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear all
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up paths

% path to tif-pics
tifPath = '';
%tifPath = '../data/03_10nm_1mw_1fps_40x';

% filename-pattern first (constant) part in frame name
fNamePattern = '20x*';


% get a piclist
piclist = dir(strcat(tifPath,filesep,fNamePattern));

% number of files
nPic = length(piclist);

% define a basis-folder where to save the results
resultsbasepath = fullfile(pwd,'results');

% give the file name of results
recording = 'Result_Rods_08.04.26_02_disp40_lost0_good5';

% path for plots and such
outpath = fullfile(resultsbasepath,recording);

% output folder for pictures
picturedir = 'pictures';

%output path for the pictures
picturepath = fullfile(resultsbasepath,recording,picturedir);

%create output directory if non-existent
if ~isfolder(picturepath)
    mkdir(picturepath)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameters for tracking and image analysis

% * Parameters for the tracking algorithm
trackingParams.maxdisp = 40;  % maximal displacement to be expected (in px)
trackingParams.mem = 0;       % store lost trajectory for x-time steps
trackingParams.dim = 2;       % position data until this column (number of dimensions to consider)
trackingParams.good = 5;      % eleminate very short trajectories up ... frames
trackingParams.quiet = 0;     % set to 1 for no tracking report

% maximal eccentricity 
eccn_max = 1;
% norm 0.5, 0 is perfect round shape; 1 is ellips

% maximum deviation in pics
maxtol = 10000;
% norm 100

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% analyze the pictures

% open a waitbar
f = waitbar(0,'Image analysis...');

% loop over time 
for iPic = 1:nPic

    % update the waitbar
    waitbar((iPic-1)/(nPic-1),f);

    % get the current file
    fName = piclist(iPic).name;
    
    % path to source file
    fPath = strcat(tifPath,filesep,fName);

    % get the connected component properties
    piclist(iPic).img_cc = f_image_analysis(fPath,maxtol);
            
end

% close the waitbar
close(f)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get properties of the analzed objects
% idea: detect cut-offs/outliers automatically 

% create vectors to store data
area_vec = [];
%eccn_vec = [];

% loop over all images
for iPic = 1:nPic

    area_vec = [area_vec;transpose([piclist(iPic).img_cc.Area])];
%    eccn_vec = [eccn_vec;transpose([piclist(iPic).img_cc.Eccentricity])];

end

% save mean and standard deviation of the areas
area_mean = median(area_vec);
area_stds = std(area_vec);

area_lb = area_mean - 3.*area_stds;
area_ub = area_mean + 3.*area_stds;

if area_lb < 0 
    area_lb = 0.;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make position list 

% allocate memory for a position list
pos = [];

% open a waitbar
f = waitbar(0,'Create position list...');

% loop over time steps
for iPic = 1:nPic
    
    % update the waitbar
    waitbar((iPic-1)/(nPic-1),f);

    % get the length
    nP = length(piclist(iPic).img_cc);

    % allocate memory for positions
    rX = zeros(nP,1);
    rY = zeros(nP,1);
    
    % also save other particle properties
    area = zeros(nP,1);
    eccn = zeros(nP,1);
    Maj_ax = zeros(nP,1);
    Min_ax = zeros(nP,1);
    Orint = zeros(nP,1);

    % read from the piclist
    for iP=1:nP

        rX(iP) = piclist(iPic).img_cc(iP).Centroid(1);
        rY(iP) = piclist(iPic).img_cc(iP).Centroid(2);

        area(iP) = piclist(iPic).img_cc(iP).Area;
        eccn(iP) = piclist(iPic).img_cc(iP).Eccentricity;
        Maj_ax(iP) = piclist(iPic).img_cc(iP).MajorAxisLength;
        Min_ax(iP) = piclist(iPic).img_cc(iP).MinorAxisLength;
        Orint(iP) = piclist(iPic).img_cc(iP).Orientation;

    end
        
    % filter and copy to position list, if the object is valid
    for iP=1:nP

        % filter based on the area
        if area(iP) < area_lb || area(iP) > area_ub
            continue
        else

            % filter for the eccentricity 
            if eccn(iP) > eccn_max
                continue
            else
                % valied particle found
                pos = [pos; rX(iP),rY(iP),...
                    area(iP),eccn(iP),Maj_ax(iP),Min_ax(iP),Orint(iP),...
                    iPic];
            end

        end
    end
        
end

% close the waitbar
close(f)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run the tracking -- connect objects in different frames

% tracking
tracklist = track(pos,trackingParams.maxdisp,trackingParams);

% convert tracklist to structure 
tracks = tracklist2struct(tracklist);

% save the number of tracks 
numtracks = length(tracks);

% clean up
clear pos tracklist area area_vec area_mean area_stds eccn rX rY fPath fName f

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% check the tracks 

% % check whether holes exist
% if 0 == trackingParams.quiet
%     f_check_holes(tracks)
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save data to results directory

% save the full dataset
save(fullfile(outpath,'tracks.mat'), 'tracks')
save(fullfile(outpath,'piclist.mat'), 'piclist')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% illustrate the results

% plot tracks
fig_ind = 1;
p_tracks(fig_ind,tracks)

% write tracking to file -- this takes time
write_tracking_pic
