% make noise bursts
fs = 192000;
dur = 1; % s
noise = [randn(1,fs*dur), zeros(1,fs*dur)];
noise = repmat(noise,1,5);
output = zeros(8,length(noise));
output(1,:) = noise;
output = output/10;
fn = 'C:\Data\stimuli\Kath\noise\noise_20s_fs192k.wav';
audiowrite(fn,output',fs);