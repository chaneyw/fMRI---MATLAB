%this is the second step after posdiscrimanddecorr1.m which calculates
%correlations at each separation for subsets of voxels divided based on their
%unattend - attend correlation values .. this one doesn't calculate
%position discrimination it just calculates the correlations at each
%separation for a group analysis

visual_field = 1;  %this really means visual area.. not sure why I called it field.

dh = {{'Run %i - Attend UP_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',2,4,6,8},{'Run %i - Attend DOWN_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',3,5,7,9},{'DH_Run_%i_%s.prt'},'DH'};

gm = {{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL lo res.vtc',1,3,5,7},{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL lo res.vtc',2,4,6,8},{'GM_Run_%i_%s.prt'},'GM'};

nw = {{'Run %i - Attend UP_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',3,5,7,10},{'Run %i - Attend DOWN_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',4,6,9,11},{'NW_Run_%i_%s.prt'},'NW'};

sh = {{'Run %i - Attend UP_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',3,5,8,10},{'Run %i - Attend DOWN_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',4,6,9,11},{'SH_Run_%i_%s.prt'},'SH'};

th = {{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL_LO_RES.vtc',3,4,6},{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL_LO_RES.vtc',2,5,7,9},{}};  %broken

subj_list = {dh,gm,nw,sh}; %need to add TH once it is fixed
base_path = 'C:\Users\Wes\Desktop\Pulvinar Data\PulvLoop\';
voi_dir = 'C:\Users\Wes\Desktop\Pulvinar Data\Resid Files\';

keep1 = [];
keep2 = [];
lengths1 = [];
lengths2 =[];
%voi_list = voi_list(2,:);  %temporary test
for subj = [3,4] %1:numel(subj_list)
    if visual_field == 1
        voi_files = dir([voi_dir subj_list{subj}{4} '\*.voi']);
    elseif visual_field == 2
        voi_files = dir([voi_dir subj_list{subj}{4} '4\*.voi']);
    end
    file_path = strcat(base_path, subj_list{subj}{4}, '\');
    for vf = [1,2]
        runs = subj_list{subj}{vf};
        for attention = [0,1]
            vtc_files = {};
            for i = 2:length(runs)
                vtc_files{i-1} = strcat(file_path,sprintf(runs{1},runs{i}));
            end

            if vf == 1 && attention == 0
                field = 'Lower';
            elseif vf == 1 && attention == 1
                field = 'Upper';
            elseif vf == 2 && attention == 0
                field = 'Upper';
            elseif vf == 2 && attention == 1
                field = 'Lower';
            end

            prt_files = {};
            for i = 2:length(runs)
                prt_files{i-1} = strcat(file_path,sprintf(subj_list{subj}{3}{1},runs{i},field));
            end

            %for voi_num = 1:size(voi_files,2) %preload the VOIs
            %    eval(['VOI_' num2str(voi_num) ' = BVQXfile(voi_files{' num2str(voi_num) '});']);
            %end

            for run = 1:numel(vtc_files)

                vtc = BVQXfile(vtc_files{run});

                % SDM options
                opts = struct( ...
                    'rcond',  'baseline', ...
                    'nvol',    vtc.NrOfVolumes);

                % create SDM
                prt = BVQXfile(prt_files{run});
                sdm = prt.CreateSDM(opts);

                tdim.tmaps = true;
                [betas, irtc, ptc, se] = sdm.CalcBetas(vtc,tdim);
                betas = reshape(betas,[size(betas,1)*size(betas,2)*size(betas,3) 6]);
                vtcdim = size(vtc.VTCData);
                for voi_num = 1:numel(voi_files)
                    if visual_field == 1
                        voi = BVQXfile([voi_dir subj_list{subj}{4} '\' voi_files(voi_num).name]);
                        avgdifs = BVQXfile([voi_dir subj_list{subj}{4} '41\' voi_files(voi_num).name(1:end-4) '_avgdiff.mat']);
                        load([voi_dir subj_list{subj}{4} '2\' voi_files(voi_num).name(1:end-4) '_Run' num2str(run) '_VF' num2str(vf) 'combined_betas.mat']); %load the VOI
                    elseif visual_field == 2
                        voi = BVQXfile([voi_dir subj_list{subj}{4} '4\' voi_files(voi_num).name]);
                        avgdifs = BVQXfile([voi_dir subj_list{subj}{4} '4\' voi_files(voi_num).name(1:end-4) '_avgdiff.mat']); %load the VOI
                    end

                    avgdifs = avgdifs.Data;
                    cutoff = quantile(avgdifs,.5);
                    medsplit = avgdifs>=cutoff;
                    [voitc,uvec,uvecr] = vtc.VOITimeCourse(voi,Inf); %extract timecourse for VOI in upsampled space
                    coords=voi.VOI.Voxels(uvec{1},:); %get the TAL coords for the VOI
                    [x,y,z]=Tal2Matlab(coords(:,1),coords(:,2),coords(:,3)); %convert the TAL coords to original space
                    %roi_betas = betas(x,y,z,:); %use the TAL coords to get the VTC data for those voxels
                    indices = sub2ind(vtcdim(2:end),x,y,z);
                    voitc2 = vtc.VTCData(:,sub2ind(vtcdim(2:end),x,y,z)); %use the TAL coords to get the VTC data for those voxels

                    % the ones that had more reduced correlation with
                    % attention
                    temp1 = keepers(medsplit,1)';
                    keep1 = [keep1 temp1];
                    lengths1 = [lengths1 length(temp1)];
                    
                    %less reduced correlation with attention
                    temp2 = keepers(logical((medsplit-1)*-1),1)';
                    keep2 = [keep2 temp2];                
                    lengths2 = [lengths2 length(temp2)];
                    %savename = [voi_dir subj_list{subj}{4} '\' voi_files(voi_num).name(1:end-4) '_Run' num2str(run) '_VF' num2str(vf) '_Att' num2str(attention) '.mat'];
                    %save(savename,'voi_resids')
                    clear voi voitc uvec uvecr coords x y z voitc2 ptc2 voi_resids savename
                end %end all VOIs
                clear vtc prt sdm betas irtc ptc se
           end %end all runs
        end
     end
end