function batch_MFSK_feature_isogd()
MFSK_bin_path = './MFSK';
list_file_path = 'train_list.txt';
src_dir = '/data3/gesture/IsoGD_files/IsoGD';
dst_dir = '/data2/szhou/gesture/baseline/MFSK_features_ISO';
have_label = true;


if have_label
    scan_format = '%s %s %*s';
else
    scan_format = '%s %s';
end
[RGB_list, D_list] = textread(list_file_path, scan_format);

for i = 1:length(RGB_list)
    save_path = [dst_dir '/' RGB_list{i} '.mfsk'];
    mkdir_if_not_exist(fileparts(save_path));
    command = strjoin({MFSK_bin_path, [src_dir '/' RGB_list{i}], ...
        [src_dir '/' D_list{i}], save_path});
    [status, output] = system(command);
    if status ~= 0
        disp(output)
    end
    fprintf('%d/%d: %s\n', i, length(RGB_list), save_path)
end
end

function mkdir_if_not_exist(dirpath)
    if dirpath(end) ~= '/', dirpath = [dirpath '/']; end
    if (exist(dirpath, 'dir') == 0), mkdir(dirpath); end
end
