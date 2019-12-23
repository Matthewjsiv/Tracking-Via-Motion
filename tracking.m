cam = webcam;
% preview(cam);
previmg = 0;
previmg2 = 0;
previmg3 = 0;
previmg4 = 0;
frames = [];
v = VideoWriter('output','MPEG-4');

open(v)

detector = vision.ForegroundDetector('NumGaussians', 5, ...
            'AdaptLearningRate', 0, 'MinimumBackgroundRatio', 0.7);

blobFind = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
            'AreaOutputPort', true, 'CentroidOutputPort', true, ...
            'MinimumBlobArea', 180);
ccentroids = [];
for i = 1:400
    img = snapshot(cam);
    img = rgb2gray(img);
    ogimg = img;
    %downsize
    img = imresize(img, 1/8, 'bilinear');

   
%processing
%%%%%%%  
    %imgage = (img-previmg) + (img - previmg2) + (img - previmg3) + (img - previmg4);
    imgage = abs(img-previmg) + abs(img - previmg2); %+ abs(img - previmg3) + abs(img - previmg4);
    
    imgage(imgage<20) = 0; %helps with noise
    
    %fill in gaps (motion doesn't show as well in the middle of an object
    %of relatively constant color)
    imgage = imopen(imgage, strel('rectangle', [1,1]));
    imgage = imclose(imgage, strel('rectangle', [10, 10]));
    imgage = imfill(imgage, 8,'holes');
    
    %convert to binary image
    imgage = imbinarize(imgage,.16);
    %imgage = imfill(imgage, 'holes');
    %imshow(imgage);
    
    %find bounding boxes of objects
    [areas, centroids, bboxes] = blobFind(imgage);
    bboxes = bboxes.*8;
    %centroids = centroids.*8;
    %imgage = img;
    box on;
        imgage = insertObjectAnnotation(ogimg, 'rectangle', ...
                    bboxes,'', 'LineWidth', 1, 'Color', 'yellow');
    %ccentroids = vertcat(ccentroids, centroids);
    %imgage = insertMarker(ogimg, ccentroids);
    
    
    imshow(imgage);
    hold on;
    writeVideo(v,imgage);
%%%%%%    

    
    previmg4 = previmg3;
    previmg3 = previmg2;
    previmg2 = previmg;
    previmg = img;
end

close(v);
close all;
clear;