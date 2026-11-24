function overlayEllipse(binaryImage, stats)
% binaryImage: logical / binary image
% stats: struct array (e.g. from regionprops)
% must contain:
%   Centroid, MajorAxisLength, MinorAxisLength, Orientation

figure; imshow(binaryImage); hold on;

for k = 1:length(stats)
    % Extract properties
    x0 = stats(k).Centroid(1);
    y0 = stats(k).Centroid(2);
    major = stats(k).MajorAxisLength / 2;
    minor = stats(k).MinorAxisLength / 2;
    
    % Orientation in MATLAB is in degrees
    theta = deg2rad(-stats(k).Orientation); 
    % NOTE: minus sign because MATLAB defines angle differently

    % Parametric ellipse
    t = linspace(0, 2*pi, 100);
    x = major * cos(t);
    y = minor * sin(t);

    % Rotation matrix
    R = [cos(theta) -sin(theta); 
         sin(theta)  cos(theta)];
     
    xy = R * [x; y];

    % Shift to centroid
    xEllipse = xy(1,:) + x0;
    yEllipse = xy(2,:) + y0;

    % Plot ellipse
    plot(xEllipse, yEllipse, 'r', 'LineWidth', 1.5);

    % Major axis
    xMajor = [x0 - major*cos(theta), x0 + major*cos(theta)];
    yMajor = [y0 - major*sin(theta), y0 + major*sin(theta)];
    plot(xMajor, yMajor, 'g', 'LineWidth', 1.5);

    % Minor axis (perpendicular)
    xMinor = [x0 - minor*sin(theta), x0 + minor*sin(theta)];
    yMinor = [y0 + minor*cos(theta), y0 - minor*cos(theta)];
    plot(xMinor, yMinor, 'b', 'LineWidth', 1.5);

    % Centroid
    plot(x0, y0, 'y.', 'MarkerSize', 15);
end

title('Ellipse and Axes Overlay');
hold off;
end