% This demo shows how to use the software described in our ICCV paper: 
%   Segmentation as Selective Search for Object Recognition,
%   K.E.A. van de Sande, J.R.R. Uijlings, T. Gevers, A.W.M. Smeulders, ICCV 2011
%%

% Compile anisotropic gaussian filter
if(~exist('anigauss'))
    mex anigaussm/anigauss_mex.c anigaussm/anigauss.c -output anigauss
end


% Compile the code of Felzenszwalb and Huttenlocher, IJCV 2004.
if(~exist('mexFelzenSegmentIndex'))
    mex FelzenSegment/mexFelzenSegmentIndex.cpp -output mexFelzenSegmentIndex;
end

%%
% Parameters. Note that this controls the number of hierarchical
% segmentations which are combined.
colorTypes = {'Rgb', 'Hsv', 'RGI', 'Opp'};

% Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
% Note that by default, we set minSize = k, and sigma = 0.8.
kThresholds = [100 200]; 
sigma = 0.8;
numHierarchy = length(colorTypes) * length(kThresholds);

%% As an example, use a single Pascal VOC image

for num = 1:5
    images{num} = num2str(num,'%06d');
end
TIMELY_ROOT = '..';
IMG = 'VideoFrame';

%%%
%%% Alternatively, do it on the whole set. (Un)comment line 67/68
%%%

% For each image do Selective Search
fprintf('Performing selective search: ');
tic;
% boxes = cell(1, length(images));
for i=4:length(images)
    boxes = [];
    if mod(i,100) == 0
        fprintf('%d ', i);
    end
    idx = 1;
    currBox = cell(1, numHierarchy);
    im_path = fullfile(TIMELY_ROOT,strcat(IMG,'_Images'),strcat(images{i},'.jpg'));
    im = imread(im_path);
    %im = imresize(im,1/4);
    %im = imread(sprintf(VOCopts.imgpath, images{i})); % For Pascal Data
    for k = kThresholds
        minSize = k; % We use minSize = k.
        
        for colorTypeI = 1:length(colorTypes)
            colorType = colorTypes{colorTypeI};
            
            currBox{idx} = SelectiveSearch(im, sigma, k, minSize, colorType);
            idx = idx + 1;
        end
    end
    
    boxes = cat(1, currBox{:});
    boxes = unique(boxes, 'rows');
    boxes = boxes(:,[2,1,4,3])-1;
%     boxes{i} = cat(1, currBox{:}); % Concatenate results of all hierarchies
%     boxes{i} = unique(boxes{i}, 'rows'); % Remove duplicate boxes
%     boxes{i} = boxes{i}(:,[2,1,4,3])-1;
    save_path = fullfile(TIMELY_ROOT,strcat(IMG,'_Proposal'),strcat(images{i},'_boxes.mat'));
    save(save_path,'boxes');
end
fprintf('Elapsed time: %f seconds\n', toc);

