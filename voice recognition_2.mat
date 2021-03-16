clear all

for i=0:4
    ref{i+1}=load(['feature/03-' num2str(i+1) '_1.wav.txt']);
end

for i=0:4
    test1{i+1}=load(['feature/03-' num2str(i+1) '_2.wav.txt']);
    gt1(i+1)=i+1;
end
for i=0:4
    test2{i+1}=load(['feature/03-' num2str(i+1) '_3.wav.txt']);
    gt2(i+1)=i+1;
end

for i=1:length(test1)
    for j=1:length(ref)
        [dist, d, D]=dtw(test1{i}',ref{j}');
        dist1(i,j)=dist;
    end
end
for i=1:length(test2)
    for j=1:length(ref)
        [dist, d, D]=dtw(test2{i}',ref{j}');
        dist2(i,j)=dist;
    end
end

[val1, ind1]=min(dist1');
[val2, ind2]=min(dist2');
cfm1=confusionmat(gt1, ind1);
cfm2=confusionmat(gt2, ind2);
cfm=cfm1+cfm2 %
acc=sum(diag(cfm))/sum(sum(cfm))*100;
