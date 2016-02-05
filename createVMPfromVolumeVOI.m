%designed to save VMPs so that I can visualize the ROIs that I am selecting
%with this method in volume space

subj_list = {'DH','GM','NW','SH'};
base_path = 'C:\Users\Wes\Desktop\Pulvinar Data\Creating ROIs'; 
thresh = 8; %threshold for the t statistic

%to do list

for subj = 1:4
    vtc_name = [base_path '\' subj_list{subj} '\' subj_list{subj} '.vtc'];
    vtc = xff(vtc_name);
    vtcdim = size(vtc.VTCData);
    for vf = 1:2
        if vf == 1
            tmp1 = 'Upper';
            tmp2 = 'UVF';
        else
            tmp1 = 'Lower';
            tmp2 = 'LVF';
        end
            
        vmp_name = [base_path '\' subj_list{subj} '\VMPs\' subj_list{subj} ' Coded ' tmp1 '.vmp'];  
        vmp = xff(vmp_name);

        for hemi = 1:2
            if hemi == 1
                tmp3 = 'LH';
            else
                tmp3 = 'RH';
            end
                
            for roi = 1:2
                if roi == 1
                    tmp4 = 'V1';
                else
                    tmp4 = 'V2';
                end
                    
                voi_name = [base_path '\' subj_list{subj} '\ROIs\' subj_list{subj} ' ' tmp3 ' ' tmp4 ' ' tmp2 '.voi'];  %%this needs to be fixed, make sure VOIs are all called the same
                voi = xff(voi_name);
                [voitc,uvec,uvecr] = vtc.VOITimeCourse(voi,Inf); %extract timecourse for VOI in upsampled space
                coords=voi.VOI(1).Voxels(uvec{1},:); %get the TAL coords for the VOI
                [x,y,z]=Tal2Matlab(coords(:,1),coords(:,2),coords(:,3)); %convert to MATLAB VTC/VMP array subscripts
                voit = vmp.Map.VMPData(sub2ind(vtcdim(2:end),x,y,z)); %use MATLAB subscript to get the t values for those voxels
                stim_spot = coords(abs(voit)>thresh,:); %see which ones are above the threshold
                [x,y,z]=Tal2Matlab(stim_spot(:,1),stim_spot(:,2),stim_spot(:,3));
                vmp_copy = vmp.copy;
                vmp_copy.Map.VMPData = zeros(58,40,46);
                vmp_copy.Map.VMPData(sub2ind(vtcdim(2:end),x,y,z)) = 20;
                save_name = [base_path '\' subj_list{subj} '\' subj_list{subj} ' ' tmp3 ' ' tmp4 ' ' tmp2 ' ' num2str(thresh) '.vmp'];
                vmp_copy.SaveAs(save_name);
            end
        end
    end
end