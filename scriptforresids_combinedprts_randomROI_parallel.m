
%vtc_files = uipickfiles('FilterSpec','C:\Users\Anna\Desktop\Pulvinar Data\Pulvinar Attention Reduced Files\*.vtc','Prompt','Select VTCs:','NumFiles',[],'Output','cell');
%prt_files = uipickfiles('FilterSpec','C:\Users\Anna\Desktop\Pulvinar Data\Pulvinar Attention Reduced Files\*.prt','Prompt','Select VTCs:','NumFiles',size(vtc_files,2),'Output','cell');
%voi_files = uipickfiles('FilterSpec','C:\Users\Anna\Desktop\Pulvinar Data\Pulvinar Attention Reduced Files\*.voi','Prompt','Select VOIs:','NumFiles',[]);

dh = {{'Run %i - Attend UP_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',2,4,6,8},{'Run %i - Attend DOWN_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',3,5,7,9},{'DH_Run_%i_%s.prt'},'DH'};

gm = {{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL lo res.vtc',1,3,5,7},{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL lo res.vtc',2,4,6,8},{'GM_Run_%i_%s.prt'},'GM'};

nw = {{'Run %i - Attend UP_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',3,5,7,10},{'Run %i - Attend DOWN_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',4,6,9,11},{'NW_Run_%i_%s.prt'},'NW'};

sh = {{'Run %i - Attend UP_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',3,5,8,10},{'Run %i - Attend DOWN_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',4,6,9,11},{'SH_Run_%i_%s.prt'},'SH'};

th = {{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL_LO_RES.vtc',3,4,6},{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL_LO_RES.vtc',2,5,7,9},{}};  %broken

subj_list = {dh,gm,nw,sh}; %need to add TH once it is fixed
base_path = 'C:\Users\Anna\Desktop\Pulvinar Data\PulvLoop\';
voi_dir = 'C:\Users\Anna\Desktop\Pulvinar Data\Resid Files\';
name_list = {'LH LVF','LH UVF', 'RH LVF', 'RH UVF'};

output = zeros(1,250);
reset(RandStream.getDefaultStream);
for iter = 1 %:150
dh = {{'Run %i - Attend UP_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',2,4,6,8},{'Run %i - Attend DOWN_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',3,5,7,9},{'DH_Run_%i_%s.prt'},'DH'};

gm = {{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL lo res.vtc',1,3,5,7},{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL lo res.vtc',2,4,6,8},{'GM_Run_%i_%s.prt'},'GM'};

nw = {{'Run %i - Attend UP_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',3,5,7,10},{'Run %i - Attend DOWN_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',4,6,9,11},{'NW_Run_%i_%s.prt'},'NW'};

sh = {{'Run %i - Attend UP_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',3,5,8,10},{'Run %i - Attend DOWN_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',4,6,9,11},{'SH_Run_%i_%s.prt'},'SH'};

th = {{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL_LO_RES.vtc',3,4,6},{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL_LO_RES.vtc',2,5,7,9},{}};  %broken

