function [S] = f_image_analysis(pic_path,maxtol)

    % ignore warnings
    w = warning ('off','all');

    % load an image
    t=Tiff(pic_path);
    img=read(t);

    % smooth the input
    img = imgaussfilt(img,0.5);
           
    % binarize by maxima
    img_ind = 255*(img>(max(max(img))-maxtol));
    
    % smooth again
    img_ind = imgaussfilt(img_ind,0.5);
    
    % binarize again
    img_ind = imbinarize(img_ind);
    
    % fill holes 
    BW = imfill(img_ind,'holes');
    
    % find connectec components and analyze them
    CC = bwconncomp(BW);
    S = regionprops(CC,'Centroid','Area','Eccentricity','MajorAxisLength','MinorAxisLength','Orientation');

    % switch warnings on again
    w = warning ('on','all');

end