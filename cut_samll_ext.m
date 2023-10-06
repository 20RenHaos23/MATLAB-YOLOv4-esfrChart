clear;
clc;

%
% 對輸入影像使用內建的偵測方法偵測並得到座標，再將影像剪裁，
% 並檢查有哪些座標在剪裁的小影像中，將座標更新，並儲存成YOLOv4可以訓練的dataset資訊



% 假設 img 是你的 1920x1080 影像，並且 rectangles 是一個 Nx4 矩陣，
% 其中每一行是一個長方形框的 [x y w h]。

img = imread('eSFRTestImage.png');
[imgHeight, imgWidth, ~] = size(img);
%imshow(img);
try
    chart = sfr_hao_tr(img);

catch ME
    msg = sprintf('無法偵測');
    disp(msg);
    return;
end
%displayChart(chart,displayGrayROIs=true,displayEdgeROIs=true,...
%        displayColorROIs=true,displayRegistrationPoints=false);
   
% 預先分配長方形框的記憶體
edge_all = zeros(length(chart.SlantedEdgeROIs), 4);
gray_all = zeros(length(chart.GrayROIs), 4);
color_all = zeros(length(chart.ColorROIs), 4);

% 獲取所有的長方形框的座標
for j = 1:length(chart.SlantedEdgeROIs)
    edge_all(j, :) = chart.SlantedEdgeROIs(j).ROI;
end

for j = 1:length(chart.GrayROIs)
    gray_all(j, :) = chart.GrayROIs(j).ROI;
end

for j = 1:length(chart.ColorROIs)
    color_all(j, :) = chart.ColorROIs(j).ROI;
end

% 切割影像並檢查每個小影像中的長方形框
%imgHeight = 1080;
%imgWidth = 1920;
subImgHeight = 448;
subImgWidth = 640;
stepSize = 40; % 每XX個像素滑動一次
numRows = ceil((imgHeight - subImgHeight) / stepSize) ;
numCols = ceil((imgWidth - subImgWidth) / stepSize) ;
rectanglesSubImg = cell(numRows, numCols);

T = table();
T.imageFilename = cell(0);
T.color = cell(0);
T.edge = cell(0);
T.gray = cell(0);

currentFolder = pwd;

for i = 1:numRows
    for j = 1:numCols

        % 建立新的變數來儲存子影像中的框框
        color_sub = [];
        gray_sub = [];
        edge_sub = [];
        
        subImg = img((i-1)*stepSize+1:min((i-1)*stepSize+subImgHeight, imgHeight), ...
                     (j-1)*stepSize+1:min((j-1)*stepSize+subImgWidth, imgWidth),:);
        %imshow(subImg);
        % 對於每個小影像，確定哪些長方形框在該小影像內
        rectangles = {edge_all, gray_all, color_all};  % 包含所有種類的長方形框
        colors = {'red', 'green', 'blue'};  % 對應每種長方形框的顏色
        for type = 1:length(rectangles)
            for k = 1:size(rectangles{type}, 1)
                rect = rectangles{type}(k, :);
                % 如果長方形框的座標在小影像的範圍內，則計算新的座標
                if rect(1) >= (j-1)*stepSize && rect(1)+rect(3) <= (j-1)*stepSize+subImgWidth && ...
                   rect(2) >= (i-1)*stepSize && rect(2)+rect(4) <= (i-1)*stepSize+subImgHeight
                    newRect = [rect(1)-(j-1)*stepSize, rect(2)-(i-1)*stepSize, rect(3), rect(4)];
                    if ~any(newRect == 0)
                        rectanglesSubImg{i, j} = [rectanglesSubImg{i, j}; newRect];
                        subImg2 = insertShape(subImg, 'Rectangle', newRect, 'Color', colors{type}, 'LineWidth', 2);
    
                        % 將框框添加到相應的變數中
                        switch type
                            case 1
                                edge_sub = [edge_sub; newRect];
                            case 2
                                gray_sub = [gray_sub; newRect];
                            case 3
                                color_sub = [color_sub; newRect];
                        end
                    end
                end
            end
        end
        imshow(subImg);
        if ~isempty(edge_sub) || ~isempty(gray_sub) || ~isempty(color_sub)
            
            filename = sprintf('%s\\eSFRTestImage\\subImg_%d_%d.jpg', currentFolder, i, j);
            imwrite(im2uint8(subImg), filename);
            % rectanglesSubImg{i, j} 現在包含所有在小影像 (i, j) 內的長方形框，其座標已調整到小影像的座標系
            TNew = table({filename}, {color_sub}, {edge_sub}, {gray_sub}, 'VariableNames', {'imageFilename', 'color', 'edge', 'gray'});
            T = [T; TNew];
        end
    end
end
matFilename = fullfile(currentFolder, 'eSFRTestImage.mat');
save(matFilename, 'T');
