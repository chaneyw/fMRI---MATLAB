%this is the original analysis from VSS 

dh = {{'Run %i - Attend UP_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',2,4,6,8},{'Run %i - Attend DOWN_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',3,5,7,9},{'DH_Run_%i_%s.prt'},'DH'};

gm = {{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL lo res.vtc',1,3,5,7},{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL lo res.vtc',2,4,6,8},{'GM_Run_%i_%s.prt'},'GM'};

nw = {{'Run %i - Attend UP_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',3,5,7,10},{'Run %i - Attend DOWN_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',4,6,9,11},{'NW_Run_%i_%s.prt'},'NW'};

sh = {{'Run %i - Attend UP_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',3,5,8,10},{'Run %i - Attend DOWN_SCCAI2_3DMCT_THPGLMF2c_TAL.vtc',4,6,9,11},{'SH_Run_%i_%s.prt'},'SH'};

th = {{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL_LO_RES.vtc',3,4,6},{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL_LO_RES.vtc',2,5,7,9},{}};  

subj_list = {dh,gm,nw,sh}; %TH not used because one fMRI run was bad
base_path = 'C:\Users\Wes\Desktop\Pulvinar Data\PulvLoop\';
voi_dir = 'C:\Users\Wes\Desktop\Pulvinar Data\Resid Files\';

for subj = 1:4 %1:numel(subj_list)
    voi_files = dir([voi_dir subj_list{subj}{4} '\*.voi']);
    file_path = strcat(base_path, subj_list{subj}{4}, '\');
    for vf = [1,2]
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


        for run = 1:numel(vtc_files)

            vtc = BVQXfile(vtc_files{run});

            % SDM options
            opts = struct( ...
                'rcond',  'baseline', ...
                'nvol',    vtc.NrOfVolumes);

            % create SDM
            prt1 = BVQXfile(prt_files{run*2-1});
            combined_prt = BVQXfile(prt_files{run*2-1});


            prt2 = BVQXfile(prt_files{run*2});

            
            
            
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
            [betas, irtc, ptc, se] = sdm1.CalcBetas(vtc);
            vtcdim = size(vtc.VTCData);

            for voi_num = 1:numel(voi_files)
                voi = BVQXfile([voi_dir subj_list{subj}{4} '\' voi_files(voi_num).name]); %load the VOI
                [voitc,uvec,uvecr] = vtc.VOITimeCourse(voi,Inf); %extract timecourse for VOI in upsampled space
                coords=voi.VOI.Voxels(uvec{1},:); %get the TAL coords for the VOI
                [x,y,z]=Tal2Matlab(coords(:,1),coords(:,2),coords(:,3)); %convert the TAL coords to original space
                voitc2 = vtc.VTCData(:,sub2ind(vtcdim(2:end),x,y,z)); %use the TAL coords to get the VTC data for those voxels
                ptc2 = ptc(:,sub2ind(vtcdim(2:end),x,y,z));  %use the TAL coords to get the predicted timecourse for those voxels
                voi_resids = double(voitc2) - ptc2; %subtract the predicted time course from the VTC data

                
                %this is for saving raw data
                voitc2 = double(voitc2);
                %savename = [voi_dir subj_list{subj}{4} '11\' voi_files(voi_num).name(1:end-4) '_Run' num2str(run) '_VF' num2str(vf) '_rawdata.mat'];
                %save(savename,'voitc2')
                
                %this is for saving resids
                savename = [voi_dir subj_list{subj}{4} '41\' voi_files(voi_num).name(1:end-4) '_Run' num2str(run) '_VF' num2str(vf) 'combined.mat'];
                save(savename,'voi_resids')
                clear voi voitc uvec uvecr coords x y z voitc2 ptc2 voi_resids savename
            end %end all VOIs
            clear vtc prt1 prt2 sdm1 sdm2 betas irtc ptc se
       end %end all runs
     end
end