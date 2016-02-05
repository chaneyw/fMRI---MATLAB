%this is the same as analysisusingsham except that it uses the data with
%motion correction only

dh = {{'Run %i - Attend UP_SCCAI2_3DMCTS.fmr',2,4,6,8},{'Run %i - Attend DOWN_SCCAI2_3DMCTS.fmr',3,5,7,9},{'DH_Run_%i_%s.prt'},'DH'};

gm = {{'Run %i_SCCAI2_3DMCT_LTR_THP3c.fmr',1,3,5,7},{'Run %i_SCCAI2_3DMCT_LTR_THP3c.fmr',2,4,6,8},{'GM_Run_%i_%s.prt'},'GM'};

nw = {{'Run %i - Attend UP_SCCAI2_3DMCTS.fmr',3,5,7,10},{'Run %i - Attend DOWN_SCCAI2_3DMCTS.fmr',4,6,9,11},{'NW_Run_%i_%s.prt'},'NW'};

sh = {{'Run %i - Attend UP_SCCAI2_3DMCTS.fmr',3,5,8,10},{'Run %i - Attend DOWN_SCCAI2_3DMCTS.fmr',4,6,9,11},{'SH_Run_%i_%s.prt'},'SH'};

th = {{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL_LO_RES.vtc',3,4,6},{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL_LO_RES.vtc',2,5,7,9},{}};  %broken

subj_list = {dh,gm,nw,sh}; %need to add TH once it is fixed
base_path = 'C:\Users\Wes\Desktop\Motion Correction Only Files\';
voi_dir = 'C:\Users\Wes\Dropbox\Resid Files\';

