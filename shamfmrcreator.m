%this is the same thing as shamfmrcreator, I am just attemption to test
%whether or not for subject DH the starting point fmr actually matters or
%not


%vtc_files = uipickfiles('FilterSpec','C:\Users\Anna\Desktop\Pulvinar Data\Pulvinar Attention Reduced Files\*.vtc','Prompt','Select VTCs:','NumFiles',[],'Output','cell');
%prt_files = uipickfiles('FilterSpec','C:\Users\Anna\Desktop\Pulvinar Data\Pulvinar Attention Reduced Files\*.prt','Prompt','Select VTCs:','NumFiles',size(vtc_files,2),'Output','cell');
%voi_files = uipickfiles('FilterSpec','C:\Users\Anna\Desktop\Pulvinar Data\Pulvinar Attention Reduced Files\*.voi','Prompt','Select VOIs:','NumFiles',[]);

dh = {{'Run %i - Attend UP_SCCAI2_3DMCT_THPGLMF2c.fmr',2,4,6,8},{'Run %i - Attend DOWN_SCCAI2_3DMCT_THPGLMF2c.fmr',3,5,7,9},{'DH_Run_%i_%s.prt'},'DH'};

gm = {{'Run %i_SCCAI2_3DMCTS.fmr',1,3,5,7},{'Run %i_SCCAI2_3DMCTS.fmr',2,4,6,8},{'GM_Run_%i_%s.prt'},'GM'};

nw = {{'Run %i - Attend UP_SCCAI2_3DMCTS.fmr',3,5,7,10},{'Run %i - Attend DOWN_SCCAI2_3DMCTS.fmr',4,6,9,11},{'NW_Run_%i_%s.prt'},'NW'};

sh = {{'Run %i - Attend UP_SCCAI2_3DMCTS.fmr',3,5,8,10},{'Run %i - Attend DOWN_SCCAI2_3DMCTS.fmr',4,6,9,11},{'SH_Run_%i_%s.prt'},'SH'};

th = {{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL_LO_RES.vtc',3,4,6},{'Run %i_SCCAI2_3DMCT_LTR_THP3c_TAL_LO_RES.vtc',2,5,7,9},{}};  %broken

subj_list = {dh,gm,nw,sh}; %need to add TH once it is fixed
base_path = 'C:\Users\Wes\Desktop\Motion Correction Only Files\';
voi_dir = 'C:\Users\Wes\Dropbox\Resid Files\';

%voi_list = voi_list(2,:);  %temporary test
for subj = 1
    
    file_path = strcat(base_path, subj_list{subj}{4}, '\Data\');
    
    fmr_files = {};
    fmr_names = {};
    for vf = [1,2]
        runs = subj_list{subj}{vf};
        for i = 2:length(runs)
            fmr_names{i-1 +(vf-1)*4} = sprintf(runs{1},runs{i});
            fmr_files{i-1 +(vf-1)*4} = strcat(file_path,sprintf(runs{1},runs{i}));
        end
    end

        %for voi_num = 1:size(voi_files,2) %preload the VOIs
        %    eval(['VOI_' num2str(voi_num) ' = BVQXfile(voi_files{' num2str(voi_num) '});']);
        %end

    for run = 1:numel(fmr_files) %1:numel(fmr_files)

        %vtc = BVQXfile(vtc_files{run});
        fmr = BVQXfile(fmr_files{run});
        fmrdim = [fmr.NrOfVolumes,fmr.ResolutionX,fmr.ResolutionY,fmr.NrOfSlices];
        %shamdata = 1:fmrdim(2)*fmrdim(3)*fmrdim(4);
        %shamdata = repmat(shamdata,[fmrdim(1) 1]);
        %shamdata = reshape(shamdata,[fmrdim(1), fmrdim(2),fmrdim(3),fmrdim(4)]);
        
        shamdata = zeros([fmrdim(2),fmrdim(3),fmrdim(4),fmrdim(1)]);
        for i = 1:fmrdim(2)
            for j = 1:fmrdim(3)
                for k = 1:fmrdim(4)
                    shamdata(i,j,k,1) = i;
                    shamdata(i,j,k,2) = j;
                    shamdata(i,j,k,3) = k;
                end
            end
        end
                
        shamdata = permute(shamdata,[1,2,4,3]);

        fmr.Slice.STCData = shamdata;            
        savename = [base_path subj_list{subj}{4} '\FMR\' fmr_names{run}(1:end-4) '_sham_test.fmr'];
        fmr.SaveAs(savename);
        clear shamdata fmr
   end %end all runs

end