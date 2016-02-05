function[keep] = expandROI(a)
if size(a,2) ~= 3
    disp('Error: Size must be X by 3')
    return
end

keep = [];
for i = 1:size(a,1)
    b = [(a(i,1)-1):(a(i,1)+1);(a(i,2)-1):(a(i,2)+1);(a(i,3)-1):(a(i,3)+1)]';
    [c,d,e] = meshgrid(b(:,1),b(:,2),b(:,3));
    thisAll = [c(:) d(:) e(:)];
    keep = [keep;thisAll];
end

keep = unique(keep,'rows');
keep = keep(keep(:,3)~=0,:);