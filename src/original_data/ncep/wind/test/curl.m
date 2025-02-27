uf1=permute(uf,[2 1 3]);
vf1=permute(vf,[2 1 3]);
curltau=zeros(192,94,240);

for i=1:240
    
    curltau(:,:,i)=wsc(latitude,longitude,uf1(:,:,i),vf1(:,:,i));
end