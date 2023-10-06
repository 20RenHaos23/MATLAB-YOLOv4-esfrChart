clear;
clc;

%
% 對指定資料夾內的所有影像使用內建的偵測方法偵測並得到座標，
% 並儲存成YOLOv4可以訓練的dataset資訊

%{
dataset_mat = load('./mydata/myData.mat');
vehicleDataset = dataset_mat.vehicleDataset;


T = table();
T.imageFilename = cell(0);
T.color = cell(0);
T.edge = cell(0);
T.gray = cell(0);
for i = 1:4
    color = vehicleDataset.color{i,1};
    gray = vehicleDataset.gray{i,1};
    edge = vehicleDataset.edge{i,1};
    imageFilename = vehicleDataset.imageFilename{i};

    TNew = table({imageFilename}, {color}, {edge}, {gray}, 'VariableNames', {'imageFilename', 'color', 'edge', 'gray'});
    T = [T; TNew]; 
end
%}

folder = '.\sta_size\';
fileListJPG = dir(fullfile(folder, '*.jpg'));
fileListPNG = dir(fullfile(folder, '*.png'));
fileList = [fileListJPG; fileListPNG];
numFiles = numel(fileList);

T = table();
T.imageFilename = cell(0);
T.color = cell(0);
T.edge = cell(0);
T.gray = cell(0);

for i = 1:numFiles
    
    randomFile = fileList(i).name;
    disp(randomFile);
  
    ImagePath = fullfile(folder, randomFile);
    I = imread(ImagePath);

    try
        chart = sfr_hao_tr(I);

    catch ME
        msg = sprintf('無法偵測%s', randomFile);
        disp(msg);
        continue;
    end
    
    %displayChart(chart,displayGrayROIs=true,displayEdgeROIs=true,...
    %    displayColorROIs=true,displayRegistrationPoints=false);

    
    % 預分配一個36x4的陣列
    edge_all = zeros(length([5:16, 25:36, 45:56]), 4);
    
    k = 1;
    % 使用for迴圈遍歷每個chart.SlantedEdgeROIs(i).ROI
    for j = [5:16, 25:36, 45:56]
        edge_all(k, :) = chart.SlantedEdgeROIs(j).ROI;
        k = k + 1;
    end
    

    % 預分配一個20x4的陣列
    gray_all = zeros(length(chart.GrayROIs), 4);
    
    % 使用for迴圈遍歷每個chart.SlantedEdgeROIs(i).ROI
    for j = 1:length(chart.GrayROIs)
        gray_all(j, :) = chart.GrayROIs(j).ROI;
    end


    % 標準版沒有
    color_all = [];

    TNew = table({ImagePath}, {color_all}, {edge_all}, {gray_all}, 'VariableNames', {'imageFilename', 'color', 'edge', 'gray'});
    T = [T; TNew]; 
    
    
end

currentFolder = pwd;
matFilename = fullfile(currentFolder, 'sta_size.mat');
save(matFilename, 'T');






