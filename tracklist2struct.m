function tracks = tracklist2struct(tracklist)
% TRACKLIST2STRUCT convert tracklist array to structure and
%   calculate some motility statistics
%   
%   Usage
%   tracks = TRACKLIST2STRUCT(tracklist)
%
%   Output
%   tracks = structure array with fields
%       position: 2-colum array, x- and y- positions (cartesian coords)
%           missing points are NaN
%       time: 1-column array, timepoints (framenumbers) measured from start of sequence
%       index: scalar, track index as returned from Crocker and Grier's
%          tracking algorithm
%   
%   See also: track, calculate_motility


% tracklistTable = { 'position',[1,2];...
%     'velocity',[];...
%     'pathlength',[];...
%     'time', 7;...
%     'index', 6 };

tracks = struct('position',{},'properties',{},'time',{},'length',{},'index',{});
propNames = {'area','eccn','Maj_ax','Min_ax','Orint'};  

VERBOSE = false;

ncols = size(tracklist,2);
dim = 2; % x,y
time_col = ncols - 1;
id_col = ncols;
prop_cols = (dim+1):(ncols-2); % everything between position and time

%% Gather data from table and calculate velocity and pathlength
numtracks = tracklist(end,end);

% fprintf('Writing motility statistics to structure... \n');
for i = 1:numtracks
    tracks(i).index = i;

    % find rows for track i
    ind = find( tracklist(:,end) == i );

    % check for missing time points and replace corresponding positions with NaN
    t_list = tracklist(ind,time_col);
    t = (tracklist(ind(1),time_col):tracklist(ind(end),time_col))';
    %find elements in t_list that are also in t
    Lit = ismember(t, t_list);
    %copy tracking data

    % positions
    tracks(i).position(Lit,:) = tracklist(ind,1:dim);
    tracks(i).position(~Lit,:) = NaN;

    % initialize properties struct
    for p = 1:length(propNames)
        tracks(i).properties.(propNames{p}) = NaN(length(t),1);
    end

    % fill properties
    for p = 1:length(propNames)
        col = prop_cols(p);
        tracks(i).properties.(propNames{p})(Lit) = tracklist(ind,col);
    end

    % time
    tracks(i).time = t;

    % consitency check 
    if length(propNames) ~= length(prop_cols)
        error('Number of property names does not match number of property columns');
    end
end

% fill in the length
for i = 1:numtracks

    tracks(i).length = length(tracks(i).position(:,1));
    
end
    
%echo progress in verbose mode
if VERBOSE
    if ~rem(i,100); fprintf('%u,',i); end; %print every 100 tracks
    if ~rem(i,1000); fprintf('\n'); end; %nl every 1000 tracks
end
end
