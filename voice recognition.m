clear all;

[y, fs] = audioread('123.wav');

framesize_time = 32;
framesize = framesize_time * fs / 1000;
shiftsize_time = 16;
shiftsize = shiftsize_time * fs / 1000;
original_matrix = buffer(y, framesize, (framesize - shiftsize), 'nodelay');

[num_of_samples, num_of_frames] = size(original_matrix);

hamming_window = hamming(num_of_samples);

for i = 1:num_of_frames
    hamming_matrix(:, i) = original_matrix(:, i) .* hamming_window;
end


%%  Energy
energy = sum((hamming_matrix .^ 2));
energy = mean(abs(hamming_matrix));
silence_time = 200;
num_of_silence_frames = ceil((fs / 1000 * silence_time - framesize) / shiftsize) + 1;
energy_threshold = 10*(mean(energy(1:num_of_silence_frames)) + std(energy(1:num_of_silence_frames)));


%% Zero Crossing Rate
for i = 1:num_of_frames
	hamming_matrix_ZCR(:, i) = hamming_matrix(:, i) - mean(hamming_matrix(:, i));	% mean justification
end
ZCR = sum(hamming_matrix_ZCR(1:(end - 1), :) .* hamming_matrix_ZCR(2:end, :) < 0);

lower_pitch = 80;
higher_pitch = 250;


%% Pitch
for i = 1:num_of_frames
    if energy(i) <= energy_threshold
        original_pitch(i) = 0;
        hamming_pitch(i) = 0;
    else
        temp = xcorr(original_matrix(:, i));
        original_acf(:, i) = temp((end / 2):end);
        original_acf_mv(:, i) = movmean(original_acf(:, i), 5);
        [pks, locs] = findpeaks(original_acf_mv((fs / higher_pitch):end, i), 'MinPeakDistance', fs / higher_pitch);
        [val, ind] = max(pks);
        if isempty(val)
            original_pitch(i) = 0;
        else
            original_period(i) = locs(ind) + (fs / higher_pitch) - 1;
            original_period_val(i) = val;
            original_pitch(i) = fs / original_period(i);
            if original_pitch(i) < lower_pitch || original_pitch(i) > higher_pitch
                original_pitch(i) = 0;
            end
        end

        temp = xcorr(hamming_matrix(:, i));
        hamming_acf(:, i) = temp((end / 2):end);
        hamming_acf_mv(:, i) = movmean(hamming_acf(:, i), 5);
        [pks, locs] = findpeaks(hamming_acf_mv((fs / higher_pitch):end, i), 'MinPeakDistance', fs / higher_pitch);
        [val, ind] = max(pks);
        if isempty(val)
            hamming_pitch(i) = 0;
        else
            hamming_period(i) = locs(ind) + (fs / higher_pitch) - 1;
            hamming_period_val(i) = val;
            hamming_pitch(i) = fs / hamming_period(i);
            if hamming_pitch(i) < lower_pitch || hamming_pitch(i) > higher_pitch
                hamming_pitch(i) = 0;
            end
        end
    end
end


%% End point detection
IMX = max(energy(33:33+num_of_silence_frames));
IMN = min(energy(33:33+num_of_silence_frames));
I1 = 0.03 * (IMX - IMN) + IMN;
I2 = 4 * IMN;
ITL = min(I1, I2);
ITU = 100 * ITL;
IZCT = sum(ZCR(33:33+num_of_silence_frames) / length(ZCR(33:33+num_of_silence_frames)));

i = 1;
begin_flag = false;
begin_ind = 0;
flag = false;
while i < num_of_frames
    if ~begin_flag
        if energy(i) > ITL
            begin_ind = i;
            begin_flag = true;
        end
    else
        if energy(i) < ITL
            begin_flag = false;
        elseif energy(i) > ITU
            flag = true;
        end
    end
    if flag
        break;
    end
    i = i + 1;
end

end_ind = num_of_frames;
while i < num_of_frames
    if energy(i) < ITL
        end_ind = i;
        break;
    end
    i = i + 1;
end


%% Plot
figure(1)
plot((1:length(y)) / shiftsize, y);
title('Waveform');
xlabel('Frame');
ylabel('Amplitude');
axis ([-inf inf -max(abs(y)) max(abs(y))]);
print('-djpeg', '-f1', '-r300', 'SSP-01');
close;

figure(2)
subplot(2, 1, 1)
plot((1:length(y)) / shiftsize, y);
title('Waveform');
xlabel('Frame');
ylabel('Amplitude');
axis ([-inf inf -max(abs(y)) max(abs(y))]);
num_of_ind = 20 ;
subplot(2, 2, 3);
plot(original_matrix(:, num_of_ind));
title(['Frame ' num2str(num_of_ind)]);
xlabel('Sample');
ylabel('Amplitude');
axis([-inf inf -max(abs(original_matrix(:, num_of_ind))) max(abs(original_matrix(:, num_of_ind)))]);
num_of_ind = 15;
subplot(2, 2, 4);
plot(original_matrix(:, num_of_ind));
title(['Frame ' num2str(num_of_ind)]);
xlabel('Sample');
ylabel('Amplitude');
axis([-inf inf -max(abs(original_matrix(:, num_of_ind))) max(abs(original_matrix(:, num_of_ind)))]);
print('-djpeg', '-f2', '-r300', 'SSP-02');
close;

