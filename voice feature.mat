clear all;

input_dir = ['data/'];
output_dir = ['feature/'];

files = dir([input_dir '/*.wav']);
num_of_files = length(files);
for i = 1:num_of_files
    [y, fs] = audioread([files(i).folder '/' files(i).name]);
    [cepstra, aspectrum, pspectrum] = melfcc(y, fs, 'wintime', 0.032, 'hoptime', 0.016, 'dither', 1);
    delta_cepstra = deltas(cepstra);
    delta_delta_cepstra = deltas(delta_cepstra);
    mfcc = [cepstra; delta_cepstra; delta_delta_cepstra];
    save([output_dir '/' files(i).name '.txt'], 'mfcc', '-ascii');
end