subj_list = {dh,gm,nw,sh}; %need to add TH once it is fixed
base_path = 'C:\Users\Anna\Desktop\Pulvinar Data\PulvLoop\';
voi_dir = 'C:\Users\Anna\Desktop\Pulvinar Data\Resid Files\';
name_list = {'LH LVF','LH UVF', 'RH LVF', 'RH UVF'};
%voi_list = voi_list(2,:);  %temporary test
for subj = 1 %:numel(subj_list)
    %voi_files = dir([voi_dir subj_list{subj}{4} '\*.voi']);
    file_path = strcat(base_path, subj_list{subj}{4}, '\');
    
    %create fake VOIs
    fake_vois = {};
    for i = 1:4
        temp_filename = [voi_dir subj_list{subj}{4} ' cortex mask.msk'];
        fake_vois{i} = pick_sphere(temp_filename);
    end
    
    temp = {fake_vois{3} fake_vois{4} fake_vois{1} fake_vois{2}};
    fake_vois = temp;
    
    for vf = 1%[1,2]
        runs = subj_list{subj}{vf};
        vtc_files = {};
        for i = 2:length(runs)
            vtc_files{i-1} = strcat(file_path,sprintf(runs{1},runs{i}));
        end

        prt_files = {};
        for i = 2:length(runs)
            prt_files = [prt_files strcat(file_path,sprintf(subj_list{subj}{3}{1},runs{i},'Upper'))];
            prt_files = [prt_files strcat(file_path,sprintf(subj_list{subj}{3}{1},runs{i},'Lower'))];
        end

        %for voi_num = 1:size(voi_files,2) %preload the VOIs
        %    eval(['VOI_' num2str(voi_num) ' = BVQXfile(voi_files{' num2str(voi_num) '});']);
        %end

        for run = 1 %:numel(vtc_files)

            vtc = BVQXfile(vtc_files{run});

            % SDM options
            opts = struct( ...
                'rcond',  'baseline', ...
                'nvol',    vtc.NrOfVolumes);

            % create SDM
            prt1 = BVQXfile(prt_files{run*2-1});
            sdm1 = prt1.CreateSDM(opts);

            prt2 = BVQXfile(prt_files{run*2});
            sdm2 = prt2.CreateSDM(opts);

            sdm1_data_matrix = sdm1.SDMMatrix;
            sdm2_data_matrix = sdm2.SDMMatrix;

            all_data_matrix = [sdm1_data_matrix(:,1:end-1) sdm2_data_matrix(:,1:end-1) sdm1_data_matrix(:,end)];

            sdm1_predictor_names = sdm1.PredictorNames;
            sdm2_predictor_names = sdm2.PredictorNames;

            all_predictor_names = [strcat(sdm1_predictor_names(1:end-1),'_upper') strcat(sdm2_predictor_names(1:end-1),'_lower') 'constant'];

            design_colors = sdm1.PredictorColors;
            design_colors = [design_colors(1:end-1,:);randi(256,[5 3])-1;[0 0 0]];

            sdm1.NrOfPredictors = size(all_data_matrix,2);
            sdm1.IncludesConstant = 1;
            sdm1.SDMMatrix = all_data_matrix;
            sdm1.PredictorNames = all_predictor_names; 
            sdm1.PredictorColors = design_colors;

            [betas, irtc, ptc, se] = sdm1.CalcBetas(vtc);
            vtcdim = size(vtc.VTCData);

            for voi_num = 1:numel(name_list)
                x = fake_vois{voi_num}(:,1);
                y = fake_vois{voi_num}(:,2);
                z = fake_vois{voi_num}(:,3);
                %keyboard

                %voi = BVQXfile([voi_dir subj_list{subj}{4} '\' voi_files(voi_num).name]); %load the VOI
                %[voitc,uvec,uvecr] = vtc.VOITimeCourse(voi,Inf); %extract timecourse for VOI in upsampled space
                %coords=voi.VOI.Voxels(uvec{1},:); %get the TAL coords for the VOI
                %[x,y,z]=Tal2Matlab(coords(:,1),coords(:,2),coords(:,3)); %convert the TAL coords to original space
                voitc2 = vtc.VTCData(:,sub2ind(vtcdim(2:end),x,y,z)); %use the TAL coords to get the VTC data for those voxels
                ptc2 = ptc(:,sub2ind(vtcdim(2:end),x,y,z));  %use the TAL coords to get the predicted timecourse for those voxels
                voi_resids = double(voitc2) - ptc2; %subtract the predicted time course from the VTC data
                savename = [voi_dir subj_list{subj}{4} '5\' subj_list{subj}{4} ' ' name_list{voi_num} '_Run' num2str(run) '_VF' num2str(vf) 'combined_random.mat'];
                save(savename,'voi_resids')
                clear voi voitc uvec uvecr coords x y z voitc2 ptc2 voi_resids savename
            end %end all VOIs
            clear vtc prt1 prt2 sdm1 sdm2 betas irtc ptc se
       end %end all runs
     end
end

subjects = {'DH5'};%,'GM5','NW5','SH5'};
region = 'V1';
base_path = 'C:\Users\Anna\Desktop\Pulvinar Data\Resid Files\';
roi_vfs = {'UVF','LVF'};
final_corrs_att = {};
for roi_vf = 1:length(roi_vfs)
    ROIcorrs = {};
    for subj = 1:length(subjects)
        file_list = dir([base_path subjects{subj} '\*' roi_vfs{roi_vf} '*VF' num2str(roi_vf) '*.mat']);
        for file_num = 1:length(file_list)
            load([base_path subjects{subj} '\' file_list(file_num).name]);
            corrs = corr(voi_resids);
            if any(corrs(:)==0)
                keyboard
            end
            pwcorrs = triu(corr(voi_resids),1);            
            pwcorrs = pwcorrs(~isnan(pwcorrs));
            %pwcorrs = pwcorrs(pwcorrs~=0);
            ROIcorrs{length(ROIcorrs)+1} = pwcorrs';
        end     
    end
    final_corrs_att{roi_vf}=cell2mat(ROIcorrs);
end

roi_vfs = {'LVF','UVF'};
final_corrs_unatt = {};
for roi_vf = 1:length(roi_vfs)
    ROIcorrs = {};
    for subj = 1:length(subjects)
        file_list = dir([base_path subjects{subj} '\*' roi_vfs{roi_vf} '*VF' num2str(roi_vf) '*.mat']);
        for file_num = 1:length(file_list)
            load([base_path subjects{subj} '\' file_list(file_num).name]);
            pwcorrs = triu(corr(voi_resids),1);            
            pwcorrs = pwcorrs(~isnan(pwcorrs));
            %pwcorrs = pwcorrs(pwcorrs~=0);
            ROIcorrs{length(ROIcorrs)+1} = pwcorrs';
        end     
    end
    final_corrs_unatt{roi_vf}=cell2mat(ROIcorrs);
end

%output(iter)=mean(abs([final_corrs_unatt{1} final_corrs_unatt{2}])) - mean(abs([final_corrs_att{1} final_corrs_att{2}]))
hist1 = abs([final_corrs_att{1} final_corrs_att{2}]);
hist2 = abs([final_corrs_unatt{1} final_corrs_unatt{2}]);
output(iter) = mean(hist2) - mean(hist1);
mean(hist2) - mean(hist1)

%clearvars -except output
%delete(savename)
end