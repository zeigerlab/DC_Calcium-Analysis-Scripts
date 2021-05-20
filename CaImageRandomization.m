cd('/Users/wzeiger/Documents/Portera Lab/Data/GCaMP6 Imaging/To be Analyzed/Transformed Movies')
source=cd;
destination='/Users/wzeiger/Documents/Portera Lab/Data/GCaMP6 Imaging/To be Analyzed/Randomized Movies';
copyfile(source, destination)
cd(destination)

files = dir('*.tif');

filenames={files.name}';
randomization=randperm(size(files,1))';
T=table(filenames,randomization);

for ii = 1:size(files,1)

    fprintf(1,'Renaming %s\n',files(ii).name)
    rand_name=sprintf('%d.tif',randomization(ii));
    movefile(files(ii).name,rand_name)

end

date=datestr(datetime('now'));
savename=sprintf('Randomization_%s.mat',date);
save(savename,'T')

