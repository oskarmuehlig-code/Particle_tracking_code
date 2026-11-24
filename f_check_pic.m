function f_check_pic(tifPath,piclist,figind,iPic)
    
    % get the current file
    fName = piclist(iPic).name;
    
    % path to source file
    fPath = strcat(tifPath,filesep,fName);

    % get the connected component properties
    img_cc = piclist(iPic).img_cc;
            
    % load an image
    t=Tiff(fPath);
    img=read(t);

    % open a figure
    figure(figind)
    imshow(img)

    hold on
    for iP=1:length(img_cc)
    
        rX = img_cc(iP).Centroid(1);
        rY = img_cc(iP).Centroid(2);

        plot(rX,rY,'rx')

    end
    hold off

end