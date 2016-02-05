%new analysis script - calculate the average correlation of each voxel with
%all other voxels in the ROI, calculate the difference between the attend
%and ignore runs, and then save one file per ROI with the result.


%made a couple of changes here on 10/7/15
%removed abs() added fisher()
visual_area = 1;

if visual_area == 1
    subjects = {'DH41','GM41','NW41','SH41'}; %V1
elseif visual_area == 2
    subjects = {'DH4','GM4','NW4','SH4'}; %V2
end

base_path = 'C:\Users\Wes\Desktop\Pulvinar Data\Resid Files\';
roi_vfs = {'UVF','LVF'};
hemis = {'LH','RH'};
final_corrs_att = {};
for subj = 1:length(subjects)
    for hemi = 1:length(hemis)
        for roi_vf = 1:length(roi_vfs)
            avgs = {[] []};
            for vf = [1,2]
                file_list = dir([base_path subjects{subj} '\*' hemis{hemi} '*' roi_vfs{roi_vf} '*VF' num2str(vf) '*combined.mat']);              
                for file_num = 1:length(file_list)
                    load([base_path subjects{subj} '\' file_list(file_num).name]);
                    pwcorrs = corr(voi_resids);
                    pwcorrs(1:length(pwcorrs)+1:numel(pwcorrs)) = NaN;
                    avgs{vf} = [avgs{vf};nanmean(pwcorrs)];
                end
            end
            if strcmp(roi_vfs{roi_vf},'UVF')
                out = mean(fisher(avgs{2})) - mean(fisher(avgs{1})); %unatt - att
            else 
                out = mean(fisher(avgs{1})) - mean(fisher(avgs{2})); %unatt - att   bigger effect of attention when more positive
            end
            savename = [base_path subjects{subj} '\' file_list(1).name(1:22) '_avgdiff.mat'];
            save(savename,'out')
        end
    end
end

