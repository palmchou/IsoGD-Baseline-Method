function iso_cal_center_and_get_hists
clear;clc;

train_list_path = 'list/train_list.txt';
valid_list_path = 'list/valid_list.txt';
MFSK_features_dir = '/data2/szhou/gesture/baseline/MFSK_features_ISO/';
K = 20; % select K videos from each class to calculate center.
code_size = 5000; 
cell_num = 2;
oribin_num = 8;
% save the center in case that we dont need to calculate it again.
center_dir = './center'; 
if ~exist(center_dir,'dir')
    mkdir(center_dir);
end

[RGB_list, ~, train_labels] = textread(train_list_path, '%s %s %s');
train_labels = str2double(train_labels);
[RGB_list_valid, ~] = textread(valid_list_path, '%s %s');


center_file = [center_dir '/' 'center.mat'];
file_exist = exist(center_file,'file');
if file_exist
    disp('Found center file, loding it.');
    load(center_file);
    disp('Center file loaded.');
else
    % check if we saved the selected features
    train_desc_file_path = [center_dir '/' 'train_desc.mat'];
    if exist(train_desc_file_path,'file')
        disp('Found features file, loading it.');
        load(train_desc_file_path);
        disp('Features file loaded.');
    else
        disp('Composing file list');

        file_list = [];
        for i = 1:249
            tmp_list = [];
            indexes = find(train_labels == i);
            for j = 1:length(indexes)
                feature_path = [RGB_list{indexes(j)} '.mfsk'];
                tmp_list{j} = feature_path;
            end
            file_list{i} = tmp_list;
        end

        disp('Read features:');
        max_rows = 750 * K * 249;
        train_desc = zeros(max_rows, 1024);

        start_row = 1;
        for i=1:249 %249
            files = file_list{i};
            num_files = length(files);
            if K > num_files
                k = num_files;
            else
                k = K;
            end
            selected_files_idx = randperm(num_files, k);
            for j=1:k
                file = files{selected_files_idx(j)};
                fprintf('Label: %d, path: %s\n', i, file)
                [~, ~, tmp_desc]=readmosift_hoghofmbh([MFSK_features_dir file], oribin_num,cell_num);
                [tmp_rows, ~] = size(tmp_desc);
                end_row = start_row + tmp_rows -1;
                train_desc(start_row:end_row, :) = tmp_desc;
                start_row = end_row + 1;
            end
            fprintf('%d rows\n', end_row);
        end
        train_desc(start_row:end, :) = []; % shrink 
        save(train_desc_file_path, 'train_desc');
        disp('train_desc saved'); 
    end

    % choose x rows from train_desc randomly
    x = 200000;
    [tmp_r, tmp_c] = size(train_desc);
    train_desc = train_desc(randperm(tmp_r, x), :);
    disp('Calculating center');
    run('../vlfeat-0.9.20/toolbox/vl_setup.m')
    [center, train_idx] =vl_kmeans(train_desc', code_size, 'distance', 'l1', 'algorithm', 'elkan');
    train_idx = train_idx';
    center=center';
    save(center_file, 'center', 'train_idx');
    disp('Center file saved');
end
disp('Creating train hist list in libsvm format');
get_hist(RGB_list, train_labels, 'list/iso/train.hist', center, code_size, ...
    MFSK_features_dir, oribin_num, cell_num);
disp('Creating validation hist list in libsvm format\n');
get_hist(RGB_list_valid, zeros(length(RGB_list_valid), 1), ...
    'list/iso/valid.hist', center, code_size, ...
    MFSK_features_dir, oribin_num, cell_num);



function get_hist(rgb_file_names, labels, save_path, center, code_size, ...
    MFSK_features_dir, oribin_num, cell_num)
fid = fopen(save_path, 'w');
for i = 1:length(rgb_file_names)
    path = [MFSK_features_dir rgb_file_names{i} '.mfsk'];
    [~, ~, tmp_desc]=readmosift_hoghofmbh(path,oribin_num,cell_num);
    hist = calhist_from_centers(tmp_desc, center,code_size);
    fprintf('%d/%d\n', i, length(rgb_file_names));
    label = labels(i);
    fprintf(fid,'%d', label);
    for sk=1:length(hist)
        number = hist(1,sk);
        fprintf(fid, ' %d:%g', sk, number);
    end
    fprintf(fid,'\n');
end


%% calcuate histogram
function hist = kmeans2d_hist(cluster_number,idx)
hist = zeros(1,cluster_number);
for i=1:length(idx)
    hist(idx(i)) = hist(idx(i)) +1;
end
hist = hist/norm(hist,2);


function hist = calhist_from_centers(descr, center,codebook_size)
distance = eucliddist(descr,center);
[c idx] = min(distance,[],2);
hist = kmeans2d_hist(codebook_size,idx);


