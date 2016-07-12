function train_hist
clear;clc;
% all_list_train = load('continous/train.mat');
% all_list_test = load('continous/test.mat');
% all_list_valid = load('continous/valid.mat');
% all_train = ['continuous_hists/train_hist.txt'];
% all_test = ['continuous_hists/test_hist.txt'];
% all_valid = ['continuous_hists/valid_hist.txt'];
% fid_train = fopen(all_train,'w');
% fid_test = fopen(all_test,'w');
% fid_valid = fopen(all_valid,'w');

MFSK_dir = '/data/gesture/continous_dataset_mfs/mfsk';
this_dir=pwd;
my_root     = this_dir(1:end-12);   % Change that to the directory of your project
% resu_dir    = [my_root '\tmpResults']; % Where the results will end up.  
center_dir =  [my_root '/continuous_center'];% save  clustering centers by kmeans
% vlfeat_path_setup = [my_root '\vlfeat\toolbox\vl_setup.m'];
center_dir_ = [center_dir '/MFSK'];
if ~exist(center_dir_,'dir')
    mkdir(center_dir_);
end

train_desc_file_path = [center_dir '/' 'train_desc.mat'];
if exist(train_desc_file_path,'file')
    load(train_desc_file_path);
else
    max_rows = 2500 * 5 * 3;
    train_desc = zeros(max_rows, 1024);
    disp('Read features:\n');
    
    start_row = 1;
    list_file = fopen('continuous/train_list.txt');
    count = 0;
    while 1
        line = fgetl(list_file);
        if ~ischar(line)
            break;
        else
            count = count + 1;
            cell_num = 2;
            oribin_num = 8;
            line = ['/home/junwan/', line(7:end)];
            [~, ~, tmp_desc]=readmosift_hoghofmbh(line,oribin_num,cell_num);
            [tmp_rows, tmp_cols] = size(tmp_desc);
            end_row = start_row + tmp_rows -1;
            train_desc(start_row:end_row, :) = tmp_desc;
            start_row = end_row + 1;
            fprintf('count: %d, %d rows\n', count, end_row);
        end
    end
    train_desc(start_row:end, :) = []; % shrink 
    save(train_desc_file_path, 'train_desc');
    disp('train_desc saved\n'); 
end

% choose x rows from train_desc randomly
x = 200000;
[tmp_r, tmp_c] = size(train_desc);
train_desc = train_desc(randperm(tmp_r, x), :);

%     train_len = size(train_desc,1);
%% code_size
code_size = 5000;% floor(codebook_size*train_len);
disp('kmeans');
name = [center_dir '/' 'center_2.mat'];
file_exist = exist(name,'file');
if file_exist
    load(name);
else
    [center, train_idx] =vl_kmeans(train_desc', code_size, 'distance', 'l1', 'algorithm', 'elkan');
    train_idx = train_idx';
    center=center';
    save(name, 'center', 'train_idx');
end
    % coding_type = 'VQ'
% get_hist(all_list_train.files,center,fid_train, code_size);
% get_hist(all_list_test.files,center,fid_test, code_size);
% get_hist(all_list_valid.files,center,fid_valid, code_size);
 
% train_list = [num_list hist_list];
% save('D:\ʵϰ\train\isolate_train_hist.txt','train_list');
fclose(fid_train);
fclose(fid_test);
fclose(fid_valid);

%sc_codes:m*n; m:dictionary size; n: feature length
%hist: 1*n

function get_hist(files,center,fid, code_size)
MFSK_dir = '/data/gesture/gesture_MFSK_new';
for i = 1:249
    num = files{i,2};
    set_name = num2str(i);
    file = files{i,3};
    for j=1:num
        cur_file = file{1,j};
        cur_file = find_file_name(cur_file,i);
        mosiftname = [MFSK_dir '/' set_name '/' cur_file '.csv'];
        cell_num = 2;
        oribin_num = 8;
        [~, ~, tmp_desc]=readmosift_hoghofmbh(mosiftname,oribin_num,cell_num);
        hist = calhist_from_centers(tmp_desc, center,code_size);
%         All_hist(count,:) = hist;
%         count = count + 1;
        fprintf('i=%d j=%d\n', i, j);
        fprintf(fid,'%d', i);
        for sk=1:length(hist)
            number = hist(1,sk);
            fprintf(fid, ' %d:%g', sk, number);
        end
        fprintf(fid,'\n');
    end
end

function cur_file = find_file_name(cur_file,i)
if i < 10
    del_nem = 3;
elseif i<100
    del_nem = 4;
else
    del_nem = 5;
end
cur_file = cur_file(del_nem:end);

function hist = hist_SC(sc_codes)
hist = full( mean(sc_codes,2)) ;
hist = hist';
hist = hist/norm(hist,2);

%%
function [train_desc, train_desc_num]=extract_all_train_descriptor...
    (descr_dir,train_num,feature_type)
train_desc = [];
train_desc_num = zeros(train_num,1);
for i=1:train_num
    mosiftname = [descr_dir '/K_' num2str(i) '.csv'];
    if strcmp(feature_type,'MFSK')
        cell_num = 2;
        oribin_num = 8;
        [~, ~, tmp_desc]=readmosift_hoghofmbh(mosiftname,oribin_num,cell_num);
    else
        [~,~,tmp_desc]=readmosift(mosiftname,feature_type);
    end
    train_desc = [train_desc ; tmp_desc];
    train_desc_num(i) = size(tmp_desc,1);
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