%voi_list = voi_list(2,:);  %temporary test
for subj = [1,2,3,4] %1:numel(subj_list)
    voi_files = dir([voi_dir subj_list{subj}{4} '\*.voi']);
    file_path = strcat(base_path, subj_list{subj}{4}, '\Data\');
    sham_file_path = strcat(base_path, subj_list{subj}{4}, '\FMR\');
%     tal_file = dir([file_path, '*.tal']);
%     tal_object = xff([file_path,tal_file.name]);
%     ia_file = dir([file_path, '*IA.trf']);
%     ia_object = xff([file_path,ia_file.name]);
%     acpc_file = dir([file_path, '*ACPC.trf']);
%     acpc_object = xff([file_path,acpc_file.name]);
    
    for vf = [1,2]
        runs = subj_list{subj}{vf};
        fmr_files = {};
        for i = 2:length(runs)
            fmr_files{i-1} = strcat(file_path,sprintf(runs{1},runs{i}));
        end

        sham_vtc_files = {};
        for i = 2:length(runs)
            temp = sprintf(runs{1},runs{i});
            temp = [temp(1:end-4) '_sham__TAL.vtc'];
            sham_vtc_files{i-1} = strcat(sham_file_path,temp);
        end

        prt_files = {};
        for i = 2:length(runs)
            prt_files = [prt_files strcat(file_path,sprintf(subj_list{subj}{3}{1},runs{i},'Upper'))];
            prt_files = [prt_files strcat(file_path,sprintf(subj_list{subj}{3}{1},runs{i},'Lower'))];
        end

        %for voi_num = 1:size(voi_files,2) %preload the VOIs
        %    eval(['VOI_' num2str(voi_num) ' = BVQXfile(voi_files{' num2str(voi_num) '});']);
        %end

        for run = 1:numel(fmr_files) %1:numel(fmr_files)

            sham_vtc = BVQXfile(sham_vtc_files{run});
            fmr = BVQXfile(fmr_files{run});
            fmrdim = [fmr.NrOfVolumes,fmr.ResolutionX,fmr.ResolutionY,fmr.NrOfSlices];
            fmrdata = fmr.Slice.STCData+0;
            fmrdata = permute(fmrdata, [3,1,2,4]);
            
            % SDM options
            opts = struct( ...
                'rcond',  'baseline', ...
                'nvol',    fmr.NrOfVolumes);

            
            
            % create SDM
            prt1 = BVQXfile(prt_files{run*2-1});
            combined_prt = BVQXfile(prt_files{run*2-1});
            %sdm1 = prt1.CreateSDM(opts);

            prt2 = BVQXfile(prt_files{run*2});
            %sdm2 = prt2.CreateSDM(opts);
            
            
            
            combined_prt.NrOfConditions = 26;
            cond_names = 'abcdefghijklmnopqrstuvwxyz';
            for i = 2:26
                combined_prt.Cond(i).ConditionName = {cond_names(i)};
                combined_prt.Cond(i).OnOffsets = [];
                combined_prt.Cond(i).Weights = ones(6,1);
                combined_prt.Cond(i).Color = randi(256,[1 3])-1;
            end
                
            
            
            for cond1 = 1:(prt1.NrOfConditions-1)
                for cond2 = 1:(prt2.NrOfConditions-1)
                    for onoff1 = 1:size(prt1.Cond(cond1+1).OnOffsets,1)
                        if any(prt2.Cond(cond2+1).OnOffsets(:,1) == prt1.Cond(cond1+1).OnOffsets(onoff1,1))
                           which_idx = find(prt2.Cond(cond2+1).OnOffsets(:,1) == prt1.Cond(cond1+1).OnOffsets(onoff1,1));
                           which_onsets = prt2.Cond(cond2+1).OnOffsets(which_idx,:);
                           combined_prt.Cond(cond1*5-4+cond2).OnOffsets = [combined_prt.Cond(cond1*5-4+cond2).OnOffsets; which_onsets];
                        end
                    end
                    combined_prt.Cond(cond1*5-4+cond2).NrOfOnOffsets = size(combined_prt.Cond(cond1*5-4+cond2).OnOffsets,1);
                end
            end
                    

            sdm1 = combined_prt.CreateSDM(opts);
            %linear.number = 1;
            %linear.ftype = 'linear';
            %fourier.number = 2;
            %sdm1.AddFilters(linear);
            %sdm1.AddFilters(fourier);
            
            [~,~,ptc,~,~,~,resids] = sdm1.CalcBetas(fmr);
            clear fmr
            vtcdim = size(sham_vtc.VTCData);
            %keyboard
            for voi_num = 1:numel(voi_files)
                voi = BVQXfile([voi_dir subj_list{subj}{4} '\' voi_files(voi_num).name]); %load the VOI
                [voitc,uvec,uvecr] = sham_vtc.VOITimeCourse(voi,Inf); %extract timecourse for VOI in upsampled space
                coords=voi.VOI.Voxels(uvec{1},:); %get the TAL coords for the VOI
                [x,y,z]=Tal2Matlab(coords(:,1),coords(:,2),coords(:,3)); %convert the TAL coords to original space
                voitc2 = sham_vtc.VTCData(1:3,sub2ind(vtcdim(2:end),x,y,z));
                
                voitc2 = voitc2';
                data = fmrdata(:,sub2ind(fmrdim(2:end),voitc2(:,1),voitc2(:,2),voitc2(:,3))); 
                
                
                
                %voi = BVQXfile([voi_dir subj_list{subj}{4} '\' voi_files(voi_num).name]); %load the VOI
                %[~,voi_coords] = samplefmrspace(zeros([fmr.ResolutionX, fmr.ResolutionY, fmr.NrOfSlices]), 128-voi.VOI.Voxels, fmr, {ia_object, fa_object, acpc_object, tal_object},'nearest',true);
                %temp = fmr.Slice.STCData(:,:,100,:);
                %temp = reshape(temp,[144 144 24]);
                %[data,voi_coords] = samplefmrspace(temp, 128-voi.VOI.Voxels, fmr, {ia_object, fa_object, acpc_object, tal_object},'nearest');
                %voi_coords = unique(round(voi_coords),'rows');
                %keyboard
                %voi_coords = voi_coords(voi_coords(:,1)<=fmr.ResolutionX & voi_coords(:,2)<=fmr.ResolutionY & voi_coords(:,3)<=fmr.NrOfSlices,:); 
                %voi_coords = voi_coords(voi_coords(:,3) <= fmr.NrOfSlices);
                %voi_coords = [voi_coords(:,2),voi_coords(:,1),voi_coords(:,3)];
                indices = sub2ind(fmrdim(2:4),voi_coords(:,1),voi_coords(:,2),voi_coords(:,3));
                
                voi_resids = resids(:,indices);
                %voi_ptc = ptc(:,indices);
     
                %raw_data = voi_resids + voi_ptc;
                %keeps = find(mean(raw_data>300));
                %voi_resids = voi_resids(:,keeps);
                
                %this is for saving raw data
                %voitc2 = double(voitc2);
                %savename = [voi_dir subj_list{subj}{4} '10\' voi_files(voi_num).name(1:end-4) '_Run' num2str(run) '_VF' num2str(vf) '_rawdata.mat'];
                %save(savename,'voitc2')
                
                %this is for saving resids
                savename = [base_path subj_list{subj}{4} '\' subj_list{subj}{4} '13\' voi_files(voi_num).name(1:end-4) '_Run' num2str(run) '_VF' num2str(vf) 'combined.mat'];
                save(savename,'voi_resids')

            end %end all VOIs
            clear fmr prt1 prt2 sdm1 sdm2 resids
       end %end all runs
     end
end