figure(3)
plot(hamming_window, 'b');
title('Hamming window');
xlabel('Sample');
ylabel('Amplitude');
axis ([-inf inf 0 1]);
print('-djpeg', '-f3', '-r300', 'SSP-03');
close;

figure(4)
plot(energy, 'b');
hold on;
plot(movmean(energy, 5), 'r');
legend('original', 'smoothing');
title('Energy');
xlabel('Frame');
ylabel('Intensity');
axis tight;
print('-djpeg', '-f4', '-r300', 'SSP-04');
close;

figure(5)
plot(ZCR / framesize, 'b');
hold on;
plot(movmean(ZCR / framesize, 5), 'r');
legend('original', 'smoothing');
title('Zero Crossing Rate');
xlabel('Frame');
ylabel('Rate');
axis ([-inf inf 0 1]);
print('-djpeg', '-f5', '-r300', 'SSP-05');
close;

num_of_ind = 180;
figure(6)
subplot(2, 2, 1);
plot(original_matrix(:, num_of_ind));
title(['Frame ' num2str(num_of_ind)]);
xlabel('Sample');
ylabel('Amplitude');
axis([-inf inf -max(abs(original_matrix(:, num_of_ind))) max(abs(original_matrix(:, num_of_ind)))]);
subplot(2, 2, 2);
plot(hamming_matrix(:, num_of_ind));
title(['Frame ' num2str(num_of_ind)]);
xlabel('Sample');
ylabel('Amplitude');
axis([-inf inf -max(abs(hamming_matrix(:, num_of_ind))) max(abs(hamming_matrix(:, num_of_ind)))]);
subplot(2, 2, 3);
plot(original_acf(:, num_of_ind), 'b');
hold on;
plot(original_acf_mv(:, num_of_ind), 'r');
plot(original_period(num_of_ind), original_period_val(num_of_ind), 'g*');
legend('original', 'smoothing');
title(['Autocorrelation on Frame ' num2str(num_of_ind)]);
xlabel('Sample');
ylabel('Amplitude');
axis tight;
subplot(2, 2, 4);
plot(hamming_acf(:, num_of_ind), 'b');
hold on;
plot(hamming_acf_mv(:, num_of_ind), 'r');
plot(hamming_period(num_of_ind), hamming_period_val(num_of_ind), 'g*');
legend('original', 'smoothing');
title(['Autocorrelation on Frame ' num2str(num_of_ind)]);
xlabel('Sample');
ylabel('Amplitude');
axis tight;
print('-djpeg', '-f6', '-r300', 'SSP-06');
close;

figure(7)
subplot(2, 1, 1);
plot((1:length(y)) / shiftsize, y);
title('Waveform');
xlabel('Frame');
ylabel('Amplitude');
axis ([-inf inf -max(abs(y)) max(abs(y))]);
subplot(2, 1, 2);
plot(original_pitch, 'b');
hold on;
plot(movmean(original_pitch, 5), 'r');
%%legend('original', 'smoothing');
title('Pitch');
xlabel('Frame');
ylabel('Hz');
axis tight;
print('-djpeg', '-f7', '-r300', 'SSP-07');
close;

figure(8)
plot((1:length(y)) / shiftsize, y);
axis ([-inf inf -max(abs(y)) max(abs(y))]);
hold on;
plot([begin_ind, begin_ind], [-max(abs(y)), max(abs(y))], 'r');
plot([end_ind, end_ind], [-max(abs(y)), max(abs(y))], 'g');
title('End point detection');
xlabel('Frame');
ylabel('Amplitude');
axis tight;
print('-djpeg', '-f8', '-r300', 'SSP-08');
close;

figure(9)
[s, w, t] = spectrogram(y, framesize, (framesize - shiftsize), framesize, fs, 'yaxis');
spectrogram(y, framesize, (framesize - shiftsize), framesize, fs, 'yaxis');
xlabel('time');
colormap('jet');
axis tight;
print('-djpeg', '-f9', '-r300', 'SSP-09');
close;

figure(10)
subplot(5, 1, 1);
plot((1:length(y)) / shiftsize, y);
title('Waveform');
xlabel('Frame');
ylabel('Amplitude');
axis ([-inf inf -max(abs(y)) max(abs(y))]);

subplot(5, 1, 2);
plot(energy, 'b');
hold on;
plot(movmean(energy, 5), 'r');
legend('original', 'smoothing');
title('Energy');
xlabel('Frame');
ylabel('Intensity');
axis tight;

subplot(5, 1, 3);
plot(ZCR / framesize, 'b');
hold on;
plot(movmean(ZCR / framesize, 5), 'r');
legend('original', 'smoothing');
title('Zero Crossing Rate');
xlabel('Frame');
ylabel('Rate');
axis ([-inf inf 0 1]);

subplot(5, 1, 4);
plot(original_pitch, 'b');
hold on;
plot(movmean(original_pitch, 5), 'r');
legend('original', 'smoothing');
title('Pitch');
xlabel('Frame');
ylabel('Hz');
axis tight;

subplot(5, 1, 5);
plot((1:length(y)) / shiftsize, y);
axis ([-inf inf -max(abs(y)) max(abs(y))]);
hold on;
plot([begin_ind, begin_ind], [-max(abs(y)), max(abs(y))], 'r');
plot([end_ind, end_ind], [-max(abs(y)), max(abs(y))], 'g');
title('End point detection');
xlabel('Frame');
ylabel('Amplitude');
axis tight;